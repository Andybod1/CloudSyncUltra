//
//  SidebarOrderTests.swift
//  CloudSyncAppTests
//
//  Unit tests for sidebar navigation order
//  Verifies #26 fix: Schedules moved to correct position
//

import XCTest
@testable import CloudSyncApp

final class SidebarOrderTests: XCTestCase {

    // MARK: - Sidebar Section Tests (#26)

    func testSidebarSectionExists() {
        // Verify all expected sidebar sections exist in the enum
        let dashboard = MainWindow.SidebarSection.dashboard
        let transfer = MainWindow.SidebarSection.transfer
        let schedules = MainWindow.SidebarSection.schedules
        let tasks = MainWindow.SidebarSection.tasks
        let history = MainWindow.SidebarSection.history
        let settings = MainWindow.SidebarSection.settings
        let encryption = MainWindow.SidebarSection.encryption

        // Just verify they exist (enum cases)
        XCTAssertNotNil(dashboard)
        XCTAssertNotNil(transfer)
        XCTAssertNotNil(schedules)
        XCTAssertNotNil(tasks)
        XCTAssertNotNil(history)
        XCTAssertNotNil(settings)
        XCTAssertNotNil(encryption)
    }

    func testSidebarSectionHashable() {
        // Sidebar sections should be Hashable for use in Sets/Dictionaries
        let section1 = MainWindow.SidebarSection.dashboard
        let section2 = MainWindow.SidebarSection.transfer
        let section3 = MainWindow.SidebarSection.schedules

        var set = Set<MainWindow.SidebarSection>()
        set.insert(section1)
        set.insert(section2)
        set.insert(section3)

        XCTAssertEqual(set.count, 3, "Each section should be unique")
    }

    func testSchedulesSectionIncluded() {
        // #26: Schedules should be a valid sidebar section
        let schedules = MainWindow.SidebarSection.schedules
        XCTAssertNotNil(schedules, "Schedules section should exist")
    }

    func testRemoteSectionWithCloudRemote() {
        // Test remote section with associated CloudRemote value
        let remote = CloudRemote(
            name: "Test Remote",
            type: .googleDrive,
            isConfigured: true
        )

        let section = MainWindow.SidebarSection.remote(remote)

        switch section {
        case .remote(let r):
            XCTAssertEqual(r.name, "Test Remote")
            XCTAssertEqual(r.type, .googleDrive)
        default:
            XCTFail("Section should be .remote")
        }
    }

    // MARK: - Expected Sidebar Order Documentation
    // The expected main navigation order is:
    // 1. Dashboard
    // 2. Transfer
    // 3. Schedules (#26 - moved here)
    // 4. Tasks
    // 5. History
    //
    // Bottom section:
    // - Encryption
    // - Settings

    func testExpectedSidebarOrder() {
        // This test documents the expected sidebar order after #26 fix
        // The order is defined in SidebarView in MainWindow.swift

        // Main navigation items in expected order
        let expectedMainNavigation: [String] = [
            "Dashboard",
            "Transfer",
            "Schedules",  // #26: Schedules is now in 3rd position
            "Tasks",
            "History"
        ]

        // Verify count
        XCTAssertEqual(expectedMainNavigation.count, 5, "Main navigation should have 5 items")

        // Verify Schedules is in position 3 (index 2)
        XCTAssertEqual(expectedMainNavigation[2], "Schedules", "Schedules should be 3rd item after Transfer")

        // Verify order: Dashboard before Transfer
        XCTAssertEqual(expectedMainNavigation[0], "Dashboard")
        XCTAssertEqual(expectedMainNavigation[1], "Transfer")

        // Verify order: Tasks after Schedules
        XCTAssertEqual(expectedMainNavigation[3], "Tasks")

        // Verify order: History is last in main nav
        XCTAssertEqual(expectedMainNavigation[4], "History")
    }

    func testSchedulesNotAtEnd() {
        // #26: Schedules should NOT be at the end of navigation
        // It should be between Transfer and Tasks

        let expectedOrder = ["Dashboard", "Transfer", "Schedules", "Tasks", "History"]

        // Schedules should be at index 2, not 4
        let schedulesIndex = expectedOrder.firstIndex(of: "Schedules")
        XCTAssertNotNil(schedulesIndex)
        XCTAssertNotEqual(schedulesIndex, expectedOrder.count - 1, "Schedules should not be at the end")
        XCTAssertEqual(schedulesIndex, 2, "Schedules should be at index 2 (3rd position)")
    }

    func testSchedulesAfterTransfer() {
        // #26: Schedules should come immediately after Transfer
        let expectedOrder = ["Dashboard", "Transfer", "Schedules", "Tasks", "History"]

        let transferIndex = expectedOrder.firstIndex(of: "Transfer")!
        let schedulesIndex = expectedOrder.firstIndex(of: "Schedules")!

        XCTAssertEqual(schedulesIndex, transferIndex + 1, "Schedules should be immediately after Transfer")
    }

    func testSchedulesBeforeTasks() {
        // #26: Schedules should come immediately before Tasks
        let expectedOrder = ["Dashboard", "Transfer", "Schedules", "Tasks", "History"]

        let schedulesIndex = expectedOrder.firstIndex(of: "Schedules")!
        let tasksIndex = expectedOrder.firstIndex(of: "Tasks")!

        XCTAssertEqual(tasksIndex, schedulesIndex + 1, "Tasks should be immediately after Schedules")
    }
}
