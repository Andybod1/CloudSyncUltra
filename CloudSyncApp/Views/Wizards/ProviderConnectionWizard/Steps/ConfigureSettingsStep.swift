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

    private var needsTwoFactor: Bool {
        provider == .protonDrive
    }

    private var isICloud: Bool {
        provider == .icloud
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

                    // 2FA field for ProtonDrive
                    if needsTwoFactor {
                        HStack {
                            Text("2FA Code")
                                .frame(width: 100, alignment: .trailing)
                            TextField("123456", text: $twoFactorCode)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding()
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
            return "Use your MEGA email and password. App-specific passwords are recommended."
        default:
            return nil
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

#Preview {
    @Previewable @State var username = ""
    @Previewable @State var password = ""
    @Previewable @State var twoFactorCode = ""

    ConfigureSettingsStep(
        provider: .protonDrive,
        username: $username,
        password: $password,
        twoFactorCode: $twoFactorCode
    )
    .frame(width: 700, height: 600)
}