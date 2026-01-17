//
//  SupportManager.swift
//  CloudSyncApp
//
//  Manages user support via GitHub Discussions
//  Pillar 6: Business Operations - Support Automation
//

import Foundation
import AppKit
import os

/// Categories for support requests mapped to GitHub Discussions categories
enum SupportCategory: String, CaseIterable {
    case question = "Q&A"
    case help = "Help"
    case feature = "Ideas"
    case general = "General"

    var displayName: String {
        switch self {
        case .question: return "Ask a Question"
        case .help: return "Get Help"
        case .feature: return "Suggest a Feature"
        case .general: return "General Discussion"
        }
    }

    var icon: String {
        switch self {
        case .question: return "questionmark.circle"
        case .help: return "lifepreserver"
        case .feature: return "lightbulb"
        case .general: return "bubble.left.and.bubble.right"
        }
    }

    var description: String {
        switch self {
        case .question: return "Ask the community a question"
        case .help: return "Get help with an issue"
        case .feature: return "Share ideas for new features"
        case .general: return "Start a general discussion"
        }
    }

    /// GitHub Discussions category slug
    var categorySlug: String {
        switch self {
        case .question: return "q-a"
        case .help: return "help"
        case .feature: return "ideas"
        case .general: return "general"
        }
    }
}

/// Quick help topics with direct links
enum QuickHelpTopic: String, CaseIterable {
    case gettingStarted = "getting-started"
    case connectProvider = "connect-provider"
    case syncFiles = "sync-files"
    case encryption = "encryption"
    case troubleshooting = "troubleshooting"

    var displayName: String {
        switch self {
        case .gettingStarted: return "Getting Started"
        case .connectProvider: return "Connect a Provider"
        case .syncFiles: return "Sync Files"
        case .encryption: return "Set Up Encryption"
        case .troubleshooting: return "Troubleshooting"
        }
    }

    var icon: String {
        switch self {
        case .gettingStarted: return "play.circle"
        case .connectProvider: return "link"
        case .syncFiles: return "arrow.triangle.2.circlepath"
        case .encryption: return "lock.shield"
        case .troubleshooting: return "wrench.and.screwdriver"
        }
    }
}

/// Manages support interactions via GitHub Discussions
@MainActor
final class SupportManager: ObservableObject {

    // MARK: - Singleton

    static let shared = SupportManager()

    // MARK: - Properties

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "support")

    /// GitHub repository for discussions
    private let repository = "Andybod1/CloudSyncUltra"

    /// Base URL for GitHub Discussions
    private var discussionsURL: URL {
        URL(string: "https://github.com/\(repository)/discussions")!
    }

    /// URL for creating new discussions
    private var newDiscussionURL: URL {
        URL(string: "https://github.com/\(repository)/discussions/new")!
    }

    /// URL for documentation/wiki
    private var docsURL: URL {
        URL(string: "https://github.com/\(repository)/wiki")!
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Open GitHub Discussions in browser
    func openDiscussions() {
        logger.info("Opening GitHub Discussions")
        NSWorkspace.shared.open(discussionsURL)
    }

    /// Open new discussion form with category pre-selected
    func openNewDiscussion(category: SupportCategory) {
        let url = URL(string: "https://github.com/\(repository)/discussions/new?category=\(category.categorySlug)")!
        logger.info("Opening new discussion: \(category.displayName)")
        NSWorkspace.shared.open(url)
    }

    /// Search discussions for a query
    func searchDiscussions(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://github.com/\(repository)/discussions?discussions_q=\(encodedQuery)")!
        logger.info("Searching discussions: \(query)")
        NSWorkspace.shared.open(url)
    }

    /// Open documentation/wiki
    func openDocumentation() {
        logger.info("Opening documentation")
        NSWorkspace.shared.open(docsURL)
    }

    /// Open a quick help topic
    func openQuickHelp(topic: QuickHelpTopic) {
        // Search for the topic in discussions
        searchDiscussions(query: "label:\(topic.rawValue)")
    }

    /// Copy support info to clipboard (for pasting in discussions)
    func copySupportInfo() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let macOSVersion = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        let info = """
        **System Information:**
        - App Version: \(appVersion) (\(buildVersion))
        - macOS Version: \(macOSVersion)
        - Date: \(ISO8601DateFormatter().string(from: Date()))
        """

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(info, forType: .string)

        logger.info("Copied support info to clipboard")
        return info
    }

    /// Check if GitHub Discussions are accessible
    func checkDiscussionsAvailable() async -> Bool {
        do {
            let (_, response) = try await URLSession.shared.data(from: discussionsURL)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            logger.error("Failed to check discussions availability: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Support Links

    /// Get all support links for display
    var supportLinks: [(title: String, url: URL, icon: String)] {
        [
            ("GitHub Discussions", discussionsURL, "bubble.left.and.bubble.right"),
            ("Documentation", docsURL, "book"),
            ("Report a Bug", URL(string: "https://github.com/\(repository)/issues/new?template=bug_report.md")!, "ladybug"),
            ("Request a Feature", URL(string: "https://github.com/\(repository)/issues/new?template=feature_request.md")!, "lightbulb"),
            ("Release Notes", URL(string: "https://github.com/\(repository)/releases")!, "doc.text")
        ]
    }
}
