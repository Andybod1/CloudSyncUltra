//
//  DashboardUITests.swift
//  CloudSyncAppUITests
//
//  UI tests for Dashboard view functionality
//

import XCTest

final class DashboardUITests: CloudSyncAppUITests {
    
    // MARK: - Dashboard Navigation Tests
    
    func testDashboardTabExists() {
        // Given: App is launched
        // When: Looking for Dashboard tab
        let dashboardTab = app.buttons["Dashboard"]
        
        // Then: Dashboard tab should exist and be selectable
        XCTAssertTrue(waitForElement(dashboardTab), "Dashboard tab should exist")
        XCTAssertTrue(dashboardTab.isEnabled, "Dashboard tab should be enabled")
    }
    
    func testNavigateToDashboard() {
        // Given: App is launched
        let dashboardTab = app.buttons["Dashboard"]
        
        // When: Clicking Dashboard tab
        dashboardTab.tap()
        
        // Then: Dashboard view should be visible
        XCTAssertTrue(dashboardTab.isSelected, "Dashboard tab should be selected")
    }
    
    // MARK: - Dashboard Content Tests
    
    func testStorageStatsDisplayed() {
        // Given: Dashboard is active
        let dashboardTab = app.buttons["Dashboard"]
        dashboardTab.tap()
        
        // Then: Storage statistics should be visible
        let storageSection = app.staticTexts["Storage Overview"]
        XCTAssertTrue(waitForElement(storageSection, timeout: 3), "Storage overview should be displayed")
    }
    
    func testRecentActivitySection() {
        // Given: Dashboard is active
        let dashboardTab = app.buttons["Dashboard"]
        dashboardTab.tap()
        
        // Then: Recent activity section should exist
        let activitySection = app.staticTexts["Recent Activity"]
        XCTAssertTrue(waitForElement(activitySection, timeout: 3), "Recent activity section should exist")
    }
    
    func testActiveSyncsSection() {
        // Given: Dashboard is active  
        let dashboardTab = app.buttons["Dashboard"]
        dashboardTab.tap()
        
        // Then: Active syncs section should exist
        let syncsSection = app.staticTexts["Active Syncs"]
        XCTAssertTrue(waitForElement(syncsSection, timeout: 3), "Active syncs section should exist")
    }
    
    // MARK: - Dashboard Interaction Tests
    
    func testDashboardRefresh() {
        // Given: Dashboard is active
        let dashboardTab = app.buttons["Dashboard"]
        dashboardTab.tap()
        
        // When: Looking for refresh button
        let refreshButton = app.buttons["Refresh"]
        
        // Then: Refresh button should be interactive (if it exists)
        if refreshButton.exists {
            XCTAssertTrue(refreshButton.isEnabled, "Refresh button should be enabled")
            refreshButton.tap()
            
            // Wait a moment for refresh
            sleep(1)
            
            // Dashboard should still be visible
            XCTAssertTrue(dashboardTab.isSelected, "Dashboard should remain selected after refresh")
        }
    }
    
    // MARK: - Visual Regression Tests
    
    func testDashboardScreenshot() {
        // Given: Dashboard is active
        let dashboardTab = app.buttons["Dashboard"]
        dashboardTab.tap()
        
        // Wait for content to load
        sleep(2)
        
        // Then: Take screenshot for visual regression
        takeScreenshot(named: "Dashboard_Main_View")
    }
}
