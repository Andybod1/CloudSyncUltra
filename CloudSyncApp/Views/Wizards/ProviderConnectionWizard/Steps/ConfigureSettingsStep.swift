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

                    // Username field (hide for Jottacloud)
                    if provider != .jottacloud {
                        HStack {
                            Text("Username")
                                .frame(width: 100, alignment: .trailing)
                            TextField("user@example.com", text: $username)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // Password field
                    HStack {
                        Text(provider == .jottacloud ? "Token" : "Password")
                            .frame(width: 100, alignment: .trailing)
                        SecureField(
                            provider == .jottacloud ? "Personal Login Token" : "Password",
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
        default:
            return nil
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