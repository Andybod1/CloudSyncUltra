//
//  SuccessStep.swift
//  CloudSyncApp
//
//  Step 4: Success confirmation and next steps
//

import SwiftUI

struct SuccessStep: View {
    let provider: CloudProviderType
    let remoteName: String
    let onBrowseFiles: () -> Void
    let onAddAnother: () -> Void
    let onStartSyncing: () -> Void

    @State private var showConfetti = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()

                // Success animation
                ZStack {
                // Animated circles
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(provider.brandColor.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                        .frame(width: 100 + CGFloat(index * 50), height: 100 + CGFloat(index * 50))
                        .scaleEffect(showConfetti ? 1.2 : 0.8)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: showConfetti
                        )
                }

                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showConfetti ? 1.0 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showConfetti)
            }

            // Success message
            VStack(spacing: 12) {
                Text("Successfully Connected!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(remoteName) is now ready to use")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            // Connection summary
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: provider.iconName)
                            .font(.title2)
                            .foregroundColor(provider.brandColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(remoteName)
                                .font(.headline)
                            Text(provider.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Label("Connected", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(Date.now, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: 500)

            // Next steps
            VStack(spacing: 20) {
                Text("What would you like to do next?")
                    .font(.headline)

                HStack(spacing: 16) {
                    NextStepButton(
                        icon: "folder.fill",
                        title: "Browse Files",
                        description: "Start exploring your cloud files",
                        action: onBrowseFiles
                    )

                    NextStepButton(
                        icon: "plus.circle.fill",
                        title: "Add Another",
                        description: "Connect another cloud service",
                        action: onAddAnother
                    )

                    NextStepButton(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Start Syncing",
                        description: "Set up automatic sync",
                        action: onStartSyncing
                    )
                }
            }
            .padding(.horizontal)

            Spacer()

            // Tips
            VStack(alignment: .leading, spacing: 8) {
                Label("Pro tip: You can enable end-to-end encryption for this remote in Settings → Encryption",
                      systemImage: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        }
    }
}

struct NextStepButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.blue)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 140, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(isHovered ? 0.15 : 0.05), radius: 5)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    SuccessStep(
        provider: .googleDrive,
        remoteName: "My Google Drive",
        onBrowseFiles: { },
        onAddAnother: { },
        onStartSyncing: { }
    )
    .frame(width: 700, height: 600)
}