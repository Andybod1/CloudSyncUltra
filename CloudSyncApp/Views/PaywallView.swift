//
//  PaywallView.swift
//  CloudSyncApp
//
//  Created by Revenue Engineer on 2026-01-15.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    // For animating tier cards
    @State private var animateTiers = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            ScrollView {
                VStack(spacing: 32) {
                    // Hero section
                    heroSection

                    // Tier comparison
                    tierComparisonSection

                    // Purchase buttons
                    purchaseSection

                    // Footer with restore and terms
                    footerSection
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 48)
            }
        }
        .frame(width: 900, height: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateTiers = true
            }
        }
        .sheet(isPresented: $showError) {
            errorSheet
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Text("Choose Your Plan")
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
        .padding(.horizontal, 48)
        .padding(.vertical, 24)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 64))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .symbolEffect(.bounce.up, value: animateTiers)

            Text("Unlock the Full Power of CloudSync Ultra")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Sync unlimited files across all your cloud services with advanced features")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)
        }
    }

    // MARK: - Tier Comparison Section

    private var tierComparisonSection: some View {
        HStack(spacing: 24) {
            ForEach([SubscriptionTier.free, .pro, .team], id: \.self) { tier in
                TierCard(
                    tier: tier,
                    isCurrentTier: storeKitManager.currentTier == tier,
                    isRecommended: tier == .pro,
                    product: storeKitManager.product(for: tier),
                    yearlyProduct: tier == .pro ? storeKitManager.product(for: tier, yearly: true) : nil,
                    selectedProduct: $selectedProduct
                )
                .opacity(animateTiers ? 1 : 0)
                .offset(y: animateTiers ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(tierAnimationDelay(for: tier)), value: animateTiers)
            }
        }
    }

    private func tierAnimationDelay(for tier: SubscriptionTier) -> Double {
        switch tier {
        case .free: return 0.1
        case .pro: return 0.2
        case .team: return 0.3
        }
    }

    // MARK: - Purchase Section

    private var purchaseSection: some View {
        VStack(spacing: 16) {
            if let product = selectedProduct {
                purchaseButton(for: product)
            } else if storeKitManager.currentTier == .free {
                Text("Select a plan to continue")
                    .foregroundStyle(.secondary)
            }

            if storeKitManager.yearlySavingsPercentage() != nil {
                savingsBadge
            }
        }
    }

    private func purchaseButton(for product: Product) -> some View {
        Button(action: { purchaseProduct(product) }) {
            HStack {
                if isPurchasing {
                    ProgressIndicator()
                        .scaleEffect(0.8)
                } else {
                    Text("Subscribe to \(tierName(for: product))")
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(product.displayPrice)
                }
            }
            .frame(maxWidth: 400)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isPurchasing || storeKitManager.isLoading)
    }

    private func tierName(for product: Product) -> String {
        if product.id.contains("pro") {
            return "Pro"
        } else if product.id.contains("team") {
            return "Team"
        }
        return ""
    }

    private var savingsBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "tag.fill")
                .foregroundStyle(.green)
                .font(.footnote)

            if let savings = storeKitManager.yearlySavingsPercentage() {
                Text("Save \(savings)% with yearly billing")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 12) {
            Button("Restore Purchases") {
                Task {
                    await storeKitManager.restorePurchases()
                    if let error = storeKitManager.errorMessage {
                        errorMessage = error
                        showError = true
                    }
                }
            }
            .buttonStyle(.link)

            HStack(spacing: 16) {
                Link("Terms of Service", destination: URL(string: "https://cloudsync.app/terms")!)
                    .font(.footnote)

                Text("•")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)

                Link("Privacy Policy", destination: URL(string: "https://cloudsync.app/privacy")!)
                    .font(.footnote)
            }
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Error Sheet

    private var errorSheet: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("Purchase Error")
                .font(.headline)

            Text(errorMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("OK") {
                showError = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(width: 400)
    }

    // MARK: - Purchase Logic

    private func purchaseProduct(_ product: Product) {
        isPurchasing = true

        Task {
            do {
                _ = try await storeKitManager.purchase(product)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPurchasing = false
        }
    }
}

// MARK: - Tier Card Component

struct TierCard: View {
    let tier: SubscriptionTier
    let isCurrentTier: Bool
    let isRecommended: Bool
    let product: Product?
    let yearlyProduct: Product?
    @Binding var selectedProduct: Product?

    @State private var showYearly = true

    var body: some View {
        VStack(spacing: 0) {
            // Header with badge
            VStack(spacing: 8) {
                if isRecommended {
                    Text("MOST POPULAR")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .clipShape(Capsule())
                } else {
                    // Placeholder for alignment
                    Text(" ")
                        .font(.caption2)
                        .padding(.vertical, 4)
                }

                Text(tier.displayName)
                    .font(.title2)
                    .fontWeight(.bold)

                if tier == .pro && yearlyProduct != nil {
                    // Billing toggle
                    Picker("Billing", selection: $showYearly) {
                        Text("Monthly").tag(false)
                        Text("Yearly").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    .onChange(of: showYearly) { _, yearly in
                        if yearly, let yearlyProduct = yearlyProduct {
                            selectedProduct = yearlyProduct
                        } else {
                            selectedProduct = product
                        }
                    }
                }

                // Price
                if tier == .free {
                    Text("Free")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                } else if showYearly && yearlyProduct != nil {
                    VStack(spacing: 4) {
                        Text(yearlyProduct!.displayPrice)
                            .font(.title2)
                            .fontWeight(.semibold)
                        if let monthlyPrice = StoreKitManager.shared.formattedMonthlyPrice(for: yearlyProduct!) {
                            Text(monthlyPrice)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if let product = product {
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()

            // Features list
            VStack(alignment: .leading, spacing: 12) {
                ForEach(tier.features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.green)

                        Text(feature)
                            .font(.callout)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Selection button
            if isCurrentTier {
                Text("Current Plan")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 24)
            } else if tier != .free {
                Button(action: {
                    if showYearly && yearlyProduct != nil {
                        selectedProduct = yearlyProduct
                    } else {
                        selectedProduct = product
                    }
                }) {
                    Text("Select \(tier.displayName)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 260, height: 450)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isRecommended ? Color.blue : Color.clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(isRecommended ? 0.1 : 0.05), radius: 10)
    }
}

// MARK: - Progress Indicator

struct ProgressIndicator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.controlSize = .small
        indicator.isIndeterminate = true
        indicator.startAnimation(nil)
        return indicator
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {}
}

// MARK: - Preview

#Preview {
    PaywallView()
        .environmentObject(StoreKitManager.shared)
}