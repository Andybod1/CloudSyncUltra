//
//  ConfigureSettingsStep.swift
//  CloudSyncApp
//
//  Step 2: Configure provider settings and credentials
//

import SwiftUI

struct ConfigureSettingsStep: View {
    let provider: CloudProviderType
    @Binding var username: String
    @Binding var password: String
    @Binding var twoFactorCode: String
    // SFTP SSH key authentication (default bindings for non-SFTP providers)
    var sshKeyFile: Binding<String> = .constant("")
    var sshKeyPassphrase: Binding<String> = .constant("")
    // FTP security options (default bindings for non-FTP providers)
    var useFTPS: Binding<Bool> = .constant(true)
    var useImplicitTLS: Binding<Bool> = .constant(false)  // false = Explicit (port 21), true = Implicit (port 990)
    var skipCertVerify: Binding<Bool> = .constant(false)
    // Server URL for self-hosted providers (Seafile, Nextcloud, ownCloud, etc.)
    var serverURL: Binding<String> = .constant("")

    // Enterprise OAuth configuration (#161)
    var useCustomOAuth: Binding<Bool> = .constant(false)
    var customOAuthClientId: Binding<String> = .constant("")
    var customOAuthClientSecret: Binding<String> = .constant("")
    var customOAuthAuthURL: Binding<String> = .constant("")
    var customOAuthTokenURL: Binding<String> = .constant("")

    // MARK: - State Properties
    @State private var showAdvancedOAuth: Bool = false

    // MARK: - Nextcloud URL Validation State (#162)
    @State private var serverURLValidation: NextcloudURLValidation = .empty

    /// Validation state for Nextcloud/ownCloud server URLs
    enum NextcloudURLValidation: Equatable {
        case empty
        case invalid(reason: String)
        case warning(message: String)
        case valid

        var isValid: Bool {
            switch self {
            case .valid, .warning: return true
            default: return false
            }
        }
    }

    private var needsTwoFactor: Bool {
        provider == .protonDrive || provider == .mega
    }

    private var twoFactorLabel: String {
        provider == .mega ? "2FA Code\n(if enabled)" : "2FA Code"
    }

    private var isICloud: Bool {
        provider == .icloud
    }

    private var isSFTP: Bool {
        provider == .sftp
    }

    private var isFTP: Bool {
        provider == .ftp
    }

    private var isSeafile: Bool {
        provider == .seafile
    }

    private var isFileFabric: Bool {
        provider == .filefabric
    }

    private var isQuatrix: Bool {
        provider == .quatrix
    }

    private var isNextcloud: Bool {
        provider == .nextcloud
    }

    private var isOwncloud: Bool {
        provider == .owncloud
    }

    /// Whether this provider supports custom OAuth configuration (#161)
    /// Enterprise users may need to use their own OAuth app for rate limits or security policies
    private var supportsCustomOAuth: Bool {
        switch provider {
        case .googleDrive, .oneDrive, .oneDriveBusiness, .sharepoint,
             .dropbox, .box, .googleCloudStorage, .googlePhotos:
            return true
        default:
            return false
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: provider.iconName)
                        .font(.largeTitle)
                        .foregroundColor(provider.brandColor)

                    Text("Configure \(provider.displayName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Text(authenticationDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)

            if isICloud {
                // iCloud special configuration
                iCloudConfiguration
            } else if provider.requiresOAuth {
                // OAuth configuration
                oauthConfiguration
            } else {
                // Credentials configuration
                credentialsConfiguration
            }

            Spacer()
            }
            .padding()
        }
    }

    private var authenticationDescription: String {
        if isICloud {
            return "iCloud Drive can be accessed through your local Mac folder"
        } else if isFileFabric {
            return "Enter your File Fabric server URL, then authenticate via OAuth in your browser."
        } else if provider.requiresOAuth {
            return "This provider uses secure OAuth authentication. You'll be redirected to \(provider.displayName) to sign in."
        } else {
            return "Enter your credentials to connect to \(provider.displayName)"
        }
    }

    @ViewBuilder
    private var iCloudConfiguration: some View {
        VStack(spacing: 20) {
            // Local folder method
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Use Local iCloud Folder")
                                .font(.headline)
                            Text("Recommended approach - no login required")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if CloudProviderType.isLocalICloudAvailable {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }

                    if CloudProviderType.isLocalICloudAvailable {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("iCloud Drive folder detected", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Path: ~/Library/Mobile Documents/com~apple~CloudDocs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("iCloud Drive not found", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Make sure you're signed into iCloud on this Mac with iCloud Drive enabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }

            // Future Apple ID method
            GroupBox {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sign in with Apple ID")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Coming soon - will require 2FA setup")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("Phase 2")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding()
            }
            .disabled(true)
        }
    }

    @ViewBuilder
    private var oauthConfiguration: some View {
        VStack(spacing: 20) {
            // FileFabric Server URL field (required before OAuth)
            if isFileFabric {
                GroupBox {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "server.rack")
                                .font(.title2)
                                .foregroundColor(provider.brandColor)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Server Configuration")
                                    .font(.headline)
                                Text("Enter your File Fabric server URL")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Divider()

                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("File Fabric requires your organization's server URL before authentication.")
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)

                        HStack {
                            Text("Server URL")
                                .frame(width: 100, alignment: .trailing)
                            TextField("https://yourfabric.smestorage.com", text: serverURL)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding()
                }
            }

            // Account email field
            GroupBox {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(provider.brandColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Account Information")
                                .font(.headline)
                            Text("Enter your \(provider.displayName) account email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    HStack {
                        Text("Email")
                            .frame(width: 100, alignment: .trailing)
                        TextField("user@example.com", text: $username)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding()
            }

            // OAuth info
            GroupBox {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "safari")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Browser Authentication")
                                .font(.headline)
                            Text("You'll be redirected to sign in securely")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Secure OAuth 2.0 authentication", systemImage: "lock.shield.fill")
                        Label("No passwords stored locally", systemImage: "key.slash")
                        Label("Revoke access anytime from \(provider.displayName)", systemImage: "xmark.shield")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
            }

            // Enterprise OAuth Configuration (#161)
            if supportsCustomOAuth {
                enterpriseOAuthConfiguration
            }

            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("What will happen:")
                    .font(.headline)

                HStack(alignment: .top, spacing: 12) {
                    Text("1.")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("Click Next to open your browser")
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 12) {
                    Text("2.")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("Sign in to \(provider.displayName)")
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 12) {
                    Text("3.")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("Grant access to CloudSync Ultra")
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 12) {
                    Text("4.")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("Return here when complete")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
        }
    }

    // MARK: - Enterprise OAuth Configuration (#161)
    @ViewBuilder
    private var enterpriseOAuthConfiguration: some View {
        DisclosureGroup(
            isExpanded: $showAdvancedOAuth,
            content: {
                VStack(spacing: 16) {
                    // Enable custom OAuth toggle
                    Toggle(isOn: useCustomOAuth) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Use Custom OAuth App")
                                .font(.subheadline)
                            Text("Use your organization's OAuth credentials")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)

                    if useCustomOAuth.wrappedValue {
                        Divider()

                        // Help text
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.blue)
                            Text(enterpriseOAuthHelpText)
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)

                        // Client ID
                        HStack {
                            Text("Client ID")
                                .frame(width: 100, alignment: .trailing)
                            TextField("OAuth Client ID", text: customOAuthClientId)
                                .textFieldStyle(.roundedBorder)
                        }

                        // Client Secret
                        HStack {
                            Text("Client Secret")
                                .frame(width: 100, alignment: .trailing)
                            SecureField("OAuth Client Secret", text: customOAuthClientSecret)
                                .textFieldStyle(.roundedBorder)
                        }

                        // Optional: Custom Auth URL (for Azure AD / custom identity providers)
                        if provider == .oneDriveBusiness || provider == .sharepoint {
                            HStack {
                                Text("Auth URL")
                                    .frame(width: 100, alignment: .trailing)
                                TextField("https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize", text: customOAuthAuthURL)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Token URL")
                                    .frame(width: 100, alignment: .trailing)
                                TextField("https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token", text: customOAuthTokenURL)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                Text("For Azure AD: Replace {tenant} with your tenant ID or domain")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Documentation links
                        if let docURL = enterpriseOAuthDocURL {
                            Link(destination: docURL) {
                                HStack {
                                    Image(systemName: "book.fill")
                                    Text("View \(provider.displayName) OAuth documentation")
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
            },
            label: {
                HStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.orange)
                    Text("Enterprise Configuration")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("(Optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        )
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    /// Help text for enterprise OAuth configuration
    private var enterpriseOAuthHelpText: String {
        switch provider {
        case .googleDrive, .googlePhotos, .googleCloudStorage:
            return "Create a custom OAuth app in Google Cloud Console for higher rate limits or to comply with organization security policies."
        case .oneDrive, .oneDriveBusiness, .sharepoint:
            return "Register an Azure AD app for your organization to manage access centrally or when the default app is blocked."
        case .dropbox:
            return "Create a Dropbox App in the App Console for enterprise deployments with custom branding and rate limits."
        case .box:
            return "Register a custom Box app for enterprise integrations with your organization's security requirements."
        default:
            return "Use your organization's OAuth credentials for enterprise deployments."
        }
    }

    /// Documentation URL for OAuth app registration
    private var enterpriseOAuthDocURL: URL? {
        switch provider {
        case .googleDrive, .googlePhotos, .googleCloudStorage:
            return URL(string: "https://rclone.org/drive/#making-your-own-client-id")
        case .oneDrive, .oneDriveBusiness, .sharepoint:
            return URL(string: "https://rclone.org/onedrive/#getting-your-own-client-id-and-key")
        case .dropbox:
            return URL(string: "https://rclone.org/dropbox/#get-your-own-dropbox-app-id")
        case .box:
            return URL(string: "https://rclone.org/box/#getting-your-own-box-client-id-and-key")
        default:
            return nil
        }
    }

    @ViewBuilder
    private var credentialsConfiguration: some View {
        VStack(spacing: 20) {
            // Credentials form
            GroupBox {
                VStack(spacing: 16) {
                    // Provider-specific instructions
                    if let instructions = providerInstructions {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text(instructions)
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }

                    // Server URL/Host field for Nextcloud, ownCloud, Seafile, FileFabric, Quatrix (#162)
                    if isNextcloud || isOwncloud || isSeafile || isFileFabric || isQuatrix {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(isQuatrix ? "Host" : "Server URL")
                                    .frame(width: 100, alignment: .trailing)
                                TextField(
                                    nextcloudURLPlaceholder,
                                    text: serverURL
                                )
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: serverURL.wrappedValue) { _, newValue in
                                    if isNextcloud || isOwncloud {
                                        validateNextcloudURL(newValue)
                                    }
                                }
                            }

                            // Nextcloud/ownCloud URL validation feedback (#162)
                            if isNextcloud || isOwncloud {
                                nextcloudURLValidationView
                            }
                        }
                    }

                    // Username field (hide for Jottacloud and Quatrix)
                    if provider != .jottacloud && !isQuatrix {
                        HStack {
                            Text("Username")
                                .frame(width: 100, alignment: .trailing)
                            TextField("user@example.com", text: $username)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // Password/Token/API Key field
                    HStack {
                        Text(provider == .jottacloud ? "Token" : isQuatrix ? "API Key" : "Password")
                            .frame(width: 100, alignment: .trailing)
                        SecureField(
                            provider == .jottacloud ? "Personal Login Token" :
                            isQuatrix ? "Quatrix API Key" : "Password",
                            text: $password
                        )
                        .textFieldStyle(.roundedBorder)
                    }

                    // 2FA field for ProtonDrive and MEGA
                    if needsTwoFactor {
                        HStack {
                            Text(twoFactorLabel)
                                .frame(width: 100, alignment: .trailing)
                            TextField("123456", text: $twoFactorCode)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding()
            }

            // SFTP SSH Key Authentication (optional)
            if isSFTP {
                GroupBox {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .font(.title2)
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("SSH Key Authentication (Optional)")
                                    .font(.headline)
                                Text("Use an SSH key instead of or in addition to password")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }

                        Divider()

                        // SSH Key File picker
                        HStack {
                            Text("Key File")
                                .frame(width: 100, alignment: .trailing)
                            TextField("No key file selected", text: sshKeyFile)
                                .textFieldStyle(.roundedBorder)
                                .disabled(true)
                            Button("Browse...") {
                                selectSSHKeyFile()
                            }
                            if !sshKeyFile.wrappedValue.isEmpty {
                                Button {
                                    sshKeyFile.wrappedValue = ""
                                    sshKeyPassphrase.wrappedValue = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Key Passphrase field (only shown when key file is selected)
                        if !sshKeyFile.wrappedValue.isEmpty {
                            HStack {
                                Text("Passphrase")
                                    .frame(width: 100, alignment: .trailing)
                                SecureField("Key passphrase (if encrypted)", text: sshKeyPassphrase)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                Text("Leave passphrase empty if your key is not encrypted")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }

            // FTP Security Configuration
            if isFTP {
                GroupBox {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .font(.title2)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Connection Security")
                                    .font(.headline)
                                Text("Configure encryption for your FTP connection")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }

                        Divider()

                        // Enable FTPS toggle
                        Toggle(isOn: useFTPS) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enable FTPS (Secure)")
                                    .font(.subheadline)
                                Text("Encrypt your connection using TLS/SSL")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // TLS mode picker (only shown when FTPS is enabled)
                        if useFTPS.wrappedValue {
                            HStack {
                                Text("TLS Mode")
                                    .frame(width: 100, alignment: .trailing)
                                Picker("", selection: useImplicitTLS) {
                                    Text("Explicit (Port 21)").tag(false)
                                    Text("Implicit (Port 990)").tag(true)
                                }
                                .pickerStyle(.segmented)
                            }

                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                Text(useImplicitTLS.wrappedValue
                                     ? "Implicit TLS connects on port 990 with immediate encryption"
                                     : "Explicit TLS (STARTTLS) upgrades a plain connection to encrypted")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            // Skip certificate verification toggle
                            Toggle(isOn: skipCertVerify) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Skip certificate verification")
                                        .font(.subheadline)
                                    Text("Use for self-signed certificates (less secure)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Plain FTP warning
                        if !useFTPS.wrappedValue {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Plain FTP transmits passwords without encryption.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    .padding()
                }
            }

            // Security note
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                Text("Your credentials are stored securely in the macOS Keychain")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Provider-specific help links
            if let helpURL = providerHelpURL {
                Link("Need help? View \(provider.displayName) setup guide",
                     destination: helpURL)
                    .font(.caption)
            }
        }
    }

    private var providerInstructions: String? {
        switch provider {
        case .jottacloud:
            return "Jottacloud requires a Personal Login Token, not your password. Click the link below to generate one."
        case .protonDrive:
            return "Enter your Proton email, password, and current 2FA code from your authenticator app."
        case .s3:
            return "Enter your AWS Access Key ID as username and Secret Access Key as password."
        case .mega:
            return "Use your MEGA email and password. If you have 2FA enabled, enter the current code from your authenticator app."
        case .sftp:
            return "Enter your SSH host and username. You can authenticate with password, SSH key, or both."
        case .ftp:
            return "Enter your FTP server host and credentials. FTPS is recommended for secure connections."
        case .opendrive:
            return "Enter your OpenDrive account email and password."
        case .azureFiles:
            return "Enter your Azure Storage Account name as username and Access Key as password."
        case .seafile:
            return "Enter your Seafile server URL (e.g., https://cloud.seafile.com), email, and password."
        case .filefabric:
            return "Enter your File Fabric server URL (e.g., https://yourfabric.smestorage.com), then authenticate via OAuth."
        case .alibabaOSS:
            return "Enter your Alibaba Cloud Access Key ID as username and Access Key Secret as password. Create keys in the RAM Console. Default region is Singapore (ap-southeast-1)."
        case .mailRuCloud:
            return "Mail.ru requires an App Password. Create one at: Settings → Security → App Passwords."
        case .quatrix:
            return "Enter your Quatrix host (e.g., yourcompany.quatrix.it) without https://. Generate an API key at your Quatrix profile under API Keys."
        case .nextcloud:
            return "Enter your Nextcloud server URL including https:// (e.g., https://cloud.example.com). Use your Nextcloud username and password, or an App Password if you have 2FA enabled."
        case .owncloud:
            return "Enter your ownCloud server URL including https:// (e.g., https://cloud.example.com). Use your ownCloud username and password."
        default:
            return nil
        }
    }

    /// Opens NSOpenPanel to select an SSH private key file
    private func selectSSHKeyFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.message = "Select your SSH private key file"
        panel.prompt = "Select Key"
        panel.showsHiddenFiles = true

        // Start in ~/.ssh directory if it exists
        let sshDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh")
        if FileManager.default.fileExists(atPath: sshDir.path) {
            panel.directoryURL = sshDir
        }

        panel.begin { response in
            if response == .OK, let url = panel.url {
                sshKeyFile.wrappedValue = url.path
            }
        }
    }

    private var providerHelpURL: URL? {
        switch provider {
        case .jottacloud:
            return URL(string: "https://www.jottacloud.com/web/secure")
        case .protonDrive:
            return URL(string: "https://proton.me/support/proton-drive")
        case .s3:
            return URL(string: "https://aws.amazon.com/iam/")
        case .alibabaOSS:
            return URL(string: "https://ram.console.aliyun.com/")
        case .mailRuCloud:
            return URL(string: "https://account.mail.ru/user/2-step-auth/passwords")
        case .quatrix:
            return URL(string: "https://docs.maytech.net/quatrix/quatrix-administration-guide/my-account/api-keys")
        case .nextcloud:
            return URL(string: "https://docs.nextcloud.com/server/latest/user_manual/en/files/access_webdav.html")
        case .owncloud:
            return URL(string: "https://doc.owncloud.com/server/next/user_manual/files/access_webdav.html")
        default:
            return nil
        }
    }

    // MARK: - Nextcloud URL Validation Helpers (#162)

    /// Placeholder text for the server URL field based on provider
    private var nextcloudURLPlaceholder: String {
        switch provider {
        case .nextcloud:
            return "https://cloud.example.com"
        case .owncloud:
            return "https://cloud.example.com"
        case .seafile:
            return "https://cloud.seafile.com"
        case .quatrix:
            return "yourcompany.quatrix.it"
        case .filefabric:
            return "https://yourfabric.smestorage.com"
        default:
            return "https://example.com"
        }
    }

    /// Validates the Nextcloud/ownCloud server URL and updates validation state
    private func validateNextcloudURL(_ urlString: String) {
        // Empty URL
        guard !urlString.trimmingCharacters(in: .whitespaces).isEmpty else {
            serverURLValidation = .empty
            return
        }

        let trimmed = urlString.trimmingCharacters(in: .whitespaces)

        // Check for missing protocol
        if !trimmed.lowercased().hasPrefix("http://") && !trimmed.lowercased().hasPrefix("https://") {
            serverURLValidation = .invalid(reason: "URL must start with https:// (e.g., https://\(trimmed))")
            return
        }

        // Check for http:// (insecure)
        if trimmed.lowercased().hasPrefix("http://") && !trimmed.lowercased().hasPrefix("https://") {
            serverURLValidation = .warning(message: "Using HTTP is not recommended. Consider using HTTPS for secure connections.")
        }

        // Try to parse as URL
        guard let url = URL(string: trimmed) else {
            serverURLValidation = .invalid(reason: "Invalid URL format. Please enter a valid server address.")
            return
        }

        // Check for valid host
        guard let host = url.host, !host.isEmpty else {
            serverURLValidation = .invalid(reason: "URL must include a server address (e.g., cloud.example.com)")
            return
        }

        // Check for common mistakes
        if trimmed.contains("/remote.php/webdav") || trimmed.contains("/remote.php/dav") {
            serverURLValidation = .warning(message: "Just enter the base URL without /remote.php/webdav - we'll add the WebDAV path automatically.")
            return
        }

        // Check for trailing slash (minor warning)
        if trimmed.hasSuffix("/") {
            // Auto-clean: This is handled, just note it
            serverURLValidation = .valid
            return
        }

        // Check for localhost (common dev setup)
        if host == "localhost" || host == "127.0.0.1" {
            serverURLValidation = .warning(message: "Connecting to localhost. Make sure your server is running.")
            return
        }

        // Valid URL
        if serverURLValidation != .warning(message: "Using HTTP is not recommended. Consider using HTTPS for secure connections.") {
            serverURLValidation = .valid
        }
    }

    /// View showing URL validation status for Nextcloud/ownCloud
    @ViewBuilder
    private var nextcloudURLValidationView: some View {
        switch serverURLValidation {
        case .empty:
            EmptyView()
        case .invalid(let reason):
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                Text(reason)
                    .font(.caption)
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 104)
        case .warning(let message):
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 104)
        case .valid:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("URL format looks good")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.leading, 104)
        }
    }
}

struct ConfigureSettingsStep_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var username = ""
        @State var password = ""
        @State var twoFactorCode = ""
        @State var sshKeyFile = ""
        @State var sshKeyPassphrase = ""

        var body: some View {
            ConfigureSettingsStep(
                provider: .sftp,
                username: $username,
                password: $password,
                twoFactorCode: $twoFactorCode,
                sshKeyFile: $sshKeyFile,
                sshKeyPassphrase: $sshKeyPassphrase
            )
            .frame(width: 700, height: 600)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}