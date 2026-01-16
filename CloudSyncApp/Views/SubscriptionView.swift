//
//  SubscriptionView.swift
//  CloudSyncApp
//
//  Created by Revenue Engineer on 2026-01-15.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    @State private var showCancelConfirmation = false
    @State private var isManagingSubscription = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            ScrollView {
                VStack(spacing: 24) {
                    // Current subscription info
                    currentSubscriptionSection

                    // Usage stats
                    if storeKitManager.currentTier != .free {
                        usageSection
                    }

                    // Benefits section
                    benefitsSection

                    // Management buttons
                    managementSection
                }
                .padding(32)
            }
        }
        .frame(width: 600, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Subscription")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
    }

    // MARK: - Current Subscription

    private var currentSubscriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tierGradient)
                        .frame(width: 60, height: 60)

                    Image(systemName: tierIcon)
                        .font(.title)
                        .foregroundStyle(.white)
                }

                // Subscription info
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(storeKitManager.currentTier.displayName) Plan")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let status = storeKitManager.subscriptionStatus {
                        HStack(spacing: 8) {
                            statusBadge(for: status.state)

                            if case .verified(let transaction) = status.transaction,
                               let expirationDate = transaction.expirationDate {
                                Text("Expires: \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else if storeKitManager.currentTier == .free {
                        Text("No active subscription")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Price
                if let transaction = storeKitManager.activeTransaction,
                   let product = storeKitManager.products.first(where: { $0.id == transaction.productID }) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(product.displayPrice)
                            .font(.title3)
                            .fontWeight(.medium)

                        Text(billingPeriod(for: product))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var tierGradient: LinearGradient {
        switch storeKitManager.currentTier {
        case .free:
            return LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pro:
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var tierIcon: String {
        switch storeKitManager.currentTier {
        case .free:
            return "cloud"
        case .pro:
            return "cloud.fill"
        }
    }

    private func statusBadge(for state: Product.SubscriptionInfo.RenewalState) -> some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon(for: state))
                .font(.caption2)

            Text(statusText(for: state))
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(statusColor(for: state))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(statusColor(for: state).opacity(0.15))
        .clipShape(Capsule())
    }

    private func statusIcon(for state: Product.SubscriptionInfo.RenewalState) -> String {
        switch state {
        case .subscribed:
            return "checkmark.circle.fill"
        case .expired:
            return "exclamationmark.circle.fill"
        case .inBillingRetryPeriod:
            return "exclamationmark.triangle.fill"
        case .inGracePeriod:
            return "clock.fill"
        case .revoked:
            return "xmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    private func statusText(for state: Product.SubscriptionInfo.RenewalState) -> String {
        switch state {
        case .subscribed:
            return "Active"
        case .expired:
            return "Expired"
        case .inBillingRetryPeriod:
            return "Billing Issue"
        case .inGracePeriod:
            return "Grace Period"
        case .revoked:
            return "Revoked"
        default:
            return "Unknown"
        }
    }

    private func statusColor(for state: Product.SubscriptionInfo.RenewalState) -> Color {
        switch state {
        case .subscribed:
            return .green
        case .expired, .revoked:
            return .red
        case .inBillingRetryPeriod, .inGracePeriod:
            return .orange
        default:
            return .gray
        }
    }

    private func billingPeriod(for product: Product) -> String {
        if product.id.contains("yearly") {
            return "per year"
        } else {
            return "per month"
        }
    }

    // MARK: - Usage Section

    private var usageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Usage")
                .font(.headline)

            HStack(spacing: 16) {
                // Transfer usage
                UsageCard(
                    title: "Monthly Transfer",
                    usage: "2.3 GB",
                    limit: storeKitManager.currentTier.transferLimitGB.map { "\($0) GB" },
                    percentage: 0.46,
                    icon: "arrow.up.arrow.down"
                )

                // Connections usage
                UsageCard(
                    title: "Cloud Connections",
                    usage: "4",
                    limit: storeKitManager.currentTier.connectionLimit.map { "\($0)" },
                    percentage: nil,
                    icon: "link"
                )
            }
        }
    }

    // MARK: - Benefits Section

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Benefits")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(storeKitManager.currentTier.features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.green)

                        Text(feature)
                            .font(.callout)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Management Section

    private var managementSection: some View {
        VStack(spacing: 12) {
            if storeKitManager.currentTier.canUpgrade {
                Button(action: {
                    dismiss()
                    // Show paywall
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Upgrade Plan")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            if storeKitManager.currentTier != .free {
                Button(action: {
                    isManagingSubscription = true
                    storeKitManager.manageSubscription()
                }) {
                    Text("Manage Subscription")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Text("Manage your subscription, billing, and payment methods in the App Store")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Usage Card Component

struct UsageCard: View {
    let title: String
    let usage: String
    let limit: String?
    let percentage: Double?
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .bottom, spacing: 4) {
                Text(usage)
                    .font(.title3)
                    .fontWeight(.semibold)

                if let limit = limit {
                    Text("/ \(limit)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Unlimited")
                        .font(.callout)
                        .foregroundStyle(.green)
                }
            }

            if let percentage = percentage {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(percentage > 0.8 ? Color.orange : Color.blue)
                            .frame(width: geometry.size.width * percentage, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    SubscriptionView()
        .environmentObject(StoreKitManager.shared)
}
