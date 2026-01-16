//
//  FeedbackCategory.swift
//  CloudSyncApp
//
//  Feedback category types for user feedback submission
//  Issue #97: In-App Feedback Manager
//

import Foundation

/// Categories for user feedback that map to GitHub issue labels
enum FeedbackCategory: String, CaseIterable, Identifiable {
    case bug = "bug"
    case feature = "enhancement"
    case feedback = "feedback"

    var id: String { rawValue }

    /// Human-readable display name for the category
    var displayName: String {
        switch self {
        case .bug: return "Bug Report"
        case .feature: return "Feature Request"
        case .feedback: return "General Feedback"
        }
    }

    /// SF Symbol icon name for the category
    var icon: String {
        switch self {
        case .bug: return "ladybug.fill"
        case .feature: return "lightbulb.fill"
        case .feedback: return "bubble.left.and.bubble.right.fill"
        }
    }

    /// GitHub label to apply to the created issue
    var githubLabel: String {
        return rawValue
    }

    /// Description text to help users understand the category
    var description: String {
        switch self {
        case .bug: return "Report a problem or unexpected behavior"
        case .feature: return "Suggest a new feature or improvement"
        case .feedback: return "Share general comments or suggestions"
        }
    }
}
