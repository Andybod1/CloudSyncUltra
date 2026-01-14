//
//  HelpCategory.swift
//  CloudSyncApp
//
//  Help topic categories for organizing help content
//

import Foundation

enum HelpCategory: String, CaseIterable, Codable, Identifiable {
    case gettingStarted = "getting_started"
    case providers = "providers"
    case syncing = "syncing"
    case troubleshooting = "troubleshooting"
    case security = "security"
    case advanced = "advanced"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gettingStarted: return "Getting Started"
        case .providers: return "Cloud Providers"
        case .syncing: return "Syncing & Transfers"
        case .troubleshooting: return "Troubleshooting"
        case .security: return "Security & Encryption"
        case .advanced: return "Advanced Features"
        }
    }

    var iconName: String {
        switch self {
        case .gettingStarted: return "play.circle.fill"
        case .providers: return "cloud.fill"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .troubleshooting: return "wrench.and.screwdriver.fill"
        case .security: return "lock.shield.fill"
        case .advanced: return "gearshape.2.fill"
        }
    }

    var sortOrder: Int {
        switch self {
        case .gettingStarted: return 0
        case .providers: return 1
        case .syncing: return 2
        case .troubleshooting: return 3
        case .security: return 4
        case .advanced: return 5
        }
    }
}
