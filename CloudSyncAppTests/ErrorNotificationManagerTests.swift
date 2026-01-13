import XCTest
@testable import CloudSyncApp

@MainActor
final class ErrorNotificationManagerTests: XCTestCase {

    var manager: ErrorNotificationManager!

    override func setUp() {
        super.setUp()
        manager = ErrorNotificationManager()
    }

    // Test: Show error adds to active errors
    func testShowErrorAddsToActiveErrors() {
        let errorMessage = "Connection timeout"
        manager.show(errorMessage)

        XCTAssertEqual(manager.activeErrors.count, 1)
        XCTAssertEqual(manager.activeErrors[0].message, errorMessage)
    }

    // Test: Dismiss removes error
    func testDismissRemovesError() {
        let errorMessage = "Connection timeout"
        manager.show(errorMessage)

        let notificationId = manager.activeErrors[0].id
        manager.dismiss(notificationId)

        XCTAssertEqual(manager.activeErrors.count, 0)
    }

    // Test: Critical error flag
    func testCriticalErrorFlag() {
        manager.show("Critical error", isCritical: true)
        
        XCTAssertEqual(manager.activeErrors.count, 1)
        XCTAssertTrue(manager.activeErrors[0].isCritical)
    }
    
    // Test: Context is stored
    func testErrorContext() {
        manager.show("File not found", context: "document.pdf")
        
        XCTAssertEqual(manager.activeErrors.count, 1)
        XCTAssertEqual(manager.activeErrors[0].context, "document.pdf")
    }
}
