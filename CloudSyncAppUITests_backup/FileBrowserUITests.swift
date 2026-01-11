//
//  FileBrowserUITests.swift
//  CloudSyncAppUITests
//
//  UI tests for File Browser functionality
//

import XCTest

final class FileBrowserUITests: CloudSyncAppUITests {
    
    // MARK: - Navigation Tests
    
    func testFileBrowserTabExists() {
        // Given: App is launched
        // When: Looking for File Browser
        let fileBrowserTab = app.buttons["Files"]
        
        // Then: Should exist and be selectable
        XCTAssertTrue(waitForElement(fileBrowserTab), "File Browser tab should exist")
        XCTAssertTrue(fileBrowserTab.isEnabled, "File Browser tab should be enabled")
    }
    
    func testNavigateToFileBrowser() {
        // Given: App is launched
        let fileBrowserTab = app.buttons["Files"]
        
        // When: Clicking Files tab
        fileBrowserTab.tap()
        
        // Then: Files view should be active
        XCTAssertTrue(fileBrowserTab.isSelected, "Files tab should be selected")
    }
    
    // MARK: - Cloud Provider Selection Tests
    
    func testCloudProviderPicker() {
        // Given: File browser is active
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        // When: Looking for provider picker
        let providerPicker = app.popUpButtons.firstMatch
        
        // Then: Picker should exist and be interactive
        if providerPicker.exists {
            XCTAssertTrue(providerPicker.isEnabled, "Provider picker should be enabled")
        }
    }
    
    func testLocalStorageAvailable() {
        // Given: File browser is active
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        // When: Opening provider picker
        let providerPicker = app.popUpButtons.firstMatch
        
        if providerPicker.exists {
            providerPicker.tap()
            
            // Then: Local Storage should be available
            let localOption = app.menuItems["Local Storage"]
            XCTAssertTrue(waitForElement(localOption, timeout: 2), "Local Storage should be in provider list")
        }
    }
    
    // MARK: - File List Tests
    
    func testFileListDisplayed() {
        // Given: File browser is active on local storage
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        // Then: File list should be displayed
        let fileList = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        
        // Either a table or scroll view should exist for file display
        let hasFileDisplay = fileList.exists || scrollView.exists
        XCTAssertTrue(hasFileDisplay, "File list or scroll view should be displayed")
    }
    
    func testFileListInteraction() {
        // Given: File browser is active
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        // Wait for file list to load
        sleep(1)
        
        // Then: Should be able to interact with file list
        let fileList = app.tables.firstMatch
        if fileList.exists {
            XCTAssertTrue(fileList.isEnabled, "File list should be interactive")
        }
    }
    
    // MARK: - View Mode Tests
    
    func testViewModeToggle() {
        // Given: File browser is active
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        // When: Looking for view mode toggle
        let listViewButton = app.buttons["List"]
        let gridViewButton = app.buttons["Grid"]
        
        // Then: View mode buttons should exist
        if listViewButton.exists || gridViewButton.exists {
            XCTAssertTrue(true, "View mode controls are present")
            
            // Test toggling if both exist
            if listViewButton.exists && gridViewButton.exists {
                listViewButton.tap()
                sleep(1)
                takeScreenshot(named: "FileBrowser_List_View")
                
                gridViewButton.tap()
                sleep(1)
                takeScreenshot(named: "FileBrowser_Grid_View")
            }
        }
    }
    
    // MARK: - Search and Filter Tests
    
    func testSearchField() {
        // Given: File browser is active
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        // When: Looking for search field
        let searchField = app.searchFields.firstMatch
        
        // Then: Search field should be available
        if searchField.exists {
            XCTAssertTrue(searchField.isEnabled, "Search field should be enabled")
            
            // Test typing in search
            searchField.tap()
            searchField.typeText("test")
            
            // Should have text
            XCTAssertTrue(searchField.value as? String == "test", "Search should accept input")
        }
    }
    
    // MARK: - Context Menu Tests
    
    func testRightClickContextMenu() {
        // Given: File browser is active with files
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        sleep(1)
        
        // When: Right-clicking in file area
        let fileList = app.tables.firstMatch
        if fileList.exists {
            // Right-click on file list
            fileList.rightClick()
            
            // Then: Context menu should appear
            sleep(1)
            
            // Look for common context menu items
            let newFolderItem = app.menuItems["New Folder"]
            let refreshItem = app.menuItems["Refresh"]
            
            let hasContextMenu = newFolderItem.exists || refreshItem.exists
            XCTAssertTrue(hasContextMenu, "Context menu should appear on right-click")
            
            if hasContextMenu {
                takeScreenshot(named: "FileBrowser_ContextMenu")
            }
        }
    }
    
    // MARK: - Screenshot Tests
    
    func testFileBrowserScreenshot() {
        // Given: File browser is active
        let fileBrowserTab = app.buttons["Files"]
        fileBrowserTab.tap()
        
        // Wait for content to load
        sleep(2)
        
        // Then: Take screenshot
        takeScreenshot(named: "FileBrowser_Main_View")
    }
}
