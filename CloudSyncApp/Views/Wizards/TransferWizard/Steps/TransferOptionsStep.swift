//
//  TransferOptionsStep.swift
//  CloudSyncApp
//
//  Step 3: Configure transfer options
//

import SwiftUI

struct TransferOptionsStep: View {
    @ObservedObject var state: TransferWizardState

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                // Header
                VStack(spacing: AppTheme.spacingS) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 60, height: 60)

                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.purple)
                    }

                    Text("Configure Transfer")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Set the transfer options and give it a name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Transfer Name
                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    Label("Transfer Name", systemImage: "tag")
                        .font(.headline)

                    TextField("My Transfer", text: $state.transferName)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Transfer Name")
                        .accessibilityHint("Enter a name to identify this transfer")

                    if state.transferName.isEmpty {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text("Please enter a name for this transfer")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Transfer Mode Selection
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Transfer Mode", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)

                    VStack(spacing: AppTheme.spacingS) {
                        ForEach(TaskType.allCases, id: \.self) { mode in
                            TransferModeCard(
                                mode: mode,
                                isSelected: state.transferMode == mode
                            ) {
                                state.transferMode = mode
                            }
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Start Options
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Options", systemImage: "slider.horizontal.3")
                        .font(.headline)

                    Toggle(isOn: $state.startImmediately) {
                        HStack(spacing: AppTheme.spacingXS) {
                            Image(systemName: state.startImmediately ? "play.circle.fill" : "pause.circle")
                                .foregroundColor(state.startImmediately ? .green : .secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Start Transfer Immediately")
                                Text(state.startImmediately ? "Transfer will begin right after setup" : "Transfer will be queued for later")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .accessibilityLabel("Start transfer immediately")
                    .accessibilityHint(state.startImmediately ? "Transfer will start immediately" : "Transfer will be queued")
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)
            }
            .padding()
        }
    }
}

/// Card for selecting transfer mode
struct TransferModeCard: View {
    let mode: TaskType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacingM) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(modeDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.windowBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.rawValue)
        .accessibilityHint(modeDescription)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var modeDescription: String {
        switch mode {
        case .transfer:
            return "One-way copy of new and changed files to destination"
        case .sync:
            return "Two-way sync keeps both locations identical"
        case .backup:
            return "Creates a backup copy with versioning support"
        }
    }
}

#Preview {
    TransferOptionsStep(state: TransferWizardState())
        .frame(width: 700, height: 600)
}
