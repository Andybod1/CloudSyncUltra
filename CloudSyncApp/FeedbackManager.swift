//
//  FeedbackManager.swift
//  CloudSyncApp
//
//  Manages user feedback submission via GitHub issues
//  Issue #97: In-App Feedback Manager
//

import Foundation
import os

/// Result of a feedback submission attempt
enum FeedbackSubmissionResult {
    case success(issueURL: String)
    case failure(error: FeedbackError)
}

/// Errors that can occur during feedback submission
enum FeedbackError: LocalizedError {
    case ghNotInstalled
    case notAuthenticated
    case submissionFailed(String)
    case invalidInput(String)

    var errorDescription: String? {
        switch self {
        case .ghNotInstalled:
            return "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com"
        case .notAuthenticated:
            return "Not authenticated with GitHub. Please run 'gh auth login' in Terminal."
        case .submissionFailed(let message):
            return "Failed to submit feedback: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        }
    }
}

/// System information for feedback reports
struct SystemInfo {
    let macOSVersion: String
    let appVersion: String
    let connectedProviders: Int

    /// Formatted string for inclusion in GitHub issue body
    var formattedString: String {
        return """

        ---
        **System Info:**
        - macOS: \(macOSVersion)
        - App Version: \(appVersion)
        - Connected Providers: \(connectedProviders)
        """
    }
}

/// Manages user feedback submission to GitHub via the gh CLI
@MainActor
final class FeedbackManager: ObservableObject {

    // MARK: - Singleton

    static let shared = FeedbackManager()

    // MARK: - Properties

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "feedback")

    /// The GitHub repository to create issues in
    private let repository = "Andybod1/CloudSyncUltra"

    /// Whether a submission is currently in progress
    @Published private(set) var isSubmitting = false

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Submit feedback to GitHub as an issue
    /// - Parameters:
    ///   - category: The type of feedback (bug, feature, feedback)
    ///   - title: The issue title
    ///   - description: The detailed description
    ///   - includeSystemInfo: Whether to append system info to the description
    /// - Returns: The result of the submission attempt
    func submitFeedback(
        category: FeedbackCategory,
        title: String,
        description: String,
        includeSystemInfo: Bool
    ) async -> FeedbackSubmissionResult {
        // Validate input
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            return .failure(error: .invalidInput("Title cannot be empty"))
        }

        guard trimmedTitle.count >= 5 else {
            return .failure(error: .invalidInput("Title must be at least 5 characters"))
        }

        guard trimmedDescription.count >= 10 else {
            return .failure(error: .invalidInput("Description must be at least 10 characters"))
        }

        // Check if gh CLI is available
        guard await isGhInstalled() else {
            return .failure(error: .ghNotInstalled)
        }

        // Check if authenticated
        guard await isGhAuthenticated() else {
            return .failure(error: .notAuthenticated)
        }

        isSubmitting = true
        defer { isSubmitting = false }

        // Build the issue body
        var body = trimmedDescription
        if includeSystemInfo {
            let systemInfo = collectSystemInfo()
            body += systemInfo.formattedString
        }

        // Create the issue
        logger.info("Submitting \(category.displayName) feedback: \(trimmedTitle)")

        do {
            let issueURL = try await createGitHubIssue(
                title: trimmedTitle,
                body: body,
                label: category.githubLabel
            )
            logger.info("Successfully created issue: \(issueURL)")
            return .success(issueURL: issueURL)
        } catch let error as FeedbackError {
            logger.error("Failed to submit feedback: \(error.localizedDescription)")
            return .failure(error: error)
        } catch {
            logger.error("Unexpected error submitting feedback: \(error.localizedDescription)")
            return .failure(error: .submissionFailed(error.localizedDescription))
        }
    }

    /// Check if the gh CLI is installed and available
    func isGhInstalled() async -> Bool {
        do {
            _ = try await runCommand("/usr/bin/which", arguments: ["gh"])
            return true
        } catch {
            logger.warning("gh CLI not found")
            return false
        }
    }

    /// Check if the user is authenticated with GitHub
    func isGhAuthenticated() async -> Bool {
        do {
            let output = try await runGhCommand(["auth", "status"])
            return output.contains("Logged in")
        } catch {
            logger.warning("gh CLI not authenticated")
            return false
        }
    }

    // MARK: - Private Methods

    /// Collect system information for the feedback report
    private func collectSystemInfo() -> SystemInfo {
        // Get macOS version
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let macOSVersion = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

        // Get app version from bundle
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"

        // Get connected providers count
        let connectedProviders = RemotesViewModel.shared.remotes.filter { $0.isConfigured && $0.type != .local }.count

        return SystemInfo(
            macOSVersion: macOSVersion,
            appVersion: appVersion,
            connectedProviders: connectedProviders
        )
    }

    /// Create a GitHub issue using the gh CLI
    private func createGitHubIssue(title: String, body: String, label: String) async throws -> String {
        let arguments = [
            "issue", "create",
            "--repo", repository,
            "--title", title,
            "--body", body,
            "--label", label
        ]

        let output = try await runGhCommand(arguments)

        // Extract the issue URL from the output
        // gh issue create typically outputs something like "https://github.com/owner/repo/issues/123"
        if let url = output.components(separatedBy: .newlines)
            .first(where: { $0.contains("github.com") && $0.contains("/issues/") }) {
            return url.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // If we can't extract the URL but the command succeeded, return a generic message
        if !output.isEmpty {
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        throw FeedbackError.submissionFailed("Could not retrieve issue URL")
    }

    /// Run a gh CLI command
    private func runGhCommand(_ arguments: [String]) async throws -> String {
        // Find gh in common locations
        let ghPaths = [
            "/usr/local/bin/gh",
            "/opt/homebrew/bin/gh",
            "/usr/bin/gh"
        ]

        var ghPath: String?
        for path in ghPaths {
            if FileManager.default.fileExists(atPath: path) {
                ghPath = path
                break
            }
        }

        if ghPath == nil {
            // Try to find gh using which
            if let whichOutput = try? await runCommand("/usr/bin/which", arguments: ["gh"]),
               !whichOutput.isEmpty {
                ghPath = whichOutput.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                throw FeedbackError.ghNotInstalled
            }
        }

        guard let finalPath = ghPath else {
            throw FeedbackError.ghNotInstalled
        }

        return try await runCommand(finalPath, arguments: arguments)
    }

    /// Run a command and return its output
    private func runCommand(_ path: String, arguments: [String]) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = arguments

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            do {
                try process.run()
                process.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: outputData, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    let message = errorOutput.isEmpty ? output : errorOutput
                    continuation.resume(throwing: FeedbackError.submissionFailed(message))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
