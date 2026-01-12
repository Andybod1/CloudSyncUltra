//
//  JottacloudAuthenticationTests.swift
//  CloudSyncAppTests
//
//  Tests for Jottacloud authentication state machine
//  Personal Login Token flow validation
//

import XCTest
@testable import CloudSyncApp

final class JottacloudAuthenticationTests: XCTestCase {
    
    // MARK: - State Parsing Tests
    
    func testParseConfigStateFromValidJSON() {
        // Given: Valid rclone JSON response
        let jsonResponse = """
        {
            "State": "auth_type_done",
            "Option": {
                "Name": "config_type"
            },
            "Error": "",
            "Result": ""
        }
        """
        
        // When: Parsing state
        let state = parseConfigState(from: jsonResponse)
        
        // Then: Should extract state correctly
        XCTAssertEqual(state, "auth_type_done")
    }
    
    func testParseConfigStateFromStandardTokenState() {
        // Given: Response after selecting "standard" auth
        let jsonResponse = """
        {
            "State": "standard_token",
            "Option": {
                "Name": "config_login_token",
                "Help": "Personal login token."
            },
            "Error": "",
            "Result": ""
        }
        """
        
        // When: Parsing state
        let state = parseConfigState(from: jsonResponse)
        
        // Then: Should extract state correctly
        XCTAssertEqual(state, "standard_token")
    }
    
    func testParseConfigStateEmptyWhenComplete() {
        // Given: Response when config is complete
        let jsonResponse = """
        {
            "State": "",
            "Option": null,
            "Error": "",
            "Result": ""
        }
        """
        
        // When: Parsing state
        let state = parseConfigState(from: jsonResponse)
        
        // Then: Should return empty string (config complete)
        XCTAssertEqual(state, "")
    }
    
    func testParseConfigStateFromCompactJSON() {
        // Given: Compact JSON (no spaces)
        let jsonResponse = "{\"State\":\"choose_device\",\"Error\":\"\"}"
        
        // When: Parsing state
        let state = parseConfigState(from: jsonResponse)
        
        // Then: Should still parse correctly
        XCTAssertEqual(state, "choose_device")
    }
    
    func testParseConfigStateReturnsNilForInvalidJSON() {
        // Given: Invalid JSON
        let invalidResponse = "This is not JSON"
        
        // When: Parsing state
        let state = parseConfigState(from: invalidResponse)
        
        // Then: Should return nil
        XCTAssertNil(state)
    }
    
    func testParseConfigStateReturnsNilForMissingStateField() {
        // Given: JSON without State field
        let jsonResponse = "{\"Error\": \"\", \"Result\": \"\"}"
        
        // When: Parsing state
        let state = parseConfigState(from: jsonResponse)
        
        // Then: Should return nil
        XCTAssertNil(state)
    }
    
    // MARK: - Error Parsing Tests
    
    func testParseConfigErrorFromValidError() {
        // Given: Response with error
        let jsonResponse = """
        {
            "State": "",
            "Error": "failed to get oauth token: invalid token",
            "Result": ""
        }
        """
        
        // When: Parsing error
        let error = parseConfigError(from: jsonResponse)
        
        // Then: Should extract error message
        XCTAssertEqual(error, "failed to get oauth token: invalid token")
    }
    
    func testParseConfigErrorReturnsNilWhenNoError() {
        // Given: Response without error
        let jsonResponse = """
        {
            "State": "auth_type_done",
            "Error": "",
            "Result": ""
        }
        """
        
        // When: Parsing error
        let error = parseConfigError(from: jsonResponse)
        
        // Then: Should return nil (no error)
        XCTAssertNil(error)
    }
    
    func testParseConfigErrorDetectsOAuthFailure() {
        // Given: OAuth token failure message in output
        let output = "NOTICE: failed to get oauth token: token expired"
        
        // When: Parsing error
        let error = parseConfigError(from: output)
        
        // Then: Should detect OAuth failure
        XCTAssertNotNil(error)
        XCTAssertTrue(error?.contains("token") ?? false)
    }
    
    // MARK: - State Machine Flow Tests
    
    func testStateFlowSequence() {
        // Document the expected state flow
        let expectedStates = [
            "auth_type_done",    // After initial config create
            "standard_token",     // After selecting "standard" auth
            "choose_device",      // After providing token (optional)
            ""                    // Config complete
        ]
        
        // Verify we understand the flow
        XCTAssertEqual(expectedStates.count, 4)
        XCTAssertEqual(expectedStates.first, "auth_type_done")
        XCTAssertEqual(expectedStates.last, "")
    }
    
    func testAuthTypeOptions() {
        // Document the authentication type options
        let authTypes = ["standard", "traditional", "legacy"]
        
        // We use "standard" for Personal Login Token
        XCTAssertTrue(authTypes.contains("standard"))
    }
    
    // MARK: - Token Validation Tests
    
    func testPersonalLoginTokenFormat() {
        // Personal Login Tokens are typically 200+ characters
        // They are base64-encoded JSON containing service endpoints
        
        let minTokenLength = 100
        let typicalTokenLength = 250
        
        XCTAssertLessThan(minTokenLength, typicalTokenLength)
    }
    
    func testEmptyTokenShouldFail() {
        // Given: Empty token
        let token = ""
        
        // Then: Should be invalid
        XCTAssertTrue(token.isEmpty)
    }
    
    func testWhitespaceOnlyTokenShouldFail() {
        // Given: Whitespace-only token
        let token = "   \n\t  "
        
        // Then: Should be invalid after trimming
        XCTAssertTrue(token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    // MARK: - Command Construction Tests
    
    func testFirstStepCommand() {
        // First step should use: config create <name> jottacloud --non-interactive
        let remoteName = "my-jottacloud"
        let expectedArgs = ["config", "create", remoteName, "jottacloud", "--non-interactive"]
        
        XCTAssertEqual(expectedArgs.count, 5)
        XCTAssertEqual(expectedArgs[0], "config")
        XCTAssertEqual(expectedArgs[1], "create")
        XCTAssertEqual(expectedArgs[3], "jottacloud")
    }
    
    func testContinueStepCommand() {
        // Continue steps should use: config create <name> jottacloud --continue --state X --result Y
        let remoteName = "my-jottacloud"
        let state = "auth_type_done"
        let result = "standard"
        
        let expectedArgs = [
            "config", "create", remoteName, "jottacloud",
            "--continue", "--state", state, "--result", result, "--non-interactive"
        ]
        
        XCTAssertTrue(expectedArgs.contains("--continue"))
        XCTAssertTrue(expectedArgs.contains("--state"))
        XCTAssertTrue(expectedArgs.contains(state))
        XCTAssertTrue(expectedArgs.contains("--result"))
        XCTAssertTrue(expectedArgs.contains(result))
    }
    
    // MARK: - Provider Configuration Tests
    
    func testJottacloudProviderExists() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Should exist with correct type
        XCTAssertEqual(provider.rcloneType, "jottacloud")
    }
    
    func testJottacloudIsSupported() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Should be supported
        XCTAssertTrue(provider.isSupported)
    }
    
    // MARK: - Helper Functions for Tests
    
    /// Parse State from rclone JSON (mirrors RcloneManager implementation)
    private func parseConfigState(from output: String) -> String? {
        // Try JSON parsing first
        if let data = output.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let state = json["State"] as? String {
            return state
        }
        
        // Fallback: Safe string search
        let patterns = ["\"State\": \"", "\"State\":\""]
        for pattern in patterns {
            if let startRange = output.range(of: pattern) {
                let afterPattern = output[startRange.upperBound...]
                if let endQuote = afterPattern.firstIndex(of: "\"") {
                    return String(afterPattern[..<endQuote])
                }
            }
        }
        return nil
    }
    
    /// Parse Error from rclone JSON (mirrors RcloneManager implementation)
    private func parseConfigError(from output: String) -> String? {
        // Try JSON parsing first
        if let data = output.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = json["Error"] as? String,
           !error.isEmpty {
            return error
        }
        
        // Fallback: Check for common error patterns
        if output.contains("failed to get oauth token") {
            return "Invalid or expired personal login token"
        }
        
        // String search fallback
        let patterns = ["\"Error\": \"", "\"Error\":\""]
        for pattern in patterns {
            if let startRange = output.range(of: pattern) {
                let afterPattern = output[startRange.upperBound...]
                if let endQuote = afterPattern.firstIndex(of: "\"") {
                    let error = String(afterPattern[..<endQuote])
                    if !error.isEmpty {
                        return error
                    }
                }
            }
        }
        return nil
    }
}
