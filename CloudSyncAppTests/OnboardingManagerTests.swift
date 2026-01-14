//
//  OnboardingManagerTests.swift
//  CloudSyncAppTests
//
//  Unit tests for OnboardingManager (#80)
//  Tests state persistence, navigation, and reset functionality
//

import XCTest
@testable import CloudSyncApp

/// Tests for OnboardingManager state persistence and flow (#80)
@MainActor
final class OnboardingManagerTests: XCTestCase {

    // MARK: - Properties

    private var sut: OnboardingManager!
    private var notificationExpectation: XCTestExpectation?
    private var observer: NSObjectProtocol?

    // MARK: - Test Lifecycle

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        // Get fresh instance - note: OnboardingManager is a singleton
        sut = OnboardingManager.shared
        // Reset to clean state
        sut.resetOnboarding()
    }

    override func tearDown() async throws {
        // Clean up notifications
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        notificationExpectation = nil
        // Reset state
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        sut = nil
        try await super.tearDown()
    }

    // MARK: - TC-80.1: First Launch Detection Tests

    /// TC-80.1.1: Fresh install (no UserDefaults) shows onboarding - P0
    func testFirstLaunchShowsOnboarding() {
        // Given: UserDefaults has no "hasCompletedOnboarding" key
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")

        // When: After reset (simulating first launch)
        sut.resetOnboarding()

        // Then: shouldShowOnboarding == true
        XCTAssertTrue(sut.shouldShowOnboarding, "First launch should show onboarding")
        // And: hasCompletedOnboarding == false
        XCTAssertFalse(sut.hasCompletedOnboarding, "First launch should not have completed onboarding")
    }

    /// TC-80.1.2: After completion, onboarding is hidden - P0
    func testSubsequentLaunchHidesOnboarding() {
        // Given: hasCompletedOnboarding == true in UserDefaults
        sut.completeOnboarding()

        // Then: shouldShowOnboarding == false
        XCTAssertFalse(sut.shouldShowOnboarding, "After completion, onboarding should not show")
    }

    /// TC-80.1.3: Default value is false for new users - P1
    func testHasCompletedOnboardingDefaultsFalse() {
        // Given: Fresh state
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        sut.resetOnboarding()

        // Then: Default value should be false
        XCTAssertFalse(sut.hasCompletedOnboarding, "Default hasCompletedOnboarding should be false")
    }

    // MARK: - TC-80.2: State Persistence Tests

    /// TC-80.2.1: Singleton maintains state - P0
    func testCompletionStatePersistsAcrossInstances() {
        // Given: Complete onboarding
        sut.completeOnboarding()

        // When: Accessing shared instance again
        let anotherReference = OnboardingManager.shared

        // Then: State is maintained
        XCTAssertTrue(anotherReference.hasCompletedOnboarding, "Singleton should maintain completion state")
        XCTAssertFalse(anotherReference.shouldShowOnboarding, "Singleton should maintain shouldShowOnboarding state")
    }

    /// TC-80.2.2: State saved to UserDefaults - P0
    func testCompletionStatePersistsToUserDefaults() {
        // Given: OnboardingManager with hasCompletedOnboarding == false
        XCTAssertFalse(sut.hasCompletedOnboarding)

        // When: completeOnboarding() is called
        sut.completeOnboarding()

        // Then: UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") == true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"), "Completion should persist to UserDefaults")
        // And: shouldShowOnboarding == false
        XCTAssertFalse(sut.shouldShowOnboarding, "After completion, should not show onboarding")
    }

    /// TC-80.2.3: Uses "hasCompletedOnboarding" key - P1
    func testAppStorageKeyIsCorrect() {
        // Given: Fresh state
        sut.resetOnboarding()

        // When: Complete onboarding
        sut.completeOnboarding()

        // Then: Correct key is used in UserDefaults
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"), "Should use 'hasCompletedOnboarding' key")
    }

    // MARK: - TC-80.3: Step Navigation Tests

    /// TC-80.3.1: nextStep() moves forward - P0
    func testNextStepAdvancesFromWelcome() {
        // Given: Manager at welcome step
        sut.resetOnboarding()
        XCTAssertEqual(sut.currentStep, .welcome)

        // When: nextStep() is called (on single-step onboarding, this completes)
        // Since there's only one step currently, nextStep should complete
        sut.nextStep()

        // Then: For single-step flow, should complete onboarding
        // Wait a brief moment for async state updates
        let expectation = XCTestExpectation(description: "Step transition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(sut.hasCompletedOnboarding, "With single step, nextStep should complete onboarding")
    }

    /// TC-80.3.2: previousStep() on first step is no-op - P1
    func testPreviousStepDoesNothingOnFirstStep() {
        // Given: Manager at first step
        sut.resetOnboarding()
        XCTAssertTrue(sut.isFirstStep)
        let initialStep = sut.currentStep

        // When: previousStep() is called
        sut.previousStep()

        // Then: Step should not change
        XCTAssertEqual(sut.currentStep, initialStep, "previousStep on first step should be no-op")
    }

    /// TC-80.3.3: goToStep() navigates directly - P1
    func testGoToStepJumpsToSpecificStep() {
        // Given: Manager in any state
        sut.resetOnboarding()

        // When: goToStep() called with welcome
        sut.goToStep(.welcome)

        // Then: Should be at welcome step
        XCTAssertEqual(sut.currentStep, .welcome, "goToStep should navigate to specified step")
    }

    /// TC-80.3.4: Final step triggers completion - P0
    func testNextStepOnLastStepCompletesOnboarding() {
        // Given: OnboardingManager at last step (isLastStep == true)
        sut.resetOnboarding()
        // Go to last step (in current implementation, welcome is the only/last step)
        while !sut.isLastStep {
            // This loop won't execute if welcome is the only step
            sut.goToStep(OnboardingStep.allCases.last!)
        }
        XCTAssertTrue(sut.isLastStep)

        // Set up notification observer
        notificationExpectation = expectation(description: "onboardingCompleted notification")
        observer = NotificationCenter.default.addObserver(
            forName: .onboardingCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.notificationExpectation?.fulfill()
        }

        // When: nextStep() is called
        sut.nextStep()

        // Then: Wait for async completion and verify
        wait(for: [notificationExpectation!], timeout: 1.0)

        // Verify hasCompletedOnboarding == true
        XCTAssertTrue(sut.hasCompletedOnboarding, "After last step, should mark as completed")
        // And: shouldShowOnboarding == false
        XCTAssertFalse(sut.shouldShowOnboarding, "After last step, should hide onboarding")
    }

    /// TC-80.3.5: progress returns correct percentage - P2
    func testProgressCalculation() {
        // Given: Manager at first step
        sut.resetOnboarding()

        // Then: Progress should be calculated correctly
        let expectedProgress = Double(sut.currentStep.rawValue + 1) / Double(sut.totalSteps)
        XCTAssertEqual(sut.progress, expectedProgress, accuracy: 0.001, "Progress should be correctly calculated")
    }

    // MARK: - TC-80.4: Reset Onboarding Functionality Tests

    /// TC-80.4.1: resetOnboarding() sets hasCompletedOnboarding to false - P0
    func testResetOnboardingClearsCompletion() {
        // Given: OnboardingManager with hasCompletedOnboarding == true
        sut.completeOnboarding()
        XCTAssertTrue(sut.hasCompletedOnboarding)

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: hasCompletedOnboarding == false
        XCTAssertFalse(sut.hasCompletedOnboarding, "Reset should clear completion state")
    }

    /// TC-80.4.2: currentStep becomes .welcome - P0
    func testResetOnboardingResetsToWelcomeStep() {
        // Given: OnboardingManager at any step
        sut.completeOnboarding()

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: currentStep == .welcome
        XCTAssertEqual(sut.currentStep, .welcome, "Reset should return to welcome step")
    }

    /// TC-80.4.3: shouldShowOnboarding becomes true - P0
    func testResetOnboardingShowsOnboarding() {
        // Given: OnboardingManager with completed state
        sut.completeOnboarding()
        XCTAssertFalse(sut.shouldShowOnboarding)

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: shouldShowOnboarding == true
        XCTAssertTrue(sut.shouldShowOnboarding, "Reset should show onboarding again")
    }

    /// TC-80.4.4: Notification.onboardingReset is posted - P1
    func testResetOnboardingPostsNotification() {
        // Given: OnboardingManager with completed state
        sut.completeOnboarding()

        // Set up notification observer
        notificationExpectation = expectation(description: "onboardingReset notification")
        observer = NotificationCenter.default.addObserver(
            forName: .onboardingReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.notificationExpectation?.fulfill()
        }

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: Notification should be posted
        wait(for: [notificationExpectation!], timeout: 1.0)
    }

    // MARK: - TC-80.5: Skip Onboarding Tests

    /// TC-80.5.1: skipOnboarding() marks as complete - P0
    func testSkipOnboardingCompletesFlow() {
        // Given: Fresh onboarding state
        sut.resetOnboarding()
        XCTAssertFalse(sut.hasCompletedOnboarding)

        // When: skipOnboarding() is called
        sut.skipOnboarding()

        // Then: Should be marked as complete
        XCTAssertTrue(sut.hasCompletedOnboarding, "Skip should mark onboarding as complete")
        XCTAssertFalse(sut.shouldShowOnboarding, "Skip should hide onboarding")
    }

    /// TC-80.5.2: Can skip from any step - P1
    func testSkipOnboardingFromAnyStep() {
        // Given: Manager at welcome step
        sut.resetOnboarding()
        XCTAssertEqual(sut.currentStep, .welcome)

        // When: skipOnboarding() is called
        sut.skipOnboarding()

        // Then: Should complete regardless of current step
        XCTAssertTrue(sut.hasCompletedOnboarding, "Should be able to skip from any step")
    }

    // MARK: - TC-80.6: Notification Integration Tests

    /// TC-80.6.1: Notification fires on completion - P1
    func testOnboardingCompletedNotificationPosted() {
        // Given: Fresh state
        sut.resetOnboarding()

        // Set up notification observer
        notificationExpectation = expectation(description: "onboardingCompleted notification")
        observer = NotificationCenter.default.addObserver(
            forName: .onboardingCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.notificationExpectation?.fulfill()
        }

        // When: completeOnboarding() is called
        sut.completeOnboarding()

        // Then: Notification should be posted
        wait(for: [notificationExpectation!], timeout: 1.0)
    }

    /// TC-80.6.2: Notification fires on reset - P1
    func testOnboardingResetNotificationPosted() {
        // Given: Completed state
        sut.completeOnboarding()

        // Set up notification observer
        notificationExpectation = expectation(description: "onboardingReset notification")
        observer = NotificationCenter.default.addObserver(
            forName: .onboardingReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.notificationExpectation?.fulfill()
        }

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: Notification should be posted
        wait(for: [notificationExpectation!], timeout: 1.0)
    }

    // MARK: - Computed Properties Tests

    func testTotalStepsReturnsCorrectCount() {
        XCTAssertEqual(sut.totalSteps, OnboardingStep.allCases.count, "totalSteps should equal all cases count")
    }

    func testCurrentStepNumberIsOneBased() {
        sut.resetOnboarding()
        XCTAssertEqual(sut.currentStepNumber, 1, "First step should be number 1 (1-based)")
    }

    func testIsFirstStepOnWelcome() {
        sut.resetOnboarding()
        XCTAssertTrue(sut.isFirstStep, "Welcome step should be first step")
    }

    // MARK: - OnboardingStep Enum Tests

    func testOnboardingStepHasTitle() {
        XCTAssertFalse(OnboardingStep.welcome.title.isEmpty, "Welcome step should have a title")
        XCTAssertEqual(OnboardingStep.welcome.title, "Welcome", "Welcome step title should be 'Welcome'")
    }

    func testOnboardingStepHasId() {
        XCTAssertEqual(OnboardingStep.welcome.id, OnboardingStep.welcome.rawValue, "Step id should equal rawValue")
    }

    func testOnboardingStepRawValues() {
        XCTAssertEqual(OnboardingStep.welcome.rawValue, 0, "Welcome should have rawValue 0")
    }
}
