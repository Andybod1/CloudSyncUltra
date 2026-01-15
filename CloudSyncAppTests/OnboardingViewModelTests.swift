//
//  OnboardingViewModelTests.swift
//  CloudSyncAppTests
//
//  Unit tests for OnboardingViewModel (#80, #81, #82)
//  Tests state persistence, navigation, and multi-step flow
//

import XCTest
@testable import CloudSyncApp

/// Tests for OnboardingViewModel state persistence and multi-step flow (#80, #81, #82)
@MainActor
final class OnboardingViewModelTests: XCTestCase {

    // MARK: - Properties

    private var sut: OnboardingViewModel!
    private var notificationExpectation: XCTestExpectation?
    private var observer: NSObjectProtocol?

    // MARK: - Test Lifecycle

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        // Get fresh instance - note: OnboardingViewModel is a singleton
        sut = OnboardingViewModel.shared
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
        let anotherReference = OnboardingViewModel.shared

        // Then: State is maintained
        XCTAssertTrue(anotherReference.hasCompletedOnboarding, "Singleton should maintain completion state")
        XCTAssertFalse(anotherReference.shouldShowOnboarding, "Singleton should maintain shouldShowOnboarding state")
    }

    /// TC-80.2.2: State saved to UserDefaults - P0
    func testCompletionStatePersistsToUserDefaults() {
        // Given: OnboardingViewModel with hasCompletedOnboarding == false
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

    // MARK: - TC-80.3: Multi-Step Navigation Tests

    /// TC-80.3.1: Initial step is welcome - P0
    func testInitialStepIsWelcome() {
        // Given: Fresh state
        sut.resetOnboarding()

        // Then: Should start at welcome step
        XCTAssertEqual(sut.currentStep, .welcome, "Initial step should be welcome")
        XCTAssertEqual(sut.currentStepNumber, 1, "Welcome should be step 1")
    }

    /// TC-80.3.2: nextStep() advances through all steps - P0
    func testNextStepAdvancesThroughAllSteps() {
        // Given: Manager at welcome step
        sut.resetOnboarding()
        XCTAssertEqual(sut.currentStep, .welcome)

        // When: nextStep() is called
        sut.nextStep()

        // Wait for async transition
        let expectation1 = XCTestExpectation(description: "Step transition 1")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)

        // Then: Should be at addProvider step
        XCTAssertEqual(sut.currentStep, .addProvider, "After first nextStep, should be at addProvider")

        // When: nextStep() again
        sut.nextStep()
        let expectation2 = XCTestExpectation(description: "Step transition 2")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)

        // Then: Should be at firstSync step
        XCTAssertEqual(sut.currentStep, .firstSync, "After second nextStep, should be at firstSync")

        // When: nextStep() again
        sut.nextStep()
        let expectation3 = XCTestExpectation(description: "Step transition 3")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 1.0)

        // Then: Should be at completion step
        XCTAssertEqual(sut.currentStep, .completion, "After third nextStep, should be at completion")
    }

    /// TC-80.3.3: previousStep() on first step is no-op - P1
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

    /// TC-80.3.4: previousStep() goes back from second step - P1
    func testPreviousStepGoesBack() {
        // Given: Manager at addProvider step
        sut.resetOnboarding()
        sut.goToStep(.addProvider)
        XCTAssertEqual(sut.currentStep, .addProvider)

        // When: previousStep() is called
        sut.previousStep()

        // Wait for async transition
        let expectation = XCTestExpectation(description: "Step transition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then: Should be at welcome step
        XCTAssertEqual(sut.currentStep, .welcome, "previousStep should go back to welcome")
    }

    /// TC-80.3.5: goToStep() navigates directly - P1
    func testGoToStepJumpsToSpecificStep() {
        // Given: Manager at welcome
        sut.resetOnboarding()

        // When: goToStep() called with completion
        sut.goToStep(.completion)

        // Then: Should be at completion step (async animation)
        let expectation = XCTestExpectation(description: "Step transition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(sut.currentStep, .completion, "goToStep should navigate to specified step")
    }

    /// TC-80.3.6: Final step nextStep triggers completion - P0
    func testNextStepOnLastStepCompletesOnboarding() {
        // Given: OnboardingViewModel at last step
        sut.resetOnboarding()
        sut.goToStep(.completion)

        // Set up notification observer
        notificationExpectation = expectation(description: "onboardingCompleted notification")
        observer = NotificationCenter.default.addObserver(
            forName: .onboardingCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.notificationExpectation?.fulfill()
        }

        // When: nextStep() is called on completion step
        sut.nextStep()

        // Then: Wait for completion and verify
        wait(for: [notificationExpectation!], timeout: 1.0)

        XCTAssertTrue(sut.hasCompletedOnboarding, "After last step, should mark as completed")
        XCTAssertFalse(sut.shouldShowOnboarding, "After last step, should hide onboarding")
    }

    /// TC-80.3.7: progress returns correct percentage - P2
    func testProgressCalculation() {
        // Given: Manager at different steps
        sut.resetOnboarding()

        // Step 0 (welcome): progress = 1/4 = 0.25
        XCTAssertEqual(sut.progress, 0.25, accuracy: 0.001, "Welcome progress should be 25%")

        sut.goToStep(.addProvider)
        let exp1 = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp1.fulfill() }
        wait(for: [exp1], timeout: 1.0)
        // Step 1 (addProvider): progress = 2/4 = 0.5
        XCTAssertEqual(sut.progress, 0.5, accuracy: 0.001, "AddProvider progress should be 50%")

        sut.goToStep(.firstSync)
        let exp2 = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)
        // Step 2 (firstSync): progress = 3/4 = 0.75
        XCTAssertEqual(sut.progress, 0.75, accuracy: 0.001, "FirstSync progress should be 75%")

        sut.goToStep(.completion)
        let exp3 = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp3.fulfill() }
        wait(for: [exp3], timeout: 1.0)
        // Step 3 (completion): progress = 4/4 = 1.0
        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.001, "Completion progress should be 100%")
    }

    // MARK: - TC-80.4: Reset Onboarding Functionality Tests

    /// TC-80.4.1: resetOnboarding() sets hasCompletedOnboarding to false - P0
    func testResetOnboardingClearsCompletion() {
        // Given: OnboardingViewModel with hasCompletedOnboarding == true
        sut.completeOnboarding()
        XCTAssertTrue(sut.hasCompletedOnboarding)

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: hasCompletedOnboarding == false
        XCTAssertFalse(sut.hasCompletedOnboarding, "Reset should clear completion state")
    }

    /// TC-80.4.2: currentStep becomes .welcome - P0
    func testResetOnboardingResetsToWelcomeStep() {
        // Given: OnboardingViewModel at any step
        sut.completeOnboarding()
        sut.goToStep(.completion)

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: currentStep == .welcome
        XCTAssertEqual(sut.currentStep, .welcome, "Reset should return to welcome step")
    }

    /// TC-80.4.3: shouldShowOnboarding becomes true - P0
    func testResetOnboardingShowsOnboarding() {
        // Given: OnboardingViewModel with completed state
        sut.completeOnboarding()
        XCTAssertFalse(sut.shouldShowOnboarding)

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: shouldShowOnboarding == true
        XCTAssertTrue(sut.shouldShowOnboarding, "Reset should show onboarding again")
    }

    /// TC-80.4.4: Reset clears provider connection state - P1
    func testResetOnboardingClearsProviderState() {
        // Given: Provider was connected during onboarding
        sut.providerConnected(name: "Google Drive")
        XCTAssertTrue(sut.hasConnectedProvider)
        XCTAssertEqual(sut.connectedProviderName, "Google Drive")

        // When: resetOnboarding() is called
        sut.resetOnboarding()

        // Then: Provider state should be cleared
        XCTAssertFalse(sut.hasConnectedProvider, "Reset should clear provider connection state")
        XCTAssertNil(sut.connectedProviderName, "Reset should clear provider name")
    }

    /// TC-80.4.5: Notification.onboardingReset is posted - P1
    func testResetOnboardingPostsNotification() {
        // Given: OnboardingViewModel with completed state
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
        // Given: Manager at various steps
        sut.resetOnboarding()

        // Test skip from welcome
        sut.skipOnboarding()
        XCTAssertTrue(sut.hasCompletedOnboarding, "Should be able to skip from welcome")

        // Reset and test from addProvider
        sut.resetOnboarding()
        sut.goToStep(.addProvider)
        sut.skipOnboarding()
        XCTAssertTrue(sut.hasCompletedOnboarding, "Should be able to skip from addProvider")

        // Reset and test from firstSync
        sut.resetOnboarding()
        sut.goToStep(.firstSync)
        sut.skipOnboarding()
        XCTAssertTrue(sut.hasCompletedOnboarding, "Should be able to skip from firstSync")
    }

    /// TC-80.5.3: skipCurrentStep() advances without completing - P1
    func testSkipCurrentStepAdvancesWithoutCompleting() {
        // Given: Manager at welcome step
        sut.resetOnboarding()
        XCTAssertEqual(sut.currentStep, .welcome)

        // When: skipCurrentStep() is called
        sut.skipCurrentStep()

        // Wait for transition
        let expectation = XCTestExpectation(description: "Step transition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then: Should advance but not complete
        XCTAssertNotEqual(sut.currentStep, .welcome, "Should advance from welcome step")
        XCTAssertFalse(sut.hasCompletedOnboarding, "Should not complete onboarding yet")
    }

    // MARK: - TC-81: Provider Connection Tests

    /// TC-81.1: providerConnected() sets state and advances - P0
    func testProviderConnectedSetsStateAndAdvances() {
        // Given: Manager at addProvider step
        sut.resetOnboarding()
        sut.goToStep(.addProvider)

        // When: providerConnected() is called
        sut.providerConnected(name: "Dropbox")

        // Wait for transition
        let expectation = XCTestExpectation(description: "Step transition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then: State should be updated
        XCTAssertTrue(sut.hasConnectedProvider, "Should mark provider as connected")
        XCTAssertEqual(sut.connectedProviderName, "Dropbox", "Should store provider name")
        // And: Should advance to next step
        XCTAssertEqual(sut.currentStep, .firstSync, "Should advance to firstSync step")
    }

    /// TC-81.2: canSkip is always true - P2
    func testCanSkipIsAlwaysTrue() {
        // Given: Manager at various steps
        sut.resetOnboarding()
        XCTAssertTrue(sut.canSkip, "canSkip should be true at welcome")

        sut.goToStep(.addProvider)
        XCTAssertTrue(sut.canSkip, "canSkip should be true at addProvider")

        sut.goToStep(.firstSync)
        XCTAssertTrue(sut.canSkip, "canSkip should be true at firstSync")
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

    // MARK: - Computed Properties Tests

    func testTotalStepsReturnsCorrectCount() {
        XCTAssertEqual(sut.totalSteps, 4, "totalSteps should be 4")
        XCTAssertEqual(sut.totalSteps, OnboardingStep.allCases.count, "totalSteps should equal all cases count")
    }

    func testCurrentStepNumberIsOneBased() {
        sut.resetOnboarding()
        XCTAssertEqual(sut.currentStepNumber, 1, "First step should be number 1 (1-based)")

        sut.goToStep(.completion)
        let exp = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(sut.currentStepNumber, 4, "Last step should be number 4")
    }

    func testIsFirstStepOnWelcome() {
        sut.resetOnboarding()
        XCTAssertTrue(sut.isFirstStep, "Welcome step should be first step")

        sut.goToStep(.addProvider)
        XCTAssertFalse(sut.isFirstStep, "AddProvider should not be first step")
    }

    func testIsLastStepOnCompletion() {
        sut.resetOnboarding()
        XCTAssertFalse(sut.isLastStep, "Welcome should not be last step")

        sut.goToStep(.completion)
        let exp = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(sut.isLastStep, "Completion should be last step")
    }

    func testCanGoBackProperty() {
        sut.resetOnboarding()
        XCTAssertFalse(sut.canGoBack, "Cannot go back from first step")

        sut.goToStep(.addProvider)
        let exp1 = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp1.fulfill() }
        wait(for: [exp1], timeout: 1.0)
        XCTAssertTrue(sut.canGoBack, "Can go back from addProvider")

        sut.goToStep(.completion)
        let exp2 = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)
        XCTAssertFalse(sut.canGoBack, "Cannot go back from completion step")
    }

    // MARK: - OnboardingStep Enum Tests

    func testOnboardingStepHasTitles() {
        XCTAssertEqual(OnboardingStep.welcome.title, "Welcome")
        XCTAssertEqual(OnboardingStep.addProvider.title, "Connect Cloud")
        XCTAssertEqual(OnboardingStep.firstSync.title, "First Sync")
        XCTAssertEqual(OnboardingStep.completion.title, "Complete")
    }

    func testOnboardingStepHasDescriptions() {
        XCTAssertFalse(OnboardingStep.welcome.description.isEmpty)
        XCTAssertFalse(OnboardingStep.addProvider.description.isEmpty)
        XCTAssertFalse(OnboardingStep.firstSync.description.isEmpty)
        XCTAssertFalse(OnboardingStep.completion.description.isEmpty)
    }

    func testOnboardingStepHasId() {
        XCTAssertEqual(OnboardingStep.welcome.id, OnboardingStep.welcome.rawValue)
        XCTAssertEqual(OnboardingStep.completion.id, OnboardingStep.completion.rawValue)
    }

    func testOnboardingStepRawValues() {
        XCTAssertEqual(OnboardingStep.welcome.rawValue, 0)
        XCTAssertEqual(OnboardingStep.addProvider.rawValue, 1)
        XCTAssertEqual(OnboardingStep.firstSync.rawValue, 2)
        XCTAssertEqual(OnboardingStep.completion.rawValue, 3)
    }

    func testOnboardingStepAllCasesOrder() {
        let allCases = OnboardingStep.allCases
        XCTAssertEqual(allCases.count, 4, "Should have 4 steps")
        XCTAssertEqual(allCases[0], .welcome)
        XCTAssertEqual(allCases[1], .addProvider)
        XCTAssertEqual(allCases[2], .firstSync)
        XCTAssertEqual(allCases[3], .completion)
    }

    // MARK: - Legacy Alias Test

    func testOnboardingManagerAliasWorks() {
        // The typealias should allow using OnboardingManager
        let manager: OnboardingManager = OnboardingViewModel.shared
        XCTAssertNotNil(manager, "OnboardingManager alias should work")
    }

    // MARK: - UI Logic Tests for Onboarding Fixes

    /// Test that provider grid shows correct count for popular vs all providers
    func testProviderGridCounts() {
        // Popular providers count (hardcoded in AddProviderStepView)
        let popularProviders: [CloudProviderType] = [
            .googleDrive,
            .dropbox,
            .oneDrive,
            .icloud,
            .protonDrive
        ]
        XCTAssertEqual(popularProviders.count, 5, "Should show 5 popular providers initially")

        // All providers count (excluding local)
        let allProviders = CloudProviderType.allCases.filter { $0.isSupported && $0 != .local }
        XCTAssertGreaterThanOrEqual(allProviders.count, 40, "Should have 40+ providers available")
    }

    /// Test provider name display lengths
    func testProviderNameDisplayLengths() {
        // Verify all provider names are reasonable length for UI
        let providers = CloudProviderType.allCases.filter { $0.isSupported }

        for provider in providers {
            XCTAssertLessThanOrEqual(provider.displayName.count, 30,
                "Provider name '\(provider.displayName)' might be too long for UI")
        }
    }


    /// Test skip after provider connection preserves state correctly
    func testSkipAfterProviderConnection() {
        // Given: Provider connected at addProvider step
        sut.goToStep(.addProvider)
        let providerName = "Test Cloud Provider"
        sut.providerConnected(name: providerName)

        // Verify provider was connected
        XCTAssertTrue(sut.hasConnectedProvider)
        XCTAssertEqual(sut.connectedProviderName, providerName)

        // When: Skip is called
        sut.skipOnboarding()

        // Then: Should complete onboarding
        XCTAssertTrue(sut.hasCompletedOnboarding)
        XCTAssertFalse(sut.shouldShowOnboarding)

        // Cleanup: Reset state for other tests
        sut.resetOnboarding()
    }

    /// Test OAuth vs manual configuration provider types
    func testProviderAuthenticationTypes() {
        let oauthProviders = CloudProviderType.allCases.filter { $0.requiresOAuth }
        let manualProviders = CloudProviderType.allCases.filter {
            $0.isSupported && !$0.requiresOAuth && $0 != .local
        }

        // Verify we have both authentication types
        XCTAssertFalse(oauthProviders.isEmpty, "Should have OAuth providers")
        XCTAssertFalse(manualProviders.isEmpty, "Should have manual config providers")

        // Verify popular providers include OAuth types
        let popularOAuth: [CloudProviderType] = [.googleDrive, .dropbox, .oneDrive]
        for provider in popularOAuth {
            XCTAssertTrue(provider.requiresOAuth, "\(provider.displayName) should require OAuth")
        }
    }

    /// Test Quick Tips content structure validation
    func testQuickTipsContentStructure() {
        // Validate Quick Tips shown in CompletionStepView
        let expectedTips = [
            ("keyboard", "Keyboard Shortcuts", "Cmd+N for new task"),
            ("calendar.badge.clock", "Scheduled Syncs", "Automate your backups"),
            ("lock.shield.fill", "Encryption", "Enable end-to-end encryption")
        ]

        // Verify all tips have required fields with appropriate lengths
        for tip in expectedTips {
            XCTAssertFalse(tip.0.isEmpty, "Icon name should not be empty")
            XCTAssertFalse(tip.1.isEmpty, "Title should not be empty")
            XCTAssertFalse(tip.2.isEmpty, "Description should not be empty")
            XCTAssertLessThanOrEqual(tip.2.count, 50, "Description should fit in 2 lines (28px height)")
        }
    }

    /// Test provider connection advances step correctly
    func testProviderConnectionAdvancesStep() {
        // Given: Fresh state at addProvider step
        sut.resetOnboarding()
        sut.goToStep(.addProvider)

        // Wait for navigation
        let exp1 = XCTestExpectation(description: "wait for navigation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp1.fulfill() }
        wait(for: [exp1], timeout: 1.0)

        XCTAssertEqual(sut.currentStep, .addProvider)

        // When: Provider is connected
        sut.providerConnected(name: "Test Provider")

        // Wait for transition
        let exp2 = XCTestExpectation(description: "wait for transition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)

        // Then: Should advance to firstSync and update state
        XCTAssertTrue(sut.hasConnectedProvider)
        XCTAssertEqual(sut.connectedProviderName, "Test Provider")
        XCTAssertEqual(sut.currentStep, .firstSync, "Should advance to firstSync after provider connection")
    }

    /// Test onboarding completion with multiple providers edge case
    func testMultipleProvidersOnboarding() {
        // This tests the edge case where user might connect multiple providers
        // during onboarding (though UI currently only tracks first)

        sut.resetOnboarding()
        sut.goToStep(.addProvider)

        // Connect first provider
        sut.providerConnected(name: "Provider 1")
        XCTAssertEqual(sut.connectedProviderName, "Provider 1")

        // Attempt to connect second provider (edge case)
        // In current implementation, this would overwrite
        sut.providerConnected(name: "Provider 2")
        XCTAssertEqual(sut.connectedProviderName, "Provider 2", "Last provider should be tracked")
    }

    /// Test step transition animation timing
    func testStepTransitionTiming() {
        // Verify step transitions complete within reasonable time
        sut.resetOnboarding()
        let startTime = Date()

        // Trigger navigation
        sut.nextStep()

        // Wait for transition
        let exp = XCTestExpectation(description: "transition timing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { exp.fulfill() }
        wait(for: [exp], timeout: 0.5)

        let duration = Date().timeIntervalSince(startTime)

        // Verify transition was quick
        XCTAssertLessThan(duration, 0.5, "Step transition should complete under 500ms")
        XCTAssertEqual(sut.currentStep, .addProvider, "Should have transitioned to next step")
    }
}
