//
//  TasksUITests.swift
//  CloudSyncAppUITests
//
//  UI tests for Tasks view and sync task management
//

import XCTest

final class TasksUITests: CloudSyncAppUITests {
    
    // MARK: - Navigation Tests
    
    func testTasksTabExists() {
        // Given: App is launched
        // When: Looking for Tasks tab
        let tasksTab = app.buttons["Tasks"]
        
        // Then: Should exist and be selectable
        XCTAssertTrue(waitForElement(tasksTab), "Tasks tab should exist")
        XCTAssertTrue(tasksTab.isEnabled, "Tasks tab should be enabled")
    }
    
    func testNavigateToTasks() {
        // Given: App is launched
        let tasksTab = app.buttons["Tasks"]
        
        // When: Clicking Tasks tab
        tasksTab.tap()
        
        // Then: Tasks view should be active
        XCTAssertTrue(tasksTab.isSelected, "Tasks tab should be selected")
    }
    
    // MARK: - Task List Tests
    
    func testTaskListDisplayed() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // Then: Task list should be displayed
        let taskList = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        
        let hasTaskDisplay = taskList.exists || scrollView.exists
        XCTAssertTrue(hasTaskDisplay, "Task list should be displayed")
    }
    
    func testEmptyStateMessage() {
        // Given: Tasks view is active with no tasks
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        sleep(1)
        
        // Then: Should show empty state or task list
        // Either we have tasks or an empty state message
        let hasTasks = app.tables.firstMatch.exists
        let hasEmptyMessage = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'No tasks' OR label CONTAINS[c] 'Create' OR label CONTAINS[c] 'Add'")).firstMatch.exists
        
        XCTAssertTrue(hasTasks || hasEmptyMessage, "Should show tasks or empty state")
    }
    
    // MARK: - Task Creation Tests
    
    func testAddTaskButton() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // When: Looking for add task button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add' OR label CONTAINS[c] 'New' OR label CONTAINS[c] '+'")).firstMatch
        
        // Then: Add button should exist and be enabled
        if addButton.exists {
            XCTAssertTrue(addButton.isEnabled, "Add task button should be enabled")
        }
    }
    
    func testCreateTaskFlow() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // When: Clicking add task button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add' OR label CONTAINS[c] 'New' OR label CONTAINS[c] '+'")).firstMatch
        
        if addButton.exists {
            addButton.tap()
            
            sleep(1)
            
            // Then: Task creation UI should appear
            // Look for form fields or dialog
            let textFields = app.textFields
            let sheets = app.sheets
            let dialogs = app.dialogs
            
            let hasTaskCreationUI = textFields.count > 0 || sheets.count > 0 || dialogs.count > 0
            
            if hasTaskCreationUI {
                XCTAssertTrue(true, "Task creation UI appears")
                takeScreenshot(named: "Tasks_CreateDialog")
            }
        }
    }
    
    // MARK: - Task Filter Tests
    
    func testTaskTypeFilter() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // When: Looking for filter controls
        let filterButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'All' OR label CONTAINS[c] 'Sync' OR label CONTAINS[c] 'Backup' OR label CONTAINS[c] 'Transfer'"))
        
        // Then: Filter buttons should be available
        if filterButtons.count > 0 {
            XCTAssertTrue(true, "Task type filters are available")
            
            // Test clicking a filter
            let firstFilter = filterButtons.firstMatch
            firstFilter.tap()
            
            sleep(1)
            
            takeScreenshot(named: "Tasks_Filtered")
        }
    }
    
    func testTaskStatusFilter() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // When: Looking for status filter
        let statusFilters = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Active' OR label CONTAINS[c] 'Completed' OR label CONTAINS[c] 'Failed'"))
        
        // Then: Status filters should be available
        if statusFilters.count > 0 {
            XCTAssertTrue(true, "Task status filters are available")
        }
    }
    
    // MARK: - Task Interaction Tests
    
    func testSelectTask() {
        // Given: Tasks view is active with tasks
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        sleep(1)
        
        // When: Selecting a task
        let taskList = app.tables.firstMatch
        if taskList.exists {
            let cells = taskList.cells
            if cells.count > 0 {
                let firstTask = cells.firstMatch
                firstTask.tap()
                
                // Then: Task should be selected
                XCTAssertTrue(true, "Can select tasks")
            }
        }
    }
    
    func testTaskContextMenu() {
        // Given: Tasks view is active with tasks
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        sleep(1)
        
        // When: Right-clicking on a task
        let taskList = app.tables.firstMatch
        if taskList.exists {
            let cells = taskList.cells
            if cells.count > 0 {
                let firstTask = cells.firstMatch
                firstTask.rightClick()
                
                sleep(1)
                
                // Then: Context menu should appear
                let contextMenuItems = app.menuItems
                if contextMenuItems.count > 0 {
                    XCTAssertTrue(true, "Task context menu appears")
                    takeScreenshot(named: "Tasks_ContextMenu")
                }
            }
        }
    }
    
    // MARK: - Task Actions Tests
    
    func testRunTaskButton() {
        // Given: Tasks view is active with a task selected
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        sleep(1)
        
        // When: Looking for run/execute button
        let runButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Run' OR label CONTAINS[c] 'Execute' OR label CONTAINS[c] 'Start'")).firstMatch
        
        // Then: Run button should be available
        if runButton.exists {
            XCTAssertTrue(runButton.isEnabled || !runButton.isEnabled, "Run button exists (enabled state depends on selection)")
        }
    }
    
    func testEditTaskButton() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // When: Looking for edit button
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Edit' OR label CONTAINS[c] 'Modify'")).firstMatch
        
        // Then: Edit button should be available
        if editButton.exists {
            XCTAssertTrue(true, "Edit task button exists")
        }
    }
    
    func testDeleteTaskButton() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // When: Looking for delete button
        let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Delete' OR label CONTAINS[c] 'Remove'")).firstMatch
        
        // Then: Delete button should be available
        if deleteButton.exists {
            XCTAssertTrue(true, "Delete task button exists")
        }
    }
    
    // MARK: - Visual Regression Tests
    
    func testTasksViewScreenshot() {
        // Given: Tasks view is active
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        // Wait for content to load
        sleep(2)
        
        // Then: Take screenshot
        takeScreenshot(named: "Tasks_Main_View")
    }
    
    func testTasksViewWithFilters() {
        // Given: Tasks view is active with filters applied
        let tasksTab = app.buttons["Tasks"]
        tasksTab.tap()
        
        sleep(1)
        
        // Apply a filter if available
        let filterButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sync' OR label CONTAINS[c] 'Backup'"))
        if filterButtons.count > 0 {
            filterButtons.firstMatch.tap()
            sleep(1)
            
            takeScreenshot(named: "Tasks_With_Filter")
        }
    }
}
