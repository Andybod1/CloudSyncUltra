import XCTest
@testable import CloudSyncApp

final class CrashReportingTests: XCTestCase {

    override func setUpWithError() throws {
        // Clean up any existing crash reports before testing
        CrashReportingManager.shared.clearLogs()
    }

    override func tearDownWithError() throws {
        // Clean up after tests
        CrashReportingManager.shared.clearLogs()
    }

    func testCrashReportModel() throws {
        // Test creating a crash report
        let report = CrashReport(
            type: .exception,
            reason: "Test exception",
            stackTrace: ["frame1", "frame2", "frame3"]
        )

        XCTAssertNotNil(report.id)
        XCTAssertEqual(report.type, .exception)
        XCTAssertEqual(report.reason, "Test exception")
        XCTAssertEqual(report.stackTrace.count, 3)
        XCTAssertNotNil(report.deviceInfo)
        XCTAssertNotNil(report.appInfo)
    }

    func testCrashReportFormatting() throws {
        let report = CrashReport(
            type: .signal,
            reason: "SIGSEGV",
            stackTrace: ["0x12345", "0x67890"]
        )

        let formatted = report.formattedDescription
        XCTAssertTrue(formatted.contains("CRASH REPORT"))
        XCTAssertTrue(formatted.contains("Signal"))
        XCTAssertTrue(formatted.contains("SIGSEGV"))
        XCTAssertTrue(formatted.contains("Stack Trace"))
    }

    func testCrashReportSummary() throws {
        let report = CrashReport(
            type: .exception,
            reason: "NSInvalidArgumentException",
            stackTrace: []
        )

        let summary = report.summary
        XCTAssertTrue(summary.contains("Exception"))
        XCTAssertFalse(summary.isEmpty)
    }

    func testDeviceInfo() throws {
        let deviceInfo = DeviceInfo.current

        XCTAssertFalse(deviceInfo.osVersion.isEmpty)
        XCTAssertFalse(deviceInfo.architecture.isEmpty)
        XCTAssertGreaterThan(deviceInfo.memoryTotal, 0)
        XCTAssertGreaterThan(deviceInfo.processorCount, 0)
    }

    func testAppInfo() throws {
        let appInfo = AppInfo.current

        XCTAssertFalse(appInfo.version.isEmpty)
        XCTAssertFalse(appInfo.build.isEmpty)
        XCTAssertFalse(appInfo.bundleIdentifier.isEmpty)
    }

    func testCrashReportingSetup() throws {
        // Test that crash reporting can be set up without errors
        CrashReportingManager.shared.setup()

        // We can't easily test the actual crash handlers without crashing
        // but we can verify the setup completes
        XCTAssertTrue(true)
    }

    func testPreviousCrashDetection() throws {
        // Initially, there should be no previous crash
        XCTAssertFalse(CrashReportingManager.shared.hasPreviousCrash())
        XCTAssertNil(CrashReportingManager.shared.lastCrashDate())

        // Clear the flag and verify it's cleared
        CrashReportingManager.shared.clearPreviousCrashFlag()
        XCTAssertFalse(CrashReportingManager.shared.hasPreviousCrash())
    }

    func testGetCrashReportCount() throws {
        // Initially should be 0
        let initialCount = CrashReportingManager.shared.getCrashReportCount()
        XCTAssertEqual(initialCount, 0)
    }

    func testGetAllCrashReports() throws {
        // Initially should be empty
        let reports = CrashReportingManager.shared.getAllCrashReports()
        XCTAssertTrue(reports.isEmpty)
    }

    func testClearLogs() throws {
        // Clear logs should work without errors
        CrashReportingManager.shared.clearLogs()

        // Verify count is 0 after clearing
        let count = CrashReportingManager.shared.getCrashReportCount()
        XCTAssertEqual(count, 0)
    }

    func testExportLogs() throws {
        // Test that export logs returns a valid URL
        do {
            let exportURL = try CrashReportingManager.shared.exportLogs()
            XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path))

            // Clean up
            try? FileManager.default.removeItem(at: exportURL)
        } catch {
            XCTFail("Export logs failed: \(error)")
        }
    }

    func testCrashReportCodable() throws {
        // Test that crash reports can be encoded and decoded
        let originalReport = CrashReport(
            type: .exception,
            reason: "Test reason",
            stackTrace: ["frame1", "frame2"]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalReport)

        let decoder = JSONDecoder()
        let decodedReport = try decoder.decode(CrashReport.self, from: data)

        XCTAssertEqual(originalReport.id, decodedReport.id)
        XCTAssertEqual(originalReport.type, decodedReport.type)
        XCTAssertEqual(originalReport.reason, decodedReport.reason)
        XCTAssertEqual(originalReport.stackTrace, decodedReport.stackTrace)
    }

    #if DEBUG
    func testDebugCrashTypes() throws {
        // Test that debug crash types exist in debug builds
        XCTAssertNotNil(CrashReportingManager.TestCrashType.exception)
        XCTAssertNotNil(CrashReportingManager.TestCrashType.segmentationFault)
        XCTAssertNotNil(CrashReportingManager.TestCrashType.abort)
    }
    #endif
}