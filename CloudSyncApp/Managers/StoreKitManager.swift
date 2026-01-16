//
//  StoreKitManager.swift
//  CloudSyncApp
//
//  Created by Revenue Engineer on 2026-01-15.
//

import SwiftUI
import StoreKit
import os.log
import AppKit

/// Manages all StoreKit 2 operations for CloudSync Ultra subscriptions
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    // MARK: - Published Properties

    @Published var currentTier: SubscriptionTier = .free {
        didSet {
            // Cache tier for nonisolated access
            Self._cachedTierRawValue = currentTier.rawValue
        }
    }
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var activeTransaction: StoreKit.Transaction?
    @Published var subscriptionStatus: Product.SubscriptionInfo.Status?

    // MARK: - Thread-Safe Tier Access

    /// Cached tier value for nonisolated access (thread-safe)
    nonisolated(unsafe) private static var _cachedTierRawValue: String = SubscriptionTier.free.rawValue

    /// Access current subscription tier from any context (thread-safe)
    nonisolated static var cachedTier: SubscriptionTier {
        SubscriptionTier(rawValue: _cachedTierRawValue) ?? .free
    }

    // MARK: - Private Properties

    private let logger = Logger(subsystem: "com.cloudsync", category: "StoreKitManager")
    private var updateListenerTask: Task<Void, Error>?

    // Product IDs (must match App Store Connect configuration)
    private let productIDs = [
        "com.cloudsync.pro.monthly",
        "com.cloudsync.pro.yearly"
    ]

    // MARK: - Initialization

    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        // Load products and check subscription status on init
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading

    /// Load products from the App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            logger.info("Loading products: \(self.productIDs.joined(separator: ", "))")
            products = try await Product.products(for: productIDs)
            logger.info("Loaded \(self.products.count) products")
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
            errorMessage = "Failed to load subscription options. Please try again."
        }
    }

    // MARK: - Purchase Methods

    /// Purchase a subscription product
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        defer { isLoading = false }

        logger.info("Attempting to purchase: \(product.id)")

        // Initiate purchase
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // Check verification
            let transaction = try checkVerified(verification)

            // Update subscription status
            await updateSubscriptionStatus()

            // Finish the transaction
            await transaction.finish()

            logger.info("Purchase successful: \(product.id)")
            return transaction

        case .userCancelled:
            logger.info("User cancelled purchase")
            return nil

        case .pending:
            logger.info("Purchase pending (Ask to Buy)")
            errorMessage = "Purchase is pending approval."
            return nil

        @unknown default:
            logger.warning("Unknown purchase result")
            return nil
        }
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        logger.info("Restoring purchases")

        // Sync with App Store to ensure we have latest transactions
        try? await AppStore.sync()

        // Update subscription status
        await updateSubscriptionStatus()

        if currentTier == .free {
            errorMessage = "No active subscriptions found."
        } else {
            logger.info("Restored subscription: \(self.currentTier.rawValue)")
        }
    }

    // MARK: - Subscription Status

    /// Update current subscription status
    func updateSubscriptionStatus() async {
        var highestTier = SubscriptionTier.free
        purchasedProductIDs.removeAll()

        // Check all active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Add to purchased products
                purchasedProductIDs.insert(transaction.productID)

                // Determine tier from product ID
                if let tier = SubscriptionTier.tier(for: transaction.productID) {
                    // Use the highest tier if multiple active
                    if tier.includes(highestTier) {
                        highestTier = tier
                    }
                    activeTransaction = transaction
                }

                logger.info("Active subscription: \(transaction.productID)")

                // Get subscription status
                if let product = products.first(where: { $0.id == transaction.productID }) {
                    subscriptionStatus = try await product.subscription?.status.first
                }
            } catch {
                logger.error("Transaction verification failed: \(error.localizedDescription)")
            }
        }

        currentTier = highestTier
        logger.info("Current tier: \(self.currentTier.rawValue)")
    }

    // MARK: - Transaction Verification

    /// Verify transaction authenticity
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            logger.error("Transaction verification failed: \(error)")
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Transaction Updates

    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for updates to transactions
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    // Update subscription status on main actor
                    await MainActor.run {
                        Task {
                            await self.updateSubscriptionStatus()
                        }
                    }

                    // Always finish transactions
                    await transaction.finish()
                } catch {
                    await MainActor.run {
                        self.logger.error("Transaction update error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Feature Access

    /// Check if user can add more remotes
    var canAddRemote: Bool {
        guard let limit = currentTier.connectionLimit else { return true }
        // This would need to check actual remote count from RemotesViewModel
        return true // Placeholder - implement with actual count
    }

    /// Check if user can use scheduled sync
    var canUseScheduledSync: Bool {
        currentTier.hasScheduledSync
    }

    /// Check if user can use encryption
    var canUseEncryption: Bool {
        currentTier.hasEncryption
    }

    /// Get remaining transfer quota
    func remainingTransferGB(currentUsageGB: Double) -> Double? {
        guard let limit = currentTier.transferLimitGB else { return nil }
        return max(0, Double(limit) - currentUsageGB)
    }

    // MARK: - Subscription Management

    /// Open subscription management on macOS
    func manageSubscription() {
        // On macOS, open the App Store app to subscriptions
        if let url = URL(string: "macappstore://showpurchases") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Price Formatting

    /// Get formatted price for a product
    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }

    /// Get formatted price per month for yearly subscriptions
    func formattedMonthlyPrice(for product: Product) -> String? {
        guard product.id.contains("yearly"),
              let months = product.subscription?.subscriptionPeriod.value,
              product.subscription?.subscriptionPeriod.unit == .year else {
            return nil
        }

        let monthlyPrice = product.price / Decimal(months * 12)
        return product.priceFormatStyle.format(monthlyPrice) + "/mo"
    }
}

// MARK: - Error Types

enum StoreError: LocalizedError {
    case verificationFailed
    case purchaseFailed(String)
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .productNotFound:
            return "Product not found"
        }
    }
}

// MARK: - Helper Extensions

extension StoreKitManager {
    /// Check if a product is purchased
    func isPurchased(_ product: Product) -> Bool {
        purchasedProductIDs.contains(product.id)
    }

    /// Get the product for a specific tier and billing period
    func product(for tier: SubscriptionTier, yearly: Bool = false) -> Product? {
        let targetID: String

        switch (tier, yearly) {
        case (.pro, false):
            targetID = "com.cloudsync.pro.monthly"
        case (.pro, true):
            targetID = "com.cloudsync.pro.yearly"
        default:
            return nil
        }

        return products.first { $0.id == targetID }
    }

    /// Get savings percentage for yearly vs monthly
    func yearlySavingsPercentage() -> Int? {
        guard let monthlyProduct = product(for: .pro, yearly: false),
              let yearlyProduct = product(for: .pro, yearly: true) else {
            return nil
        }

        let monthlyTotal = monthlyProduct.price * 12
        let yearlyCost = yearlyProduct.price
        let savings = (monthlyTotal - yearlyCost) / monthlyTotal

        return NSDecimalNumber(decimal: savings * 100).intValue
    }
}
