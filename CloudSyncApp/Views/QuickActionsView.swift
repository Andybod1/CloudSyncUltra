//
//  QuickActionsView.swift
//  CloudSyncApp
//
//  Quick Actions menu accessible via Cmd+Shift+N
//

import SwiftUI

// MARK: - Quick Action Model

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let shortcut: String
    let action: QuickActionType

    enum QuickActionType {
        case newSyncTask
        case addRemote
        case openFileBrowser
        case viewTransfers
        case openSettings
    }
}

// MARK: - Quick Actions View

struct QuickActionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedIndex = 0

    private let actions: [QuickAction] = [
        QuickAction(title: "New Sync Task", icon: "plus.circle", shortcut: "N", action: .newSyncTask),
        QuickAction(title: "Add Remote", icon: "externaldrive.badge.plus", shortcut: "R", action: .addRemote),
        QuickAction(title: "Open File Browser", icon: "folder", shortcut: "F", action: .openFileBrowser),
        QuickAction(title: "View Transfers", icon: "arrow.left.arrow.right", shortcut: "T", action: .viewTransfers),
        QuickAction(title: "Settings", icon: "gear", shortcut: ",", action: .openSettings),
    ]

    var filteredActions: [QuickAction] {
        if searchText.isEmpty { return actions }
        return actions.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search actions...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if let action = filteredActions.first {
                            performAction(action)
                        }
                    }
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Actions list
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(filteredActions.enumerated()), id: \.element.id) { index, action in
                        QuickActionRow(
                            action: action,
                            isSelected: index == selectedIndex
                        ) {
                            performAction(action)
                        }
                    }
                }
                .padding(8)
            }

            if filteredActions.isEmpty {
                VStack {
                    Spacer()
                    Text("No matching actions")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(height: 100)
            }
        }
        .frame(width: 320, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: searchText) { _, _ in
            selectedIndex = 0
        }
    }

    private func performAction(_ action: QuickAction) {
        dismiss()

        // Small delay to allow sheet to dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch action.action {
            case .newSyncTask:
                NotificationCenter.default.post(name: .showNewTask, object: nil)
            case .addRemote:
                NotificationCenter.default.post(name: .showAddRemote, object: nil)
            case .openFileBrowser:
                // Navigate to first configured remote or dashboard
                NotificationCenter.default.post(name: .navigateToFileBrowser, object: nil)
            case .viewTransfers:
                NotificationCenter.default.post(name: .navigateToTransfer, object: nil)
            case .openSettings:
                NotificationCenter.default.post(name: .navigateToSettings, object: nil)
            }
        }
    }
}

// MARK: - Quick Action Row

struct QuickActionRow: View {
    let action: QuickAction
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: action.icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                Text(action.title)
                Spacer()
                Text("\u{2318}\(action.shortcut)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                (isHovered || isSelected) ? Color.accentColor.opacity(0.1) : Color.clear
            )
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Notification Names (Quick Actions specific)

extension Notification.Name {
    // Note: showQuickActions is defined in CloudSyncAppApp.swift
    static let showAddRemote = Notification.Name("showAddRemote")
    static let navigateToFileBrowser = Notification.Name("navigateToFileBrowser")
}

#Preview {
    QuickActionsView()
}
