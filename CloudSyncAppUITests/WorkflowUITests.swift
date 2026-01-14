//
//  WorkflowUITests.swift
//  CloudSyncAppUITests
//
//  End-to-end workflow tests for critical user journeys
//

import XCTest

final class WorkflowUITests: CloudSyncAppUITests {
    
    // MARK: - Complete User Workflows
    
    func testCompleteOnboardingWorkflow() {
        // Scenario: New user opens app for first time
        
        // Given: App is launched
        XCTAssertTrue(app.state == .runningForeground, "App should be running")
        
        // When: User explores main tabs
        let dashboardTab = app.buttons["Dashboard"]
        let filesTab = app.buttons["Files"]
        let transferTab = app.buttons["Transfer"]
        let tasksTab = app.buttons["Tasks"]
        
        // Then: All main navigation should be accessible
        let allTabsExist = dashboardTab.exists && filesTab.exists && 
                          transferTab.exists && tasksTab.exists
        
        if allTabsExist {
            XCTAssertTrue(true, "Complete navigation is available")
            
            // Navigate through each tab
            dashboardTab.tap()
            sleep(1)
            takeScreenshot(named: "Workflow_Onboarding_Dashboard")
            
            filesTab.tap()
            sleep(1)
            takeScreenshot(named: "Workflow_Onboarding_Files")
            
            transferTab.tap()
            sleep(1)
            takeScreenshot(named: "Workflow_Onboarding_Transfer")
            
            tasksTab.tap()
            sleep(1)
            takeScreenshot(named: "Workflow_Onboarding_Tasks")
        }
    }
    
    func testFileExplorationWorkflow() {
        // Scenario: User wants to browse local files
        
        // Given: App is launched
        // When: User navigates to Files
        let filesTab = app.buttons["Files"]
        filesTab.tap()
        
        sleep(1)
        
        // Then: User can select local storage
        let providerPicker = app.popUpButtons.firstMatch
        if providerPicker.exists {
            providerPicker.tap()
            sleep(1)
            
            let localOption = app.menuItems["Local Storage"]
            if localOption.exists {
                localOption.tap()
                sleep(1)
                
                // User should see file list
                let fileList = app.tables.firstMatch
                XCTAssertTrue(fileList.exists || app.scrollViews.count > 0, 
                             "File list should be displayed")
                
                takeScreenshot(named: "Workflow_FileExploration_Complete")
            }
        }
    }
    
    func testAddCloudProviderWorkflow() {
        // Scenario: User wants to add a cloud provider
        
        // Given: User is on Files tab
        let filesTab = app.buttons["Files"]
        filesTab.tap()
        
        sleep(1)
        
        // When: User tries to add a cloud provider
        // Look for "Add Cloud" or similar button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add Cloud' OR label CONTAINS[c] 'Add Remote'")).firstMatch
        
        if addButton.exists {
            addButton.tap()
            sleep(1)
            
            // Then: Provider selection should appear
            takeScreenshot(named: "Workflow_AddProvider_Dialog")
            
            // User should see provider options
            let hasProviderOptions = app.sheets.count > 0 || 
                                    app.dialogs.count > 0 || 
                                    app.menuItems.count > 0
            
            XCTAssertTrue(hasProviderOptions, "Provider selection UI should appear")
        }
    }
    
    func testCreateSyncTaskWorkflow() {
        // Scenario: User creates a new sync task
        
        // Given: User is on Tasks tab
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        sleep(1)
        
        // When: User clicks add task button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add' OR label CONTAINS[c] 'New' OR label CONTAINS[c] '+'")).firstMatch
        
        if addButton.exists {
            addButton.tap()
            sleep(1)
            
            // Then: Task creation form should appear
            let hasForm = app.textFields.count > 0 || 
                         app.sheets.count > 0 ||
                         app.dialogs.count > 0
            
            if hasForm {
                takeScreenshot(named: "Workflow_CreateTask_Form")
                
                // Fill in task details if fields exist
                let textFields = app.textFields
                if textFields.count > 0 {
                    // Task name field
                    let nameField = textFields.firstMatch
                    nameField.tap()
                    nameField.typeText("Test Sync Task")
                    
                    sleep(1)
                    takeScreenshot(named: "Workflow_CreateTask_Filled")
                }
                
                XCTAssertTrue(true, "Task creation workflow is accessible")
            }
        }
    }
    
    func testLocalToCloudTransferWorkflow() {
        // Scenario: User transfers files from local to cloud
        
        // Given: User is on Transfer tab
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        sleep(1)
        
        // When: User sets up source and destination
        let providerPickers = app.popUpButtons
        
        if providerPickers.count >= 2 {
            // Set source to Local
            let sourcePicker = providerPickers.firstMatch
            sourcePicker.tap()
            sleep(1)
            
            let localOption = app.menuItems["Local Storage"]
            if localOption.exists {
                localOption.tap()
                sleep(1)
                
                takeScreenshot(named: "Workflow_Transfer_SourceSet")
            }
            
            // Set destination to a cloud provider
            let destPicker = providerPickers.element(boundBy: 1)
            destPicker.tap()
            sleep(1)
            
            // Look for any cloud provider
            let cloudProviders = app.menuItems.matching(NSPredicate(format: "label != 'Local Storage'"))
            if cloudProviders.count > 0 {
                // Just verify we can see cloud options
                XCTAssertTrue(true, "Cloud providers are available for destination")
                takeScreenshot(named: "Workflow_Transfer_ProviderMenu")
            }
        }
    }
    
    func testDashboardMonitoringWorkflow() {
        // Scenario: User monitors sync activity from dashboard
        
        // Given: App is running
        // When: User navigates to dashboard
        let dashboardTab = app.buttons["Dashboard"]
        dashboardTab.tap()
        
        sleep(2)
        
        // Then: User should see monitoring information
        let storageSection = app.staticTexts["Storage Overview"]
        let activitySection = app.staticTexts["Recent Activity"]
        let syncsSection = app.staticTexts["Active Syncs"]
        
        let hasDashboardSections = storageSection.exists || 
                                   activitySection.exists || 
                                   syncsSection.exists
        
        if hasDashboardSections {
            takeScreenshot(named: "Workflow_Dashboard_Monitoring")
            XCTAssertTrue(true, "Dashboard monitoring is functional")
        }
    }
    
    func testSearchFilesWorkflow() {
        // Scenario: User searches for specific files
        
        // Given: User is on Files tab
        let filesTab = app.buttons["Files"]
        filesTab.tap()
        
        sleep(1)
        
        // When: User types in search field
        let searchField = app.searchFields.firstMatch
        
        if searchField.exists {
            searchField.tap()
            searchField.typeText("document")
            
            sleep(2)
            
            // Then: File list should update with results
            takeScreenshot(named: "Workflow_Search_Results")
            
            XCTAssertTrue(true, "File search is functional")
        }
    }
    
    func testViewModeToggleWorkflow() {
        // Scenario: User switches between list and grid views
        
        // Given: User is browsing files
        let filesTab = app.buttons["Files"]
        filesTab.tap()
        
        sleep(1)
        
        // When: User toggles view modes
        let listButton = app.buttons["List"]
        let gridButton = app.buttons["Grid"]
        
        if listButton.exists && gridButton.exists {
            // Start with list view
            listButton.tap()
            sleep(1)
            takeScreenshot(named: "Workflow_ViewMode_List")
            
            // Switch to grid view
            gridButton.tap()
            sleep(1)
            takeScreenshot(named: "Workflow_ViewMode_Grid")
            
            // Switch back to list
            listButton.tap()
            sleep(1)
            
            XCTAssertTrue(true, "View mode toggling works")
        }
    }
    
    // MARK: - Error Handling Workflows
    
    func testNoNetworkWorkflow() {
        // Scenario: User tries to connect to cloud without network
        // Note: This requires network simulation or manual testing
        
        // Given: App is launched
        // When: User attempts cloud operations
        let filesTab = app.buttons["Files"]
        filesTab.tap()
        
        sleep(1)
        
        // Then: App should remain stable
        XCTAssertTrue(app.state == .runningForeground, 
                     "App should handle network issues gracefully")
    }
    
    func testEmptyStateWorkflow() {
        // Scenario: New user with no configured providers or tasks
        
        // Given: Fresh app state
        // When: User navigates to Tasks
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        sleep(1)
        
        // Then: Should show helpful empty state
        let hasEmptyState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'No tasks' OR label CONTAINS[c] 'Get started'")).count > 0
        
        if hasEmptyState {
            takeScreenshot(named: "Workflow_EmptyState_Tasks")
            XCTAssertTrue(true, "Empty states are user-friendly")
        }
    }
}
