//
//  StoreKitTests.swift
//  CloudSyncAppTests
//
//  Created by Revenue Engineer on 2026-01-15.
//

import XCTest
import StoreKit
import StoreKitTest
@testable import CloudSyncApp

@MainActor
class StoreKitTests: XCTestCase {

    var storeKitManager: StoreKitManager!
    var testSession: SKTestSession!

    override func setUp() async throws {
        try await super.setUp()

        // Create a test session
        testSession = try SKTestSession(configurationFileNamed: "Configuration.storekit")
        testSession.resetToDefaultState()
        testSession.clearTransactions()
        testSession.disableDialogs = true

        // Initialize StoreKitManager
        storeKitManager = StoreKitManager.shared
    }

    override func tearDown() async throws {
        testSession = nil
        storeKitManager = nil
        try await super.tearDown()
    }

    // MARK: - Product Loading Tests

    func testLoadProducts() async throws {
        // Given
        XCTAssertTrue(storeKitManager.products.isEmpty)

        // When
        await storeKitManager.loadProducts()

        // Then
        XCTAssertFalse(storeKitManager.products.isEmpty)
        XCTAssertEqual(storeKitManager.products.count, 3)

        // Verify product IDs
        let productIDs = storeKitManager.products.map { $0.id }
        XCTAssertTrue(productIDs.contains("com.cloudsync.pro.monthly"))
        XCTAssertTrue(productIDs.contains("com.cloudsync.pro.yearly"))
        XCTAssertTrue(productIDs.contains("com.cloudsync.team.monthly"))
    }

    // MARK: - Tier Tests

    func testSubscriptionTierLimits() {
        // Test Free tier
        let freeTier = SubscriptionTier.free
        XCTAssertEqual(freeTier.connectionLimit, 2)
        XCTAssertEqual(freeTier.transferLimitGB, 5)
        XCTAssertFalse(freeTier.hasScheduledSync)
        XCTAssertFalse(freeTier.hasEncryption)

        // Test Pro tier
        let proTier = SubscriptionTier.pro
        XCTAssertNil(proTier.connectionLimit)
        XCTAssertNil(proTier.transferLimitGB)
        XCTAssertTrue(proTier.hasScheduledSync)
        XCTAssertTrue(proTier.hasEncryption)

        // Test Team tier
        let teamTier = SubscriptionTier.team
        XCTAssertNil(teamTier.connectionLimit)
        XCTAssertNil(teamTier.transferLimitGB)
        XCTAssertTrue(teamTier.hasScheduledSync)
        XCTAssertTrue(teamTier.hasEncryption)
        XCTAssertTrue(teamTier.hasTeamManagement)
    }

    func testTierComparison() {
        // Test tier inclusion
        XCTAssertTrue(SubscriptionTier.pro.includes(.free))
        XCTAssertTrue(SubscriptionTier.team.includes(.free))
        XCTAssertTrue(SubscriptionTier.team.includes(.pro))
        XCTAssertFalse(SubscriptionTier.free.includes(.pro))
        XCTAssertFalse(SubscriptionTier.pro.includes(.team))
    }

    // MARK: - Purchase Flow Tests

    func testPurchaseProMonthly() async throws {
        // Load products first
        await storeKitManager.loadProducts()

        // Find Pro monthly product
        guard let product = storeKitManager.product(for: .pro, yearly: false) else {
            XCTFail("Pro monthly product not found")
            return
        }

        // Purchase the product
        let transaction = try await storeKitManager.purchase(product)
        XCTAssertNotNil(transaction)

        // Wait for status update
        await storeKitManager.updateSubscriptionStatus()

        // Verify subscription status
        XCTAssertEqual(storeKitManager.currentTier, .pro)
        XCTAssertTrue(storeKitManager.purchasedProductIDs.contains(product.id))
    }

    func testPurchaseProYearly() async throws {
        // Load products first
        await storeKitManager.loadProducts()

        // Find Pro yearly product
        guard let product = storeKitManager.product(for: .pro, yearly: true) else {
            XCTFail("Pro yearly product not found")
            return
        }

        // Purchase the product
        let transaction = try await storeKitManager.purchase(product)
        XCTAssertNotNil(transaction)

        // Wait for status update
        await storeKitManager.updateSubscriptionStatus()

        // Verify subscription status
        XCTAssertEqual(storeKitManager.currentTier, .pro)
        XCTAssertTrue(storeKitManager.purchasedProductIDs.contains(product.id))
    }

    func testPurchaseTeam() async throws {
        // Load products first
        await storeKitManager.loadProducts()

        // Find Team product
        guard let product = storeKitManager.product(for: .team) else {
            XCTFail("Team product not found")
            return
        }

        // Purchase the product
        let transaction = try await storeKitManager.purchase(product)
        XCTAssertNotNil(transaction)

        // Wait for status update
        await storeKitManager.updateSubscriptionStatus()

        // Verify subscription status
        XCTAssertEqual(storeKitManager.currentTier, .team)
        XCTAssertTrue(storeKitManager.purchasedProductIDs.contains(product.id))
    }

    // MARK: - Restore Purchases Tests

    func testRestorePurchases() async throws {
        // First, purchase a product
        await storeKitManager.loadProducts()
        if let product = storeKitManager.product(for: .pro) {
            _ = try await storeKitManager.purchase(product)
        }

        // Clear local state
        storeKitManager.currentTier = .free
        storeKitManager.purchasedProductIDs.removeAll()

        // Restore purchases
        await storeKitManager.restorePurchases()

        // Verify restoration
        XCTAssertEqual(storeKitManager.currentTier, .pro)
        XCTAssertFalse(storeKitManager.purchasedProductIDs.isEmpty)
    }

    // MARK: - Feature Gating Tests

    func testRemoteConnectionLimits() {
        let remotesVM = RemotesViewModel(forTesting: true)

        // Test free tier limits
        storeKitManager.currentTier = .free
        remotesVM.remotes = [
            CloudRemote(name: "Local", type: .local, isConfigured: true, path: "/"),
            CloudRemote(name: "Google", type: .googleDrive, isConfigured: true, path: "/")
        ]
        XCTAssertFalse(remotesVM.canAddMoreRemotes)
        XCTAssertEqual(remotesVM.remainingRemotesCount, 0)

        // Test pro tier (unlimited)
        storeKitManager.currentTier = .pro
        XCTAssertTrue(remotesVM.canAddMoreRemotes)
        XCTAssertNil(remotesVM.remainingRemotesCount)
    }

    func testScheduledSyncGating() {
        let syncManager = SyncManager.shared

        // Test free tier
        storeKitManager.currentTier = .free
        XCTAssertFalse(syncManager.canUseScheduledSync)
        XCTAssertFalse(syncManager.enableScheduledSync())

        // Test pro tier
        storeKitManager.currentTier = .pro
        XCTAssertTrue(syncManager.canUseScheduledSync)
        XCTAssertTrue(syncManager.enableScheduledSync())
    }

    func testEncryptionGating() {
        let encryptionManager = EncryptionManager.shared

        // Test free tier
        storeKitManager.currentTier = .free
        XCTAssertFalse(encryptionManager.canUseEncryption)
        XCTAssertFalse(encryptionManager.checkEncryptionAccess())

        // Test pro tier
        storeKitManager.currentTier = .pro
        XCTAssertTrue(encryptionManager.canUseEncryption)
        XCTAssertTrue(encryptionManager.checkEncryptionAccess())
    }

    // MARK: - Price Formatting Tests

    func testPriceFormatting() async throws {
        await storeKitManager.loadProducts()

        if let monthlyProduct = storeKitManager.product(for: .pro, yearly: false) {
            let price = storeKitManager.formattedPrice(for: monthlyProduct)
            XCTAssertFalse(price.isEmpty)
            XCTAssertTrue(price.contains("9.99"))
        }

        if let yearlyProduct = storeKitManager.product(for: .pro, yearly: true) {
            let price = storeKitManager.formattedPrice(for: yearlyProduct)
            XCTAssertFalse(price.isEmpty)
            XCTAssertTrue(price.contains("99"))

            // Test monthly price calculation
            let monthlyPrice = storeKitManager.formattedMonthlyPrice(for: yearlyProduct)
            XCTAssertNotNil(monthlyPrice)
        }
    }

    // MARK: - Savings Calculation Test

    func testYearlySavingsCalculation() async throws {
        await storeKitManager.loadProducts()

        let savings = storeKitManager.yearlySavingsPercentage()
        XCTAssertNotNil(savings)
        if let savings = savings {
            XCTAssertGreaterThan(savings, 0)
            XCTAssertLessThan(savings, 100)
        }
    }

    // MARK: - Subscription Expiration Tests

    func testSubscriptionExpiration() async throws {
        // Purchase a subscription
        await storeKitManager.loadProducts()
        if let product = storeKitManager.product(for: .pro) {
            _ = try await storeKitManager.purchase(product)
        }

        // Expire the subscription
        try await testSession.expireSubscription(productIdentifier: "com.cloudsync.pro.monthly")

        // Update status
        await storeKitManager.updateSubscriptionStatus()

        // Verify expired
        XCTAssertEqual(storeKitManager.currentTier, .free)
    }
}