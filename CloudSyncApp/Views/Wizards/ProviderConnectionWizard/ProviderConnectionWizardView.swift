//
//  ProviderConnectionWizardView.swift
//  CloudSyncApp
//
//  Multi-step wizard for connecting cloud providers
//

import SwiftUI

/// State management for the provider connection wizard
class ProviderConnectionWizardState: ObservableObject {
    @Published var currentStep = 0
    @Published var selectedProvider: CloudProviderType?
    @Published var remoteName = ""
    @Published var username = ""
    @Published var password = ""
    @Published var twoFactorCode = ""
    @Published var isConnecting = false
    @Published var connectionError: String?
    @Published var isConnected = false

    // SFTP SSH key authentication
    @Published var sshKeyFile: String = ""
    @Published var sshKeyPassphrase: String = ""

    // FTP security options
    @Published var useFTPS: Bool = true          // Default: FTPS enabled for security
    @Published var useImplicitTLS: Bool = false  // Default: Explicit TLS (port 21)
    @Published var skipCertVerify: Bool = false  // Default: verify certificates

    // Server URL for self-hosted providers (Seafile, etc.)
    @Published var serverURL: String = ""

    // Local Storage: security-scoped bookmark support (#167)
    @Published var localFolderPath: String = ""
    @Published var localFolderURL: URL?
    @Published var localBookmarkCreated: Bool = false

    // Enterprise OAuth configuration (#161)
    @Published var useCustomOAuth: Bool = false
    @Published var customOAuthClientId: String = ""
    @Published var customOAuthClientSecret: String = ""
    @Published var customOAuthAuthURL: String = ""
    @Published var customOAuthTokenURL: String = ""

    func reset() {
        currentStep = 0
        selectedProvider = nil
        remoteName = ""
        username = ""
        password = ""
        twoFactorCode = ""
        isConnecting = false
        connectionError = nil
        isConnected = false
        sshKeyFile = ""
        sshKeyPassphrase = ""
        useFTPS = true
        useImplicitTLS = false
        skipCertVerify = false
        serverURL = ""
        localFolderPath = ""
        localFolderURL = nil
        localBookmarkCreated = false
        useCustomOAuth = false
        customOAuthClientId = ""
        customOAuthClientSecret = ""
        customOAuthAuthURL = ""
        customOAuthTokenURL = ""
    }
}

/// Main wizard view for provider connection
struct ProviderConnectionWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    @StateObject private var wizardState = ProviderConnectionWizardState()

    private let steps = ["Choose Provider", "Configure Settings", "Test Connection", "Success"]

    var body: some View {
        WizardView(
            steps: steps,
            currentStep: .init(get: { wizardState.currentStep }, set: { wizardState.currentStep = $0 }),
            onCancel: {
                dismiss()
            },
            onComplete: {
                // Add the configured remote
                if let provider = wizardState.selectedProvider {
                    // Use the same rclone name that was configured in TestConnectionStep
                    let rcloneName = wizardState.remoteName.lowercased().replacingOccurrences(of: " ", with: "_")
                    var remote = CloudRemote(
                        name: wizardState.remoteName,
                        type: provider,
                        isConfigured: true,
                        path: "",
                        customRcloneName: rcloneName
                    )
                    // Store the account email/username
                    remote.accountName = wizardState.username

                    let success = remotesVM.addRemote(remote)
                    if !success {
                        // Subscription limit reached - error is set in remotesVM
                        wizardState.connectionError = remotesVM.error
                        return
                    }
                }
                dismiss()
            }
        ) {
            // Content for current step
            switch wizardState.currentStep {
            case 0:
                ChooseProviderStep(
                    selectedProvider: $wizardState.selectedProvider,
                    remoteName: $wizardState.remoteName
                )
            case 1:
                // Local Storage uses a special configuration step with security-scoped bookmarks (#167)
                if wizardState.selectedProvider == .local {
                    LocalStorageConfigStep(
                        selectedFolderPath: $wizardState.localFolderPath,
                        selectedFolderURL: $wizardState.localFolderURL,
                        bookmarkCreated: $wizardState.localBookmarkCreated,
                        remoteName: wizardState.remoteName
                    )
                } else {
                    ConfigureSettingsStep(
                        provider: wizardState.selectedProvider ?? .googleDrive,
                        username: $wizardState.username,
                        password: $wizardState.password,
                        twoFactorCode: $wizardState.twoFactorCode,
                        sshKeyFile: $wizardState.sshKeyFile,
                        sshKeyPassphrase: $wizardState.sshKeyPassphrase,
                        useFTPS: $wizardState.useFTPS,
                        useImplicitTLS: $wizardState.useImplicitTLS,
                        skipCertVerify: $wizardState.skipCertVerify,
                        serverURL: $wizardState.serverURL,
                        useCustomOAuth: $wizardState.useCustomOAuth,
                        customOAuthClientId: $wizardState.customOAuthClientId,
                        customOAuthClientSecret: $wizardState.customOAuthClientSecret,
                        customOAuthAuthURL: $wizardState.customOAuthAuthURL,
                        customOAuthTokenURL: $wizardState.customOAuthTokenURL
                    )
                }
            case 2:
                TestConnectionStep(
                    provider: wizardState.selectedProvider ?? .googleDrive,
                    remoteName: wizardState.remoteName,
                    username: wizardState.username,
                    password: wizardState.password,
                    twoFactorCode: wizardState.twoFactorCode,
                    sshKeyFile: wizardState.sshKeyFile,
                    sshKeyPassphrase: wizardState.sshKeyPassphrase,
                    useFTPS: wizardState.useFTPS,
                    useImplicitTLS: wizardState.useImplicitTLS,
                    skipCertVerify: wizardState.skipCertVerify,
                    serverURL: wizardState.serverURL,
                    localFolderPath: wizardState.localFolderPath,  // Local Storage support (#167)
                    useCustomOAuth: wizardState.useCustomOAuth,  // Enterprise OAuth (#161)
                    customOAuthClientId: wizardState.customOAuthClientId,
                    customOAuthClientSecret: wizardState.customOAuthClientSecret,
                    customOAuthAuthURL: wizardState.customOAuthAuthURL,
                    customOAuthTokenURL: wizardState.customOAuthTokenURL,
                    isConnecting: $wizardState.isConnecting,
                    connectionError: $wizardState.connectionError,
                    isConnected: $wizardState.isConnected
                )
            case 3:
                SuccessStep(
                    provider: wizardState.selectedProvider ?? .googleDrive,
                    remoteName: wizardState.remoteName,
                    onBrowseFiles: {
                        // Add the remote first, then navigate to file browser
                        addConfiguredRemote()
                        dismiss()
                        // Navigate to file browser after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            NotificationCenter.default.post(name: .navigateToFileBrowser, object: nil)
                        }
                    },
                    onAddAnother: {
                        // Add the remote first, then reset wizard for another
                        addConfiguredRemote()
                        wizardState.reset()
                    },
                    onStartSyncing: {
                        // Add the remote first, then navigate to schedules
                        addConfiguredRemote()
                        dismiss()
                        // Navigate to schedules after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            NotificationCenter.default.post(name: NSNotification.Name("OpenScheduleSettings"), object: nil)
                        }
                    }
                )
            default:
                EmptyView()
            }
        }
    }

    private func addConfiguredRemote() {
        guard let provider = wizardState.selectedProvider else { return }
        let rcloneName = wizardState.remoteName.lowercased().replacingOccurrences(of: " ", with: "_")

        // For local storage, use the selected folder path (#167)
        let remotePath = provider == .local ? wizardState.localFolderPath : ""

        var remote = CloudRemote(
            name: wizardState.remoteName,
            type: provider,
            isConfigured: true,
            path: remotePath,
            customRcloneName: rcloneName
        )

        // For local storage, store the folder path as "account name" for display purposes
        remote.accountName = provider == .local ? wizardState.localFolderPath : wizardState.username

        _ = remotesVM.addRemote(remote)
    }
}

#Preview {
    ProviderConnectionWizardView()
        .environmentObject(RemotesViewModel.shared)
}