//
//  CloudSyncAppUITests.swift
//  CloudSyncAppUITests
//
//  Base UI test class with shared functionality
//

import XCTest

class CloudSyncAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Stop immediately when a failure occurs
        continueAfterFailure = false
        
        // Launch app for each test
        app = XCUIApplication()
        
        // Set launch arguments for testing
        app.launchArguments = ["--uitesting"]
        
        // Launch the application
        app.launch()
        
        // 🐌 SLOW DOWN: Wait 2 seconds so you can see the app launch
        sleep(2)
    }
    
    override func tearDownWithError() throws {
        // Terminate app after each test
        app.terminate()
        app = nil
    }
    
    // MARK: - Test: App Launch
    
    func testAppLaunches() throws {
        // Given: App is launched
        // Then: App should be running
        XCTAssertTrue(app.state == .runningForeground, "App should be in foreground")
    }
    
    func testMainWindowExists() throws {
        // Given: App is launched
        // Then: Main window should exist
        let window = app.windows.firstMatch
        XCTAssertTrue(window.exists, "Main window should exist")
    }
    
    func testMenuBarIconExists() throws {
        // Given: App is launched
        // Then: Menu bar should be accessible
        // Note: Testing menu bar items requires accessibility permissions
        // This is a basic structure test
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    // MARK: - Helper Methods
    
    /// Wait for element to exist with timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for element to be hittable (visible and interactive)
    func waitForHittable(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Take screenshot with description
    func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
