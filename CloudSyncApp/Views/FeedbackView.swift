//
//  FeedbackView.swift
//  CloudSyncApp
//
//  Modal form for submitting user feedback via GitHub issues
//  Issue #97: In-App Feedback Manager
//

import SwiftUI

/// Modal view for submitting user feedback
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var feedbackManager = FeedbackManager.shared

    // Form state
    @State private var selectedCategory: FeedbackCategory = .feedback
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var includeSystemInfo: Bool = true

    // UI state
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    @State private var submittedIssueURL: String = ""
    @State private var isCheckingPrerequisites = true
    @State private var ghInstalled = false
    @State private var ghAuthenticated = false

    // Validation
    private var titleIsValid: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).count >= 5
    }

    private var descriptionIsValid: Bool {
        description.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    private var canSubmit: Bool {
        titleIsValid && descriptionIsValid && !feedbackManager.isSubmitting && ghInstalled && ghAuthenticated
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Prerequisites check
                    if isCheckingPrerequisites {
                        prerequisitesCheckingView
                    } else if !ghInstalled || !ghAuthenticated {
                        prerequisitesWarningView
                    } else {
                        // Category picker
                        categoryPickerView

                        // Title field
                        titleFieldView

                        // Description field
                        descriptionFieldView

                        // System info toggle
                        systemInfoToggleView
                    }
                }
                .padding(20)
            }

            Divider()

            // Footer buttons
            footerView
        }
        .frame(width: 500, height: 520)
        .task {
            await checkPrerequisites()
        }
        .alert("Feedback Submitted", isPresented: $showSuccessAlert) {
            Button("Open in Browser") {
                if let url = URL(string: submittedIssueURL) {
                    NSWorkspace.shared.open(url)
                }
                dismiss()
            }
            Button("Close") {
                dismiss()
            }
        } message: {
            Text("Thank you for your feedback! Your issue has been created on GitHub.")
        }
        .alert("Submission Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - View Components

    private var headerView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 40, height: 40)

                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Send Feedback")
                    .font(.headline)
                Text("Help us improve CloudSync Ultra")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var prerequisitesCheckingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Checking GitHub CLI...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private var prerequisitesWarningView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Setup Required")
                    .font(.headline)
            }

            if !ghInstalled {
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("GitHub CLI (gh) is not installed")
                                .fontWeight(.medium)
                        }

                        Text("The feedback feature requires the GitHub CLI to submit issues.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Link(destination: URL(string: "https://cli.github.com")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("Install GitHub CLI")
                            }
                        }
                        .font(.caption)
                    }
                    .padding(8)
                }
            } else if !ghAuthenticated {
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Not authenticated with GitHub")
                                .fontWeight(.medium)
                        }

                        Text("Please authenticate with GitHub using the terminal command:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Text("gh auth login")
                                .font(.system(.caption, design: .monospaced))
                                .padding(6)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(4)

                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString("gh auth login", forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                            .help("Copy to clipboard")
                        }
                    }
                    .padding(8)
                }
            }

            Button("Retry Check") {
                Task {
                    await checkPrerequisites()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 12) {
                ForEach(FeedbackCategory.allCases) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    private var titleFieldView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Title")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !title.isEmpty {
                    Image(systemName: titleIsValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(titleIsValid ? .green : .red)
                        .font(.caption)
                }
            }

            TextField("Brief summary of your feedback", text: $title)
                .textFieldStyle(.roundedBorder)

            if !title.isEmpty && !titleIsValid {
                Text("Title must be at least 5 characters")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var descriptionFieldView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Description")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !description.isEmpty {
                    Image(systemName: descriptionIsValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(descriptionIsValid ? .green : .red)
                        .font(.caption)
                }
            }

            TextEditor(text: $description)
                .font(.body)
                .frame(minHeight: 120)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )

            HStack {
                if !description.isEmpty && !descriptionIsValid {
                    Text("Description must be at least 10 characters")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                Spacer()
                Text("\(description.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var systemInfoToggleView: some View {
        GroupBox {
            Toggle(isOn: $includeSystemInfo) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Include system information")
                        .fontWeight(.medium)
                    Text("Helps us diagnose issues (macOS version, app version, provider count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .toggleStyle(.checkbox)
            .padding(4)
        }
    }

    private var footerView: some View {
        HStack {
            if feedbackManager.isSubmitting {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Submitting...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape)

            Button("Submit Feedback") {
                Task {
                    await submitFeedback()
                }
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return)
            .disabled(!canSubmit)
        }
        .padding()
    }

    // MARK: - Actions

    private func checkPrerequisites() async {
        isCheckingPrerequisites = true
        ghInstalled = await feedbackManager.isGhInstalled()
        if ghInstalled {
            ghAuthenticated = await feedbackManager.isGhAuthenticated()
        }
        isCheckingPrerequisites = false
    }

    private func submitFeedback() async {
        let result = await feedbackManager.submitFeedback(
            category: selectedCategory,
            title: title,
            description: description,
            includeSystemInfo: includeSystemInfo
        )

        switch result {
        case .success(let issueURL):
            submittedIssueURL = issueURL
            showSuccessAlert = true
        case .failure(let error):
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

// MARK: - Category Button

private struct CategoryButton: View {
    let category: FeedbackCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? categoryColor.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? categoryColor : .secondary)
                }

                Text(category.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? categoryColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? categoryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var categoryColor: Color {
        switch category {
        case .bug: return .red
        case .feature: return .orange
        case .feedback: return .blue
        }
    }
}

// MARK: - Preview

#Preview {
    FeedbackView()
}
