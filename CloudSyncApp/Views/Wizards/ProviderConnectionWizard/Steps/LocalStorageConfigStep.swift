//
//  LocalStorageConfigStep.swift
//  CloudSyncApp
//
//  Configuration step for Local Storage with security-scoped bookmark support.
//  Issue #167: Local Storage security-scoped bookmarks
//

import SwiftUI

struct LocalStorageConfigStep: View {
    @Binding var selectedFolderPath: String
    @Binding var selectedFolderURL: URL?
    @Binding var bookmarkCreated: Bool
    let remoteName: String

    @State private var showFolderPicker = false
    @State private var errorMessage: String?
    @State private var isCreatingBookmark = false

    private let bookmarkManager = SecurityScopedBookmarkManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("Configure Local Storage")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    Text("Select a folder on your Mac to use as Local Storage. This folder will be accessible across app launches.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Security info
                GroupBox {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .font(.title2)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Secure Folder Access")
                                    .font(.headline)
                                Text("CloudSync Ultra uses macOS security features to safely access your folder")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Sandboxed app security", systemImage: "checkmark.shield.fill")
                            Label("Access persists across restarts", systemImage: "arrow.clockwise.circle.fill")
                            Label("You can revoke access anytime", systemImage: "xmark.shield.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                }

                // Folder selection
                GroupBox {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "folder.badge.plus")
                                .font(.title2)
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select Folder")
                                    .font(.headline)
                                Text("Choose a folder to sync with other cloud providers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }

                        Divider()

                        if selectedFolderPath.isEmpty {
                            // No folder selected
                            VStack(spacing: 16) {
                                Image(systemName: "folder.fill.badge.questionmark")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)

                                Text("No folder selected")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Button {
                                    selectFolder()
                                } label: {
                                    Label("Choose Folder...", systemImage: "folder.badge.plus")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                        } else {
                            // Folder selected
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedFolderURL?.lastPathComponent ?? "Selected Folder")
                                            .font(.headline)

                                        Text(displayPath(selectedFolderPath))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    if bookmarkCreated {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else if isCreatingBookmark {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                }
                                .padding()
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(8)

                                HStack {
                                    Button {
                                        selectFolder()
                                    } label: {
                                        Label("Change Folder", systemImage: "folder.badge.plus")
                                    }

                                    Spacer()

                                    if bookmarkCreated {
                                        Label("Bookmark saved", systemImage: "checkmark.circle")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }

                // Error message
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }

                // Tips
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Tips for Local Storage")
                                .font(.headline)
                        } icon: {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            tipRow(icon: "externaldrive.fill", text: "Use an external drive for large backups")
                            tipRow(icon: "folder.fill.badge.gearshape", text: "Choose a dedicated folder for syncing")
                            tipRow(icon: "icloud.fill", text: "Avoid folders already synced by iCloud or Dropbox")
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .padding()
        }
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func displayPath(_ path: String) -> String {
        let homePath = NSHomeDirectory()
        if path.hasPrefix(homePath) {
            return "~" + path.dropFirst(homePath.count)
        }
        return path
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.message = "Select a folder to use as Local Storage"
        panel.prompt = "Select"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                selectedFolderURL = url
                selectedFolderPath = url.path

                // Create security-scoped bookmark
                isCreatingBookmark = true
                errorMessage = nil

                // Generate a unique identifier for this local storage remote
                let identifier = "local_storage_\(remoteName.lowercased().replacingOccurrences(of: " ", with: "_"))"

                Task { @MainActor in
                    let success = bookmarkManager.createBookmark(for: url, identifier: identifier)

                    isCreatingBookmark = false
                    bookmarkCreated = success

                    if !success {
                        errorMessage = bookmarkManager.lastError?.localizedDescription ?? "Failed to create bookmark"
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var folderPath = ""
        @State var folderURL: URL?
        @State var bookmarkCreated = false

        var body: some View {
            LocalStorageConfigStep(
                selectedFolderPath: $folderPath,
                selectedFolderURL: $folderURL,
                bookmarkCreated: $bookmarkCreated,
                remoteName: "My Local Storage"
            )
            .frame(width: 700, height: 600)
        }
    }

    return PreviewWrapper()
}
