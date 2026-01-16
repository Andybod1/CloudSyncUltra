//
//  SubscriptionTier.swift
//  CloudSyncApp
//
//  Created by Revenue Engineer on 2026-01-15.
//

import Foundation

/// Represents the subscription tier for CloudSync Ultra
enum SubscriptionTier: String, Codable, CaseIterable {
    case free
    case pro

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .pro:
            return "Pro"
        }
    }

    var monthlyPrice: String {
        switch self {
        case .free:
            return "$0"
        case .pro:
            return "$9.99"
        }
    }

    var yearlyPrice: String? {
        switch self {
        case .free:
            return nil
        case .pro:
            return "$99.00"
        }
    }

    // MARK: - Feature Limits

    /// Maximum number of cloud connections allowed. nil means unlimited.
    var connectionLimit: Int? {
        switch self {
        case .free:
            return 2
        case .pro:
            return nil // unlimited
        }
    }

    /// Monthly transfer limit in GB. nil means unlimited.
    var transferLimitGB: Int? {
        switch self {
        case .free:
            return 5
        case .pro:
            return nil
        }
    }

    /// Whether scheduled sync is available
    var hasScheduledSync: Bool {
        self != .free
    }

    /// Whether encryption is available
    var hasEncryption: Bool {
        self != .free
    }

    /// Whether real-time sync is available
    var hasRealtimeSync: Bool {
        self != .free
    }

    /// Whether version history is available
    var hasVersionHistory: Bool {
        self == .pro
    }

    /// Whether SSO is available (future feature)
    var hasSSO: Bool {
        false
    }

    // MARK: - Feature Descriptions

    var features: [String] {
        switch self {
        case .free:
            return [
                "2 cloud connections",
                "5 GB monthly transfer",
                "Manual sync only",
                "Basic support"
            ]
        case .pro:
            return [
                "Unlimited connections",
                "Unlimited transfer",
                "Scheduled & real-time sync",
                "End-to-end encryption",
                "Version history",
                "Priority support"
            ]
        }
    }

    // MARK: - StoreKit Product IDs

    var productIDs: [String] {
        switch self {
        case .free:
            return [] // No products for free tier
        case .pro:
            return [
                "com.cloudsync.pro.monthly",
                "com.cloudsync.pro.yearly"
            ]
        }
    }

    /// Get the appropriate tier for a given product ID
    static func tier(for productID: String) -> SubscriptionTier? {
        for tier in SubscriptionTier.allCases {
            if tier.productIDs.contains(productID) {
                return tier
            }
        }
        return nil
    }

    // MARK: - Comparison

    /// Check if this tier includes all features of another tier
    func includes(_ other: SubscriptionTier) -> Bool {
        switch (self, other) {
        case (.free, .free):
            return true
        case (.pro, .free), (.pro, .pro):
            return true
        default:
            return false
        }
    }

    /// Check if upgrade is available from this tier
    var canUpgrade: Bool {
        self != .pro
    }

    /// Get available upgrade options
    var upgradeOptions: [SubscriptionTier] {
        switch self {
        case .free:
            return [.pro]
        case .pro:
            return []
        }
    }
}

// MARK: - Helper Extensions

extension SubscriptionTier {
    /// Check if a specific number of connections is allowed
    func canAddConnection(currentCount: Int) -> Bool {
        guard let limit = connectionLimit else { return true }
        return currentCount < limit
    }

    /// Check if a specific transfer amount is allowed
    func canTransfer(monthlyUsageGB: Double, additionalGB: Double) -> Bool {
        guard let limit = transferLimitGB else { return true }
        return (monthlyUsageGB + additionalGB) <= Double(limit)
    }

    /// Get a user-friendly message for hitting a limit
    func limitMessage(for feature: String) -> String {
        switch feature {
        case "connections":
            return "You've reached the \(connectionLimit ?? 0) connection limit for the \(displayName) tier. Upgrade to add more connections."
        case "transfer":
            return "You've reached the \(transferLimitGB ?? 0) GB monthly transfer limit for the \(displayName) tier. Upgrade for unlimited transfers."
        case "encryption":
            return "Encryption is only available in Pro tier. Upgrade to secure your data."
        case "scheduling":
            return "Scheduled sync is only available in Pro tier. Upgrade to automate your syncs."
        default:
            return "This feature requires an upgrade. Check out our Pro tier."
        }
    }
}