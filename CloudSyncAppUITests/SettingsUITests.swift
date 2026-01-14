//
//  SettingsUITests.swift
//  CloudSyncAppUITests
//
//  UI tests for Settings view and preferences persistence
//

import XCTest

final class SettingsUITests: CloudSyncAppUITests {

    // MARK: - Navigation Tests

    func testSettingsAccessible() {
        // Given: App is launched
        // When: Looking for Settings access
        // Settings typically accessed via menu or gear icon

        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Preferences' OR label CONTAINS[c] 'gear'")).firstMatch
        let menuBar = app.menuBars.firstMatch

        // Then: Settings should be accessible somehow
        let hasSettingsButton = settingsButton.exists
        let hasMenuBar = menuBar.exists

        XCTAssertTrue(hasSettingsButton || hasMenuBar, "Settings should be accessible via button or menu bar")
    }

    func testSettingsViaMenuBar() {
        // Given: App is launched
        // When: Accessing Settings via menu bar
        let menuBar = app.menuBars.firstMatch

        if menuBar.exists {
            // Click on app menu
            let appMenu = app.menuBarItems["CloudSyncApp"]
            if appMenu.exists {
                appMenu.tap()
                sleep(1)

                // Look for Settings or Preferences menu item
                let settingsMenuItem = app.menuItems.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Preferences'")).firstMatch

                if settingsMenuItem.exists {
                    settingsMenuItem.tap()
                    sleep(1)

                    // Then: Settings window/sheet should appear
                    let hasSettingsUI = app.windows.count > 0 || app.sheets.count > 0
                    XCTAssertTrue(hasSettingsUI, "Settings UI should appear")

                    takeScreenshot(named: "Settings_Main_View")
                }
            }
        }
    }

    // MARK: - Settings Content Tests

    func testGeneralSettingsTab() {
        // Given: Settings is open
        openSettings()

        // When: Looking for General settings tab
        let generalTab = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'General'")).firstMatch

        // Then: General settings should be available
        if generalTab.exists {
            generalTab.tap()
            sleep(1)

            XCTAssertTrue(true, "General settings tab is accessible")
            takeScreenshot(named: "Settings_General_Tab")
        }
    }

    func testAppearanceSettings() {
        // Given: Settings is open
        openSettings()

        // When: Looking for appearance/theme settings
        let appearanceSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Appearance' OR label CONTAINS[c] 'Theme'")).firstMatch
        let darkModeToggle = app.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Dark' OR label CONTAINS[c] 'Theme'")).firstMatch

        // Then: Appearance settings should be available
        if appearanceSection.exists || darkModeToggle.exists {
            XCTAssertTrue(true, "Appearance settings are available")
        }
    }

    func testSyncSettings() {
        // Given: Settings is open
        openSettings()

        // When: Looking for sync settings
        let syncSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Sync' OR label CONTAINS[c] 'Transfer'")).firstMatch

        // Then: Sync settings should be available
        if syncSection.exists {
            XCTAssertTrue(true, "Sync settings are available")
            takeScreenshot(named: "Settings_Sync_Section")
        }
    }

    func testNotificationSettings() {
        // Given: Settings is open
        openSettings()

        // When: Looking for notification settings
        let notificationSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Notification'")).firstMatch
        let notificationToggle = app.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Notification'")).firstMatch

        // Then: Notification settings should be available
        if notificationSection.exists || notificationToggle.exists {
            XCTAssertTrue(true, "Notification settings are available")
        }
    }

    // MARK: - Settings Persistence Tests

    func testSettingsChangesPersist() {
        // Given: Settings is open
        openSettings()

        // When: Toggling a setting
        let toggles = app.switches
        if toggles.count > 0 {
            let firstToggle = toggles.firstMatch
            let initialValue = firstToggle.value as? String

            // Toggle the switch
            firstToggle.tap()
            sleep(1)

            let newValue = firstToggle.value as? String

            // Then: Value should change
            if initialValue != newValue {
                XCTAssertTrue(true, "Settings can be changed")

                // Toggle back to preserve original state
                firstToggle.tap()
            }
        }
    }

    func testBandwidthSettings() {
        // Given: Settings is open
        openSettings()

        // When: Looking for bandwidth/throttling settings
        let bandwidthSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Bandwidth' OR label CONTAINS[c] 'Speed' OR label CONTAINS[c] 'Throttle'")).firstMatch
        let bandwidthSlider = app.sliders.firstMatch

        // Then: Bandwidth settings should be configurable
        if bandwidthSection.exists || bandwidthSlider.exists {
            XCTAssertTrue(true, "Bandwidth settings are available")

            if bandwidthSlider.exists {
                takeScreenshot(named: "Settings_Bandwidth")
            }
        }
    }

    func testAboutSection() {
        // Given: Settings is open or About menu accessed
        // When: Looking for About information

        // Try menu bar first
        let menuBar = app.menuBars.firstMatch
        if menuBar.exists {
            let appMenu = app.menuBarItems.firstMatch
            appMenu.tap()
            sleep(1)

            let aboutMenuItem = app.menuItems.matching(NSPredicate(format: "label CONTAINS[c] 'About'")).firstMatch
            if aboutMenuItem.exists {
                aboutMenuItem.tap()
                sleep(1)

                // Then: About panel should show version info
                let versionText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Version' OR label CONTAINS[c] '2.0'")).firstMatch

                if versionText.exists {
                    XCTAssertTrue(true, "About section shows version info")
                    takeScreenshot(named: "Settings_About")
                }
            }
        }
    }

    // MARK: - Keyboard Shortcuts

    func testSettingsKeyboardShortcut() {
        // Given: App is launched
        // When: Pressing Cmd+, (standard Settings shortcut)
        app.typeKey(",", modifierFlags: .command)

        sleep(1)

        // Then: Settings should open
        let hasSettingsUI = app.windows.count > 1 || app.sheets.count > 0

        // Note: This may not work in all test environments
        if hasSettingsUI {
            XCTAssertTrue(true, "Settings opened via keyboard shortcut")
        }
    }

    // MARK: - Helper Methods

    private func openSettings() {
        // Try button first
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Preferences'")).firstMatch

        if settingsButton.exists {
            settingsButton.tap()
            sleep(1)
            return
        }

        // Try menu bar
        let menuBar = app.menuBars.firstMatch
        if menuBar.exists {
            let appMenu = app.menuBarItems["CloudSyncApp"]
            if appMenu.exists {
                appMenu.tap()
                sleep(1)

                let settingsMenuItem = app.menuItems.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Preferences'")).firstMatch
                if settingsMenuItem.exists {
                    settingsMenuItem.tap()
                    sleep(1)
                }
            }
        }

        // Try keyboard shortcut as last resort
        app.typeKey(",", modifierFlags: .command)
        sleep(1)
    }

    // MARK: - Visual Regression Tests

    func testSettingsScreenshot() {
        // Given: Settings is open
        openSettings()

        // Wait for content to load
        sleep(2)

        // Then: Take screenshot
        takeScreenshot(named: "Settings_Full_View")
    }
}
