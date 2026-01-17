//
//  SupportView.swift
//  CloudSyncApp
//
//  Support center view with GitHub Discussions integration
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var supportManager = SupportManager.shared

    @State private var searchQuery = ""
    @State private var copiedInfo = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Search
                    searchSection

                    // Quick Actions
                    quickActionsSection

                    // Support Categories
                    categoriesSection

                    // Quick Help Topics
                    quickHelpSection

                    // Support Links
                    linksSection
                }
                .padding(24)
            }

            Divider()

            // Footer
            footerView
        }
        .frame(width: 500, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("Support Center")
                    .font(.headline)
                Text("Get help from the community")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Search Section

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Search Discussions")
                .font(.headline)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search for help...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if !searchQuery.isEmpty {
                            supportManager.searchDiscussions(query: searchQuery)
                        }
                    }

                if !searchQuery.isEmpty {
                    Button {
                        supportManager.searchDiscussions(query: searchQuery)
                    } label: {
                        Text("Search")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(10)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                SupportQuickActionButton(
                    title: "Ask Question",
                    icon: "questionmark.bubble",
                    color: .blue
                ) {
                    supportManager.openNewDiscussion(category: .question)
                }

                SupportQuickActionButton(
                    title: "Get Help",
                    icon: "lifepreserver",
                    color: .orange
                ) {
                    supportManager.openNewDiscussion(category: .help)
                }

                SupportQuickActionButton(
                    title: "Browse All",
                    icon: "list.bullet",
                    color: .green
                ) {
                    supportManager.openDiscussions()
                }
            }
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start a Discussion")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(SupportCategory.allCases, id: \.self) { category in
                    CategoryRow(category: category) {
                        supportManager.openNewDiscussion(category: category)
                    }
                }
            }
        }
    }

    // MARK: - Quick Help Section

    private var quickHelpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Help")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(QuickHelpTopic.allCases, id: \.self) { topic in
                    QuickHelpButton(topic: topic) {
                        supportManager.openQuickHelp(topic: topic)
                    }
                }
            }
        }
    }

    // MARK: - Links Section

    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resources")
                .font(.headline)

            VStack(spacing: 4) {
                ForEach(supportManager.supportLinks, id: \.title) { link in
                    LinkRow(title: link.title, icon: link.icon) {
                        NSWorkspace.shared.open(link.url)
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Button {
                let info = supportManager.copySupportInfo()
                copiedInfo = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    copiedInfo = false
                }
            } label: {
                Label(copiedInfo ? "Copied!" : "Copy System Info", systemImage: copiedInfo ? "checkmark" : "doc.on.doc")
            }
            .buttonStyle(.borderless)

            Spacer()

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Supporting Views

private struct SupportQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryRow: View {
    let category: SupportCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.displayName)
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

private struct QuickHelpButton: View {
    let topic: QuickHelpTopic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: topic.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.blue)

                Text(topic.displayName)
                    .font(.caption)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

private struct LinkRow: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 16)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.blue)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SupportView()
}
