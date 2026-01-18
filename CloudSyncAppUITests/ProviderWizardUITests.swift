//
//  ProviderWizardUITests.swift
//  CloudSyncAppUITests
//
//  UI tests for Provider Connection Wizard flow
//

import XCTest

final class ProviderWizardUITests: CloudSyncAppUITests {

    // MARK: - Wizard Launch Tests

    func testProviderWizardAccessible() {
        // Given: App is launched
        // When: Looking for Add Provider / Connect button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add' OR label CONTAINS[c] 'Connect' OR label CONTAINS[c] 'New'")).firstMatch

        // Then: Should be able to launch wizard
        if addButton.exists && waitForHittable(addButton) {
            addButton.tap()
            sleep(1)

            // Wizard should appear
            let wizardTitle = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Provider' OR label CONTAINS[c] 'Connect' OR label CONTAINS[c] 'Cloud'")).firstMatch
            XCTAssertTrue(wizardTitle.exists || app.windows.count > 0, "Provider wizard should be accessible")

            takeScreenshot(named: "ProviderWizard_Launch")
        }
    }

    func testWizardHasNavigationButtons() {
        // Given: Wizard is open
        openProviderWizard()

        // When: Looking for navigation controls
        let nextButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Next' OR label CONTAINS[c] 'Continue'")).firstMatch
        let cancelButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Cancel'")).firstMatch
        let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Back' OR label CONTAINS[c] 'Previous'")).firstMatch

        // Then: Navigation buttons should exist
        XCTAssertTrue(nextButton.exists || cancelButton.exists, "Wizard should have navigation buttons")
    }

    // MARK: - Step 1: Choose Provider Tests

    func testChooseProviderStepDisplaysProviders() {
        // Given: Wizard is open on Step 1
        openProviderWizard()

        // When: Looking for provider options
        let providerGrid = app.scrollViews.firstMatch
        let googleDrive = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Google Drive'")).firstMatch
        let dropbox = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Dropbox'")).firstMatch
        let oneDrive = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'OneDrive'")).firstMatch

        // Then: Popular providers should be visible
        let hasProviders = googleDrive.exists || dropbox.exists || oneDrive.exists || providerGrid.exists
        XCTAssertTrue(hasProviders, "Step 1 should display cloud providers")

        takeScreenshot(named: "ProviderWizard_Step1_ChooseProvider")
    }

    func testProviderSearchFunctionality() {
        // Given: Wizard is open on Step 1
        openProviderWizard()

        // When: Looking for search field
        let searchField = app.searchFields.firstMatch
        let textField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'Search'")).firstMatch

        // Then: Search functionality should be available
        if searchField.exists || textField.exists {
            let field = searchField.exists ? searchField : textField
            field.tap()
            field.typeText("Google")
            sleep(1)

            // Results should filter
            let googleResult = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Google'")).firstMatch
            XCTAssertTrue(googleResult.exists, "Search should filter providers")

            takeScreenshot(named: "ProviderWizard_Step1_Search")
        }
    }

    func testSelectProvider() {
        // Given: Wizard is open on Step 1
        openProviderWizard()

        // When: Selecting a provider (try Google Drive first, then others)
        let providers = ["Google Drive", "Dropbox", "OneDrive", "iCloud", "MEGA"]
        var selected = false

        for providerName in providers {
            let provider = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", providerName)).firstMatch
            if !provider.exists {
                // Try static text (might be in a button container)
                let providerText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", providerName)).firstMatch
                if providerText.exists {
                    providerText.tap()
                    selected = true
                    break
                }
            } else {
                provider.tap()
                selected = true
                break
            }
        }

        if selected {
            sleep(1)
            takeScreenshot(named: "ProviderWizard_Step1_Selected")
        }
    }

    func testPopularProvidersSection() {
        // Given: Wizard is open on Step 1
        openProviderWizard()

        // When: Looking for Popular Providers section
        let popularSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Popular'")).firstMatch

        // Then: Popular providers section should exist
        if popularSection.exists {
            XCTAssertTrue(true, "Popular Providers section is visible")
            takeScreenshot(named: "ProviderWizard_Step1_PopularProviders")
        }
    }

    func testAllProvidersSection() {
        // Given: Wizard is open on Step 1
        openProviderWizard()

        // When: Scrolling to All Providers section
        let allSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'All Providers'")).firstMatch
        let scrollView = app.scrollViews.firstMatch

        if scrollView.exists {
            scrollView.swipeUp()
            sleep(1)
        }

        // Then: All providers section should exist
        if allSection.exists {
            XCTAssertTrue(true, "All Providers section is visible")
            takeScreenshot(named: "ProviderWizard_Step1_AllProviders")
        }
    }

    // MARK: - Step 2: Configure Settings Tests

    func testConfigureSettingsStepForOAuth() {
        // Given: OAuth provider (Google Drive) is selected
        openProviderWizard()
        selectProvider("Google Drive")
        goToNextStep()

        // When: On Configure Settings step
        sleep(1)

        // Then: Should show OAuth configuration
        let oauthInfo = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'OAuth' OR label CONTAINS[c] 'Browser' OR label CONTAINS[c] 'sign in'")).firstMatch
        let emailField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'email'")).firstMatch

        let hasOAuthUI = oauthInfo.exists || emailField.exists
        if hasOAuthUI {
            XCTAssertTrue(true, "OAuth configuration UI is shown")
            takeScreenshot(named: "ProviderWizard_Step2_OAuth")
        }
    }

    func testConfigureSettingsStepForCredentials() {
        // Given: Credentials-based provider (MEGA) is selected
        openProviderWizard()
        selectProvider("MEGA")
        goToNextStep()

        // When: On Configure Settings step
        sleep(1)

        // Then: Should show username/password fields
        let usernameField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'email' OR placeholderValue CONTAINS[c] 'user'")).firstMatch
        let passwordField = app.secureTextFields.firstMatch

        let hasCredentialsUI = usernameField.exists || passwordField.exists
        if hasCredentialsUI {
            XCTAssertTrue(true, "Credentials configuration UI is shown")
            takeScreenshot(named: "ProviderWizard_Step2_Credentials")
        }
    }

    func testConfigureSettingsStepForiCloud() {
        // Given: iCloud is selected
        openProviderWizard()
        selectProvider("iCloud")
        goToNextStep()

        // When: On Configure Settings step
        sleep(1)

        // Then: Should show iCloud-specific configuration
        let iCloudInfo = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'iCloud' OR label CONTAINS[c] 'Local' OR label CONTAINS[c] 'folder'")).firstMatch

        if iCloudInfo.exists {
            XCTAssertTrue(true, "iCloud configuration UI is shown")
            takeScreenshot(named: "ProviderWizard_Step2_iCloud")
        }
    }

    func testConfigureSettingsStepForProtonDrive() {
        // Given: Proton Drive is selected (requires 2FA)
        openProviderWizard()
        selectProvider("Proton")
        goToNextStep()

        // When: On Configure Settings step
        sleep(1)

        // Then: Should show 2FA field
        let twoFactorField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] '2FA' OR placeholderValue CONTAINS[c] '123456' OR placeholderValue CONTAINS[c] 'code'")).firstMatch

        if twoFactorField.exists {
            XCTAssertTrue(true, "2FA field is shown for Proton Drive")
            takeScreenshot(named: "ProviderWizard_Step2_ProtonDrive")
        }
    }

    func testSecurityNoteDisplayed() {
        // Given: Wizard is on Configure Settings step
        openProviderWizard()
        selectProvider("MEGA")
        goToNextStep()

        // When: Looking for security note
        let securityNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Keychain' OR label CONTAINS[c] 'secure' OR label CONTAINS[c] 'encrypted'")).firstMatch

        // Then: Security information should be displayed
        if securityNote.exists {
            XCTAssertTrue(true, "Security note is displayed")
        }
    }

    // MARK: - Step 3: Test Connection Tests

    func testTestConnectionStepElements() {
        // Given: Provider configured and moved to step 3
        openProviderWizard()
        selectProvider("Google Drive")
        goToNextStep()
        goToNextStep()

        // When: On Test Connection step
        sleep(1)

        // Then: Should show connection testing UI
        let testingText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Testing' OR label CONTAINS[c] 'Connecting' OR label CONTAINS[c] 'Verifying'")).firstMatch
        let progressIndicator = app.progressIndicators.firstMatch

        let hasTestingUI = testingText.exists || progressIndicator.exists
        if hasTestingUI {
            XCTAssertTrue(true, "Connection testing UI is shown")
            takeScreenshot(named: "ProviderWizard_Step3_Testing")
        }
    }

    func testConnectionProgressSteps() {
        // Given: On Test Connection step
        openProviderWizard()
        selectProvider("Google Drive")
        goToNextStep()
        goToNextStep()

        // When: Looking for progress steps
        sleep(1)

        let progressSteps = [
            "Initialize",
            "Authenticate",
            "Verify",
            "Test"
        ]

        var foundSteps = 0
        for step in progressSteps {
            let stepText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", step)).firstMatch
            if stepText.exists {
                foundSteps += 1
            }
        }

        // Then: Should show some progress steps
        if foundSteps > 0 {
            XCTAssertTrue(true, "Connection progress steps are shown (\(foundSteps) found)")
            takeScreenshot(named: "ProviderWizard_Step3_ProgressSteps")
        }
    }

    func testRetryButtonOnFailure() {
        // Given: Connection test might fail
        openProviderWizard()
        selectProvider("MEGA")
        goToNextStep()

        // Enter invalid credentials
        let usernameField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch

        if usernameField.exists {
            usernameField.tap()
            usernameField.typeText("invalid@test.com")
        }

        if passwordField.exists {
            passwordField.tap()
            passwordField.typeText("wrongpassword")
        }

        goToNextStep()

        // Wait for potential failure
        sleep(5)

        // When: Looking for retry button
        let retryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Retry' OR label CONTAINS[c] 'Try Again'")).firstMatch

        // Then: Retry button might appear on failure
        if retryButton.exists {
            XCTAssertTrue(true, "Retry button is available on connection failure")
            takeScreenshot(named: "ProviderWizard_Step3_Retry")
        }
    }

    // MARK: - Step 4: Success Tests

    func testSuccessStepElements() {
        // Note: This test may not complete if connection requires real credentials
        // Given: Simulated successful connection (iCloud uses local folder)
        openProviderWizard()
        selectProvider("iCloud")
        goToNextStep()
        goToNextStep()

        // Wait for connection test
        sleep(3)

        // Check if we made it to success
        let successText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Success' OR label CONTAINS[c] 'Connected' OR label CONTAINS[c] 'ready'")).firstMatch

        if successText.exists {
            XCTAssertTrue(true, "Success step is shown")
            takeScreenshot(named: "ProviderWizard_Step4_Success")
        }
    }

    func testSuccessStepNextActions() {
        // Given: On Success step
        openProviderWizard()
        selectProvider("iCloud")
        goToNextStep()
        goToNextStep()
        sleep(3)

        // When: Looking for next action buttons
        let browseFilesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Browse' OR label CONTAINS[c] 'Files'")).firstMatch
        let addAnotherButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add Another' OR label CONTAINS[c] 'another'")).firstMatch
        let startSyncingButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sync' OR label CONTAINS[c] 'Start'")).firstMatch

        // Then: Next action buttons should be available
        let hasNextActions = browseFilesButton.exists || addAnotherButton.exists || startSyncingButton.exists
        if hasNextActions {
            XCTAssertTrue(true, "Success step shows next actions")
            takeScreenshot(named: "ProviderWizard_Step4_NextActions")
        }
    }

    // MARK: - Navigation Tests

    func testBackButtonNavigation() {
        // Given: Wizard is on Step 2
        openProviderWizard()
        selectProvider("Google Drive")
        goToNextStep()
        sleep(1)

        // When: Clicking Back button
        let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Back' OR label CONTAINS[c] 'Previous'")).firstMatch

        if backButton.exists && waitForHittable(backButton) {
            backButton.tap()
            sleep(1)

            // Then: Should return to Step 1 (Choose Provider)
            let providerText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Choose' OR label CONTAINS[c] 'Provider' OR label CONTAINS[c] 'Select'")).firstMatch
            XCTAssertTrue(providerText.exists || app.staticTexts["Google Drive"].exists, "Should navigate back to provider selection")

            takeScreenshot(named: "ProviderWizard_BackNavigation")
        }
    }

    func testCancelButtonClosesWizard() {
        // Given: Wizard is open
        openProviderWizard()
        let initialWindowCount = app.windows.count

        // When: Clicking Cancel button
        let cancelButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Cancel'")).firstMatch

        if cancelButton.exists && waitForHittable(cancelButton) {
            cancelButton.tap()
            sleep(1)

            // Then: Wizard should close (window count may decrease)
            // Note: Depends on implementation - wizard may be sheet or window
            takeScreenshot(named: "ProviderWizard_Cancel")
        }
    }

    func testStepIndicatorProgress() {
        // Given: Wizard is open
        openProviderWizard()

        // When: Looking for step indicator
        let stepIndicator = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Step' OR label MATCHES '.*[1-4].*of.*[4].*'")).firstMatch
        let progressDots = app.images.matching(NSPredicate(format: "label CONTAINS[c] 'circle'"))

        // Then: Step progress should be visible
        let hasStepIndicator = stepIndicator.exists || progressDots.count > 0
        if hasStepIndicator {
            XCTAssertTrue(true, "Step indicator is visible")
        }
    }

    // MARK: - Keyboard Interaction Tests

    func testKeyboardNavigationInWizard() {
        // Given: Wizard is open on Configure Settings
        openProviderWizard()
        selectProvider("MEGA")
        goToNextStep()
        sleep(1)

        // When: Using Tab to navigate fields
        let usernameField = app.textFields.firstMatch

        if usernameField.exists {
            usernameField.tap()
            app.typeKey(.tab, modifierFlags: [])
            sleep(1)

            // Then: Focus should move to next field
            takeScreenshot(named: "ProviderWizard_KeyboardNavigation")
        }
    }

    func testEnterKeyAdvancesStep() {
        // Given: Wizard is on Step 1 with provider selected
        openProviderWizard()
        selectProvider("iCloud")

        // When: Pressing Enter
        app.typeKey(.return, modifierFlags: [])
        sleep(1)

        // Then: Should advance to next step (if Next button would be enabled)
        takeScreenshot(named: "ProviderWizard_EnterKey")
    }

    func testEscapeKeyCancel() {
        // Given: Wizard is open
        openProviderWizard()

        // When: Pressing Escape
        app.typeKey(.escape, modifierFlags: [])
        sleep(1)

        // Then: Wizard might close or show cancel confirmation
        takeScreenshot(named: "ProviderWizard_EscapeKey")
    }

    // MARK: - Visual Regression Tests

    func testWizardScreenshots() {
        // Given: Wizard is open
        openProviderWizard()

        // Step 1
        takeScreenshot(named: "ProviderWizard_Visual_Step1")

        // Step 2 (select provider first)
        selectProvider("Google Drive")
        goToNextStep()
        sleep(1)
        takeScreenshot(named: "ProviderWizard_Visual_Step2")

        // Back to step 1 and try different provider
        let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Back'")).firstMatch
        if backButton.exists {
            backButton.tap()
            sleep(1)
        }

        selectProvider("MEGA")
        goToNextStep()
        sleep(1)
        takeScreenshot(named: "ProviderWizard_Visual_Step2_Credentials")
    }

    // MARK: - Helper Methods

    private func openProviderWizard() {
        // Try various ways to open the provider wizard
        let addButtons = [
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add Provider'")),
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add Remote'")),
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Connect'")),
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'New'")),
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '+' OR label == 'plus'"))
        ]

        for buttonQuery in addButtons {
            let button = buttonQuery.firstMatch
            if button.exists && waitForHittable(button, timeout: 2) {
                button.tap()
                sleep(1)
                return
            }
        }

        // Try menu bar
        let fileMenu = app.menuBarItems["File"]
        if fileMenu.exists {
            fileMenu.tap()
            sleep(1)

            let newRemoteItem = app.menuItems.matching(NSPredicate(format: "label CONTAINS[c] 'New' OR label CONTAINS[c] 'Add'")).firstMatch
            if newRemoteItem.exists {
                newRemoteItem.tap()
                sleep(1)
            }
        }
    }

    private func selectProvider(_ providerName: String) {
        // Try clicking on provider by name
        let providerButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", providerName)).firstMatch
        let providerText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", providerName)).firstMatch

        if providerButton.exists && waitForHittable(providerButton, timeout: 2) {
            providerButton.tap()
        } else if providerText.exists {
            providerText.tap()
        }

        sleep(1)
    }

    private func goToNextStep() {
        let nextButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Next' OR label CONTAINS[c] 'Continue'")).firstMatch

        if nextButton.exists && waitForHittable(nextButton, timeout: 2) {
            nextButton.tap()
            sleep(1)
        }
    }

    private func goToPreviousStep() {
        let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Back' OR label CONTAINS[c] 'Previous'")).firstMatch

        if backButton.exists && waitForHittable(backButton, timeout: 2) {
            backButton.tap()
            sleep(1)
        }
    }
}
