//
//  ChooseProviderStep.swift
//  CloudSyncApp
//
//  Step 1: Choose a cloud provider
//

import SwiftUI

struct ChooseProviderStep: View {
    @Binding var selectedProvider: CloudProviderType?
    @Binding var remoteName: String
    @State private var searchText = ""

    private let supportedProviders = CloudProviderType.allCases
        .filter { $0.isSupported && $0 != .local }
        .sorted { $0.displayName < $1.displayName }

    private var filteredProviders: [CloudProviderType] {
        if searchText.isEmpty {
            return supportedProviders
        }
        return supportedProviders.filter { provider in
            provider.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var popularProviders: [CloudProviderType] {
        [.googleDrive, .dropbox, .oneDrive, .icloud, .protonDrive, .mega]
            .filter { supportedProviders.contains($0) }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Choose Your Cloud Storage Provider")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Select the cloud service you want to connect to CloudSync Ultra")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search providers...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if searchText.isEmpty {
                        // Popular providers section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Popular Providers")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 12)
                            ], spacing: 12) {
                                ForEach(popularProviders) { provider in
                                    WizardProviderCard(
                                        provider: provider,
                                        isSelected: selectedProvider == provider,
                                        showOAuthBadge: true
                                    ) {
                                        selectProvider(provider)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // All providers section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("All Providers")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 12)
                            ], spacing: 12) {
                                ForEach(supportedProviders.filter { !popularProviders.contains($0) }) { provider in
                                    WizardProviderCard(
                                        provider: provider,
                                        isSelected: selectedProvider == provider,
                                        showOAuthBadge: true
                                    ) {
                                        selectProvider(provider)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Filtered results
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 12)
                        ], spacing: 12) {
                            ForEach(filteredProviders) { provider in
                                WizardProviderCard(
                                    provider: provider,
                                    isSelected: selectedProvider == provider,
                                    showOAuthBadge: true
                                ) {
                                    selectProvider(provider)
                                }
                            }
                        }
                        .padding(.horizontal)

                        if filteredProviders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No providers match '\(searchText)'")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                }
                .padding(.vertical)
            }

            // Selected provider info
            if let provider = selectedProvider {
                VStack(spacing: 12) {
                    Divider()

                    HStack(spacing: 12) {
                        Image(systemName: provider.iconName)
                            .font(.title2)
                            .foregroundColor(provider.brandColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(provider.displayName)
                                .font(.headline)

                            HStack(spacing: 12) {
                                if provider.requiresOAuth {
                                    Label("OAuth Authentication", systemImage: "safari")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Label("Username & Password", systemImage: "key.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                if provider.isExperimental {
                                    Label("Experimental", systemImage: "flask.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.default, value: selectedProvider)
        .animation(.default, value: searchText)
    }

    private func selectProvider(_ provider: CloudProviderType) {
        selectedProvider = provider
        remoteName = provider.displayName
    }
}

/// Enhanced provider card with OAuth/credentials badge for wizard
struct WizardProviderCard: View {
    let provider: CloudProviderType
    let isSelected: Bool
    var showOAuthBadge: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Provider icon
                ZStack {
                    Circle()
                        .fill(provider.brandColor.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: provider.iconName)
                        .font(.title2)
                        .foregroundColor(provider.brandColor)
                }

                // Provider name
                Text(provider.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Badges
                VStack(spacing: 4) {
                    if provider.isExperimental {
                        Text("EXPERIMENTAL")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Capsule())
                    }

                    if showOAuthBadge {
                        Image(systemName: provider.requiresOAuth ? "safari" : "key.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? provider.brandColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? provider.brandColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedProvider: CloudProviderType?
    @Previewable @State var remoteName = ""

    ChooseProviderStep(
        selectedProvider: $selectedProvider,
        remoteName: $remoteName
    )
    .frame(width: 700, height: 600)
}