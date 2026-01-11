//
//  ProtonDriveSetupView.swift
//  CloudSyncApp
//
//  Dedicated setup view for Proton Drive with full authentication support
//

import SwiftUI

struct ProtonDriveSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    
    // Form fields
    @State private var username = ""
    @State private var password = ""
    @State private var twoFactorMode: TwoFactorMode = .none
    @State private var twoFactorCode = ""
    @State private var otpSecretKey = ""
    @State private var mailboxPassword = ""
    @State private var showAdvanced = false
    
    // State
    @State private var isConfiguring = false
    @State private var isTesting = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showPrerequisites = true
    
    let remote: CloudRemote
    var onSuccess: ((CloudRemote) -> Void)?
    
    enum TwoFactorMode: String, CaseIterable, Identifiable {
        case none = "None"
        case code = "Single Code"
        case totp = "TOTP Secret"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .none: return "No 2FA configured"
            case .code: return "Enter a 6-digit code from your authenticator"
            case .totp: return "Enter your TOTP secret for automatic code generation (recommended)"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                if showPrerequisites {
                    prerequisitesSection
                }
                
                // Credentials Section
                credentialsSection
                
                // 2FA Section
                twoFactorSection
                
                // Advanced Section
                advancedSection
                
                // Messages
                messagesSection
                
                // Actions
                actionsSection
            }
            .padding()
        }
        .frame(width: 500, height: 650)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.42, green: 0.31, blue: 0.78).opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "shield.checkered")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 0.42, green: 0.31, blue: 0.78))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Connect Proton Drive")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("End-to-end encrypted cloud storage")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Prerequisites
    
    private var prerequisitesSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Before You Begin")
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    prerequisiteItem(
                        number: "1",
                        text: "Log in to Proton Drive via your web browser at least once"
                    )
                    prerequisiteItem(
                        number: "2",
                        text: "This generates the encryption keys required by rclone"
                    )
                    prerequisiteItem(
                        number: "3",
                        text: "If you have 2FA enabled, have your authenticator ready"
                    )
                }
                
                HStack {
                    Spacer()
                    Button("I've Done This") {
                        withAnimation {
                            showPrerequisites = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.42, green: 0.31, blue: 0.78))
                }
            }
            .padding(8)
        }
    }
    
    private func prerequisiteItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 18, height: 18)
                .background(Color(red: 0.42, green: 0.31, blue: 0.78))
                .clipShape(Circle())
            
            Text(text)
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Credentials
    
    private var credentialsSection: some View {
        GroupBox("Account Credentials") {
            VStack(spacing: 16) {
                HStack {
                    Text("Email")
                        .frame(width: 100, alignment: .trailing)
                    TextField("your@proton.me", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    Text("Password")
                        .frame(width: 100, alignment: .trailing)
                    SecureField("Account password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(8)
        }
    }
    
    // MARK: - Two Factor
    
    private var twoFactorSection: some View {
        GroupBox("Two-Factor Authentication") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("2FA Mode", selection: $twoFactorMode) {
                    ForEach(TwoFactorMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(twoFactorMode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                switch twoFactorMode {
                case .none:
                    EmptyView()
                    
                case .code:
                    HStack {
                        Text("Code")
                            .frame(width: 100, alignment: .trailing)
                        TextField("123456", text: $twoFactorCode)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                        
                        Text("from authenticator app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("⚠️ Single codes expire. You may need to re-authenticate when the session ends.")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                case .totp:
                    HStack {
                        Text("TOTP Secret")
                            .frame(width: 100, alignment: .trailing)
                        SecureField("ABCDEFGHIJKLMNOP...", text: $otpSecretKey)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("✅ Recommended: The secret allows automatic code generation")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Find this in your Proton account security settings when you set up 2FA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
        }
    }
    
    // MARK: - Advanced
    
    private var advancedSection: some View {
        DisclosureGroup("Advanced Options", isExpanded: $showAdvanced) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Mailbox Password")
                        .frame(width: 120, alignment: .trailing)
                    SecureField("For two-password accounts", text: $mailboxPassword)
                        .textFieldStyle(.roundedBorder)
                }
                
                Text("Only needed if you use Proton's two-password mode (separate login and mailbox passwords)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Messages
    
    @ViewBuilder
    private var messagesSection: some View {
        if let error = errorMessage {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(error)
                    .foregroundColor(.red)
            }
            .font(.callout)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
        
        if let success = successMessage {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(success)
                    .foregroundColor(.green)
            }
            .font(.callout)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Actions
    
    private var actionsSection: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            // Test Connection
            Button {
                Task { await testConnection() }
            } label: {
                HStack(spacing: 4) {
                    if isTesting {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Text("Test Connection")
                }
            }
            .buttonStyle(.bordered)
            .disabled(username.isEmpty || password.isEmpty || isTesting || isConfiguring)
            
            // Connect
            Button {
                Task { await connect() }
            } label: {
                HStack(spacing: 4) {
                    if isConfiguring {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Text("Connect")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.42, green: 0.31, blue: 0.78))
            .disabled(username.isEmpty || password.isEmpty || isTesting || isConfiguring)
        }
    }
    
    // MARK: - Actions
    
    private func testConnection() async {
        isTesting = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let result = try await RcloneManager.shared.testProtonDriveConnection(
                username: username,
                password: password,
                twoFactorCode: get2FACode(),
                mailboxPassword: mailboxPassword.isEmpty ? nil : mailboxPassword
            )
            
            if result.success {
                successMessage = result.message
            } else {
                errorMessage = result.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isTesting = false
    }
    
    private func connect() async {
        isConfiguring = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await RcloneManager.shared.setupProtonDrive(
                username: username,
                password: password,
                twoFactorCode: twoFactorMode == .code ? twoFactorCode : nil,
                otpSecretKey: twoFactorMode == .totp ? otpSecretKey : nil,
                mailboxPassword: mailboxPassword.isEmpty ? nil : mailboxPassword
            )
            
            // Update the remote
            var updated = remote
            updated.isConfigured = true
            updated.customRcloneName = "proton"
            
            onSuccess?(updated)
            
            successMessage = "Connected successfully!"
            
            // Auto-dismiss after success
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            dismiss()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isConfiguring = false
    }
    
    private func get2FACode() -> String? {
        switch twoFactorMode {
        case .none:
            return nil
        case .code:
            return twoFactorCode.isEmpty ? nil : twoFactorCode
        case .totp:
            // For testing, we pass the OTP secret as the 2FA code
            // The test method will handle it appropriately
            return otpSecretKey.isEmpty ? nil : otpSecretKey
        }
    }
}

// MARK: - Preview

#Preview {
    ProtonDriveSetupView(
        remote: CloudRemote(name: "Proton Drive", type: .protonDrive)
    )
}
