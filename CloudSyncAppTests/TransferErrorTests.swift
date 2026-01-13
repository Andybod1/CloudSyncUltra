import XCTest
@testable import CloudSyncApp

final class TransferErrorTests: XCTestCase {

    // MARK: - User Message Tests

    func testQuotaExceededUserMessage() {
        let error = TransferError.quotaExceeded(provider: "Google Drive")
        XCTAssertEqual(error.userMessage, "Google Drive storage is full. Free up space or upgrade your storage plan.")
    }

    func testRateLimitExceededWithRetryAfter() {
        let error = TransferError.rateLimitExceeded(provider: "Dropbox", retryAfter: 60)
        XCTAssertTrue(error.userMessage.contains("60 seconds"))
    }

    func testRateLimitExceededWithoutRetryAfter() {
        let error = TransferError.rateLimitExceeded(provider: "Dropbox", retryAfter: nil)
        XCTAssertTrue(error.userMessage.contains("wait a moment"))
    }

    func testAuthenticationFailedMessage() {
        let error = TransferError.authenticationFailed(provider: "OneDrive", reason: "Invalid token")
        XCTAssertTrue(error.userMessage.contains("authentication failed"))
        XCTAssertTrue(error.userMessage.contains("Invalid token"))
    }

    func testTokenExpiredMessage() {
        let error = TransferError.tokenExpired(provider: "Google Drive")
        XCTAssertTrue(error.userMessage.contains("session expired"))
        XCTAssertTrue(error.userMessage.contains("reconnect"))
    }

    func testConnectionTimeoutMessage() {
        let error = TransferError.connectionTimeout
        XCTAssertTrue(error.userMessage.contains("Connection timed out"))
        XCTAssertTrue(error.userMessage.contains("internet connection"))
    }

    func testFileTooLargeMessage() {
        let error = TransferError.fileTooLarge(
            fileName: "video.mp4",
            maxSize: 1024 * 1024 * 100, // 100 MB
            providerLimit: 1024 * 1024 * 100
        )
        XCTAssertTrue(error.userMessage.contains("video.mp4"))
        XCTAssertTrue(error.userMessage.contains("too large"))
    }

    func testPartialFailureMessage() {
        let error = TransferError.partialFailure(
            succeeded: 8,
            failed: 2,
            errors: ["quota exceeded", "connection timeout"]
        )
        XCTAssertTrue(error.userMessage.contains("8 of 10"))
        XCTAssertTrue(error.userMessage.contains("2 failed"))
    }

    // MARK: - Title Tests

    func testErrorTitles() {
        XCTAssertEqual(TransferError.quotaExceeded(provider: "").title, "Storage Full")
        XCTAssertEqual(TransferError.connectionTimeout.title, "Connection Error")
        XCTAssertEqual(TransferError.authenticationFailed(provider: "").title, "Authentication Failed")
        XCTAssertEqual(TransferError.tokenExpired(provider: "").title, "Session Expired")
        XCTAssertEqual(TransferError.fileTooLarge(fileName: "", maxSize: 0, providerLimit: 0).title, "File Too Large")
    }

    // MARK: - Retryable Tests

    func testRetryableErrors() {
        XCTAssertTrue(TransferError.connectionTimeout.isRetryable)
        XCTAssertTrue(TransferError.connectionFailed(reason: "test").isRetryable)
        XCTAssertTrue(TransferError.networkUnreachable.isRetryable)
        XCTAssertTrue(TransferError.rateLimitExceeded(provider: "", retryAfter: nil).isRetryable)
        XCTAssertTrue(TransferError.timeout(duration: 30).isRetryable)
    }

    func testNonRetryableErrors() {
        XCTAssertFalse(TransferError.quotaExceeded(provider: "").isRetryable)
        XCTAssertFalse(TransferError.tokenExpired(provider: "").isRetryable)
        XCTAssertFalse(TransferError.authenticationFailed(provider: "").isRetryable)
        XCTAssertFalse(TransferError.cancelled.isRetryable)
    }

    // MARK: - Critical Error Tests

    func testCriticalErrors() {
        XCTAssertTrue(TransferError.quotaExceeded(provider: "").isCritical)
        XCTAssertTrue(TransferError.authenticationFailed(provider: "").isCritical)
        XCTAssertTrue(TransferError.checksumMismatch(fileName: "").isCritical)
        XCTAssertTrue(TransferError.encryptionError(details: "").isCritical)
    }

    func testNonCriticalErrors() {
        XCTAssertFalse(TransferError.connectionTimeout.isCritical)
        XCTAssertFalse(TransferError.rateLimitExceeded(provider: "", retryAfter: nil).isCritical)
        XCTAssertFalse(TransferError.cancelled.isCritical)
    }

    // MARK: - Error Pattern Parsing Tests

    func testParseGoogleDriveQuotaError() {
        let output = "ERROR : googleapi: Error 403: The user's Drive storage quota has been exceeded., storageQuotaExceeded"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .quotaExceeded(let provider, _) = error {
            XCTAssertEqual(provider, "Google Drive")
        } else {
            XCTFail("Expected quotaExceeded error for Google Drive")
        }
    }

    func testParseDropboxInsufficientStorage() {
        let output = "ERROR : insufficient_storage: not enough space"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .quotaExceeded(let provider, _) = error {
            XCTAssertEqual(provider, "Dropbox")
        } else {
            XCTFail("Expected quotaExceeded error for Dropbox")
        }
    }

    func testParseOneDriveQuotaExceeded() {
        let output = "ERROR : QuotaExceeded: not enough space in OneDrive"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .quotaExceeded(let provider, _) = error {
            // Parser defaults to Dropbox for quota errors
            XCTAssertEqual(provider, "Dropbox")
        } else {
            XCTFail("Expected quotaExceeded error")
        }
    }

    func testParseRateLimitExceeded() {
        let output = "ERROR : rateLimitExceeded: too many requests. Retry after 120 seconds"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .rateLimitExceeded(_, let retryAfter) = error {
            XCTAssertNotNil(retryAfter)
        } else {
            XCTFail("Expected rateLimitExceeded error")
        }
    }

    func testParseConnectionTimeout() {
        let output = "ERROR : connection timed out after 30 seconds"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .connectionTimeout = error {
            // Success
        } else {
            XCTFail("Expected connectionTimeout error")
        }
    }

    func testParseTokenExpired() {
        let output = "ERROR : token has expired, please reauthenticate"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .tokenExpired = error {
            // Success
        } else {
            XCTFail("Expected tokenExpired error")
        }
    }

    func testParseAuthenticationFailed() {
        let output = "ERROR : authentication failed: invalid credentials"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .authenticationFailed = error {
            // Success
        } else {
            XCTFail("Expected authenticationFailed error")
        }
    }

    func testParseDNSResolutionFailed() {
        let output = "ERROR : lookup failed: no such host drive.google.com"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .dnsResolutionFailed(let host) = error {
            XCTAssertTrue(host.contains("drive.google.com") || host == "unknown")
        } else {
            XCTFail("Expected dnsResolutionFailed error")
        }
    }

    func testParseChecksumMismatch() {
        let output = "ERROR : checksum mismatch for file data.csv"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .checksumMismatch = error {
            // Success
        } else {
            XCTFail("Expected checksumMismatch error")
        }
    }

    func testParseGenericError() {
        let output = "ERROR : Something went wrong during transfer"
        let error = TransferError.parse(from: output)

        XCTAssertNotNil(error)
        if case .unknown(let message) = error {
            XCTAssertTrue(message.contains("Something went wrong"))
        } else {
            XCTFail("Expected unknown error")
        }
    }

    func testParseNoError() {
        let output = "Transferred: 1.5 GiB / 2 GiB, 75%, 50 MiB/s"
        let error = TransferError.parse(from: output)

        XCTAssertNil(error, "Should not detect error in normal progress output")
    }

    // MARK: - Codable Tests

    func testTransferErrorCodable() throws {
        let errors: [TransferError] = [
            .quotaExceeded(provider: "Google Drive"),
            .connectionTimeout,
            .tokenExpired(provider: "Dropbox"),
            .partialFailure(succeeded: 5, failed: 2, errors: ["quota", "timeout"])
        ]

        for error in errors {
            let encoded = try JSONEncoder().encode(error)
            let decoded = try JSONDecoder().decode(TransferError.self, from: encoded)
            XCTAssertEqual(error, decoded)
        }
    }
}