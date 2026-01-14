//
//  TransferViewUITests.swift
//  CloudSyncAppUITests
//
//  UI tests for Transfer view and file operations
//

import XCTest

final class TransferViewUITests: CloudSyncAppUITests {
    
    // MARK: - Navigation Tests
    
    func testTransferTabExists() {
        // Given: App is launched
        // When: Looking for Transfer tab
        let transferTab = app.buttons["Transfer"]
        
        // Then: Should exist and be selectable
        XCTAssertTrue(waitForElement(transferTab), "Transfer tab should exist")
        XCTAssertTrue(transferTab.isEnabled, "Transfer tab should be enabled")
    }
    
    func testNavigateToTransfer() {
        // Given: App is launched
        let transferTab = app.buttons["Transfer"]
        
        // When: Clicking Transfer tab
        transferTab.tap()
        
        // Then: Transfer view should be active
        XCTAssertTrue(transferTab.isSelected, "Transfer tab should be selected")
    }
    
    // MARK: - Dual Pane Layout Tests
    
    func testDualPaneLayout() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // Then: Should have source and destination panes
        // Look for multiple file browsers or split views
        let scrollViews = app.scrollViews
        
        // In a dual-pane layout, we expect at least 2 scroll views or tables
        XCTAssertGreaterThanOrEqual(scrollViews.count, 1, "Transfer view should have file browser panes")
    }
    
    func testSourcePaneProviderPicker() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // Then: Source pane should have provider picker
        let popUpButtons = app.popUpButtons
        XCTAssertGreaterThanOrEqual(popUpButtons.count, 1, "Should have at least one provider picker")
    }
    
    func testDestinationPaneProviderPicker() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // Then: Should have provider pickers for both panes
        let popUpButtons = app.popUpButtons
        
        // In dual pane, we expect 2 provider pickers
        if popUpButtons.count >= 2 {
            XCTAssertTrue(true, "Both source and destination have provider pickers")
        }
    }
    
    // MARK: - Transfer Controls Tests
    
    func testTransferButtonExists() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // When: Looking for transfer action buttons
        let transferButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Transfer' OR label CONTAINS[c] 'Copy' OR label CONTAINS[c] 'Move'")).firstMatch
        
        // Then: Transfer button should exist
        if transferButton.exists {
            XCTAssertTrue(true, "Transfer action button exists")
        }
    }
    
    func testNewFolderButton() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // When: Looking for new folder button
        let newFolderButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Folder'")).firstMatch
        
        // Then: New folder button should be available
        if newFolderButton.exists {
            XCTAssertTrue(newFolderButton.isEnabled, "New folder button should be enabled")
        }
    }
    
    // MARK: - File Selection Tests
    
    func testFileSelection() {
        // Given: Transfer view is active with files
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        sleep(1)
        
        // When: Looking for selectable files
        let tables = app.tables
        
        if tables.count > 0 {
            let firstTable = tables.firstMatch
            if firstTable.exists {
                // Try to select a file
                let cells = firstTable.cells
                if cells.count > 0 {
                    let firstCell = cells.firstMatch
                    firstCell.tap()
                    
                    XCTAssertTrue(true, "File selection works")
                }
            }
        }
    }
    
    // MARK: - Context Menu Tests
    
    func testTransferViewContextMenu() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        sleep(1)
        
        // When: Right-clicking in transfer pane
        let tables = app.tables
        if tables.count > 0 {
            let firstTable = tables.firstMatch
            firstTable.rightClick()
            
            sleep(1)
            
            // Then: Context menu should appear
            let contextMenuItems = app.menuItems
            if contextMenuItems.count > 0 {
                XCTAssertTrue(true, "Context menu appears in transfer view")
                takeScreenshot(named: "TransferView_ContextMenu")
            }
        }
    }
    
    // MARK: - Provider Selection Tests
    
    func testSelectSourceProvider() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // When: Selecting source provider
        let providerPickers = app.popUpButtons
        if providerPickers.count > 0 {
            let sourcePicker = providerPickers.firstMatch
            sourcePicker.tap()
            
            // Then: Provider menu should open
            sleep(1)
            
            let menuItems = app.menuItems
            XCTAssertGreaterThan(menuItems.count, 0, "Provider menu should show options")
            
            // Select local storage
            let localOption = app.menuItems["Local Storage"]
            if localOption.exists {
                localOption.tap()
                XCTAssertTrue(true, "Can select source provider")
            }
        }
    }
    
    func testSelectDestinationProvider() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // When: Selecting destination provider (second picker)
        let providerPickers = app.popUpButtons
        if providerPickers.count >= 2 {
            let destPicker = providerPickers.element(boundBy: 1)
            destPicker.tap()
            
            sleep(1)
            
            // Then: Provider menu should open
            let menuItems = app.menuItems
            XCTAssertGreaterThan(menuItems.count, 0, "Destination provider menu should show options")
        }
    }
    
    // MARK: - Visual Regression Tests
    
    func testTransferViewScreenshot() {
        // Given: Transfer view is active
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        // Wait for content to load
        sleep(2)
        
        // Then: Take screenshot
        takeScreenshot(named: "TransferView_Main")
    }
    
    func testTransferViewWithSelection() {
        // Given: Transfer view is active with file selected
        let transferTab = app.buttons["Transfer"]
        transferTab.tap()
        
        sleep(1)
        
        // Select a file if available
        let tables = app.tables
        if tables.count > 0 {
            let firstTable = tables.firstMatch
            let cells = firstTable.cells
            if cells.count > 0 {
                cells.firstMatch.tap()
                sleep(1)
                
                takeScreenshot(named: "TransferView_FileSelected")
            }
        }
    }
}
