//
//  ProtonDriveSetupView.swift
//  CloudSyncApp
//
//  Dedicated setup view for Proton Drive with full authentication support,
//  credential storage, and connection management.
//

import SwiftUI

struct ProtonDriveSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    @StateObject private var protonManager = ProtonDriveManager.shared
    
    // Form fields
    @State private var username = ""
    @State private var password = ""
    @State private var twoFactorMode: TwoFactorMode = .none
    @State private var twoFactorCode = ""
    @State private var otpSecretKey = ""
    @State private var mailboxPassword = ""
    @State private var showAdvanced = false
    @State private var rememberCredentials = true
    
    // State
    @State private var isConfiguring = false
    @State private var isTesting = false
    @State private var testResult: TestResult?
    @State private var showPrerequisites = true
    @State private var currentStep: SetupStep = .prerequisites
    
    let remote: CloudRemote
    var onSuccess: ((CloudRemote) -> Void)?
    
    enum TwoFactorMode: String, CaseIterable, Identifiable {
        case none = "None"
        case code = "Single Code"
        case totp = "TOTP Secret"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .none: return "lock.open"
            case .code: return "number.circle"
            case .totp: return "key.fill"
            }
        }
        
        var description: String {
            switch self {
            case .none: return "No two-factor authentication"
            case .code: return "Enter a 6-digit code from your authenticator app"
            case .totp: return "Enter your TOTP secret for automatic code generation"
            }
        }
    }
    
    enum SetupStep {
        case prerequisites
        case credentials
        case connected
    }
    
    struct TestResult {
        let success: Bool
        let message: String
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding()
            
            Divider()
            
            // Content based on step
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch currentStep {
                    case .prerequisites:
                        prerequisitesSection
                    case .credentials:
                        credentialsForm
                    case .connected:
                        connectedSection
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer actions
            footerActions
                .padding()
        }
        .frame(width: 520, height: 680)
        .onAppear {
            checkExistingConnection()
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.42, green: 0.31, blue: 0.78),
                                Color(red: 0.55, green: 0.35, blue: 0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "shield.checkered")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Proton Drive")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 6) {
                    connectionStatusBadge
                    
                    if let lastCheck = protonManager.lastConnectionCheck {
                        Text("• Last checked \(lastCheck.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Step indicator
            stepIndicator
        }
    }
    
    private var connectionStatusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(protonManager.connectionState.statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch protonManager.connectionState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .error, .sessionExpired: return .red
        }
    }
    
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(stepIndex >= index ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private var stepIndex: Int {
        switch currentStep {
        case .prerequisites: return 0
        case .credentials: return 1
        case .connected: return 2
        }
    }
    
    // MARK: - Prerequisites
    
    private var prerequisitesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Warning card
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("Before You Connect")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        prerequisiteRow(
                            icon: "globe",
                            title: "Log in via Browser First",
                            description: "Visit drive.proton.me and log in to generate encryption keys"
                        )
                        
                        prerequisiteRow(
                            icon: "key.fill",
                            title: "Encryption Keys Required",
                            description: "Proton generates keys on first browser login - this can't be done via API"
                        )
                        
                        prerequisiteRow(
                            icon: "iphone",
                            title: "Have 2FA Ready",
                            description: "If you use two-factor authentication, have your authenticator ready"
                        )
                    }
                }
                .padding(8)
            }
            
            // Quick link to Proton Drive
            Link(destination: URL(string: "https://drive.proton.me")!) {
                HStack {
                    Image(systemName: "safari")
                    Text("Open Proton Drive in Browser")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .padding(12)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Check for saved credentials
            if protonManager.hasSavedCredentials {
                savedCredentialsCard
            }
        }
    }
    
    private func prerequisiteRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var savedCredentialsCard: some View {
        GroupBox {
            HStack(spacing: 12) {
                Image(systemName: "person.badge.key.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved Credentials Found")
                        .fontWeight(.semibold)
                    
                    if let savedUsername = protonManager.getSavedUsername() {
                        Text(savedUsername)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Reconnect") {
                    Task { await quickReconnect() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isConfiguring)
            }
            .padding(4)
        }
    }
    
    // MARK: - Credentials Form
    
    private var credentialsForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Email & Password
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    Label("Account Credentials", systemImage: "person.circle")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Email")
                                .frame(width: 110, alignment: .trailing)
                            TextField("you@proton.me", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.emailAddress)
                                .autocorrectionDisabled()
                        }
                        
                        HStack {
                            Text("Password")
                                .frame(width: 110, alignment: .trailing)
                            SecureField("Account password", text: $password)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding(8)
            }
            
            // 2FA Section
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    Label("Two-Factor Authentication", systemImage: "lock.shield")
                        .font(.headline)
                    
                    // Mode selector
                    HStack(spacing: 0) {
                        ForEach(TwoFactorMode.allCases) { mode in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    twoFactorMode = mode
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: mode.icon)
                                        .font(.caption)
                                    Text(mode.rawValue)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(twoFactorMode == mode ? Color.accentColor : Color.clear)
                                .foregroundColor(twoFactorMode == mode ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Description
                    Text(twoFactorMode.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 2FA input
                    switch twoFactorMode {
                    case .none:
                        EmptyView()
                        
                    case .code:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Code")
                                    .frame(width: 110, alignment: .trailing)
                                TextField("123456", text: $twoFactorCode)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 120)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                                Text("Single-use codes expire. Consider using TOTP secret for persistent auth.")
                                    .foregroundColor(.orange)
                            }
                            .font(.caption)
                        }
                        
                    case .totp:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("TOTP Secret")
                                    .frame(width: 110, alignment: .trailing)
                                SecureField("Base32 secret key", text: $otpSecretKey)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                Text("Recommended: Allows automatic code generation for persistent auth.")
                                    .foregroundColor(.green)
                            }
                            .font(.caption)
                        }
                    }
                }
                .padding(8)
            }
            
            // Advanced options
            DisclosureGroup(isExpanded: $showAdvanced) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Mailbox Password")
                            .frame(width: 110, alignment: .trailing)
                        SecureField("For two-password accounts", text: $mailboxPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Text("Only required if you use Proton's two-password mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            } label: {
                Label("Advanced Options", systemImage: "gearshape.2")
                    .font(.headline)
            }
            
            // Remember credentials toggle
            Toggle(isOn: $rememberCredentials) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remember credentials")
                    Text("Securely stored in macOS Keychain for quick reconnection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            
            // Test result
            if let result = testResult {
                testResultCard(result)
            }
        }
    }
    
    private func testResultCard(_ result: TestResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(result.success ? .green : .red)
            
            Text(result.message)
                .font(.callout)
                .foregroundColor(result.success ? .green : .red)
            
            Spacer()
            
            if !result.success {
                Button("Dismiss") {
                    testResult = nil
                }
                .font(.caption)
            }
        }
        .padding(12)
        .background((result.success ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Connected Section
    
    private var connectedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Success card
            GroupBox {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("Successfully Connected!")
                        .font(.headline)
                    
                    Text("Your Proton Drive is now linked to CloudSync Ultra")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            // Storage info
            if let storage = protonManager.storageInfo {
                storageInfoCard(storage)
            }
            
            // Quick actions
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Quick Actions", systemImage: "bolt.fill")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        quickActionButton(
                            icon: "folder",
                            title: "Browse Files",
                            action: { dismiss() }
                        )
                        
                        quickActionButton(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Start Sync",
                            action: { dismiss() }
                        )
                        
                        quickActionButton(
                            icon: "lock.shield",
                            title: "Setup Encryption",
                            action: { dismiss() }
                        )
                    }
                }
                .padding(8)
            }
        }
    }
    
    private func storageInfoCard(_ storage: ProtonDriveManager.StorageInfo) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Storage", systemImage: "externaldrive.fill")
                    .font(.headline)
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(storage.usagePercentage > 90 ? Color.red : Color.accentColor)
                            .frame(width: geo.size.width * CGFloat(storage.usagePercentage / 100), height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(storage.usedFormatted) used")
                    Spacer()
                    Text("\(storage.freeFormatted) free")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(storage.totalFormatted) total")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
            .padding(8)
        }
    }
    
    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Footer Actions
    
    private var footerActions: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape)
            
            Spacer()
            
            switch currentStep {
            case .prerequisites:
                Button("Continue") {
                    withAnimation {
                        currentStep = .credentials
                    }
                }
                .buttonStyle(.borderedProminent)
                
            case .credentials:
                HStack(spacing: 12) {
                    Button {
                        withAnimation {
                            currentStep = .prerequisites
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    
                    Button {
                        Task { await testConnection() }
                    } label: {
                        if isTesting {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16)
                        } else {
                            Image(systemName: "network")
                        }
                        Text("Test")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canTest || isTesting || isConfiguring)
                    
                    Button {
                        Task { await connect() }
                    } label: {
                        if isConfiguring {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16)
                        } else {
                            Image(systemName: "link")
                        }
                        Text("Connect")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canConnect || isTesting || isConfiguring)
                }
                
            case .connected:
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
        }
    }
    
    // MARK: - Validation
    
    private var canTest: Bool {
        !username.isEmpty && !password.isEmpty && is2FAValid
    }
    
    private var canConnect: Bool {
        canTest
    }
    
    private var is2FAValid: Bool {
        switch twoFactorMode {
        case .none: return true
        case .code: return twoFactorCode.count == 6
        case .totp: return !otpSecretKey.isEmpty
        }
    }
    
    // MARK: - Actions
    
    private func checkExistingConnection() {
        if protonManager.connectionState.isConnected {
            currentStep = .connected
        } else if protonManager.hasSavedCredentials {
            // Stay on prerequisites but show reconnect option
            currentStep = .prerequisites
        }
    }
    
    private func quickReconnect() async {
        isConfiguring = true
        
        do {
            try await protonManager.reconnect()
            
            var updated = remote
            updated.isConfigured = true
            updated.customRcloneName = "proton"
            onSuccess?(updated)
            
            withAnimation {
                currentStep = .connected
            }
        } catch {
            testResult = TestResult(success: false, message: error.localizedDescription)
            withAnimation {
                currentStep = .credentials
            }
        }
        
        isConfiguring = false
    }
    
    private func testConnection() async {
        isTesting = true
        testResult = nil
        
        let result = await protonManager.testConnection(
            username: username,
            password: password,
            twoFactorCode: get2FAValue(),
            mailboxPassword: mailboxPassword.isEmpty ? nil : mailboxPassword
        )
        
        testResult = TestResult(success: result.success, message: result.message)
        isTesting = false
    }
    
    private func connect() async {
        isConfiguring = true
        testResult = nil
        
        do {
            try await protonManager.connect(
                username: username,
                password: password,
                twoFactorCode: twoFactorMode == .code ? twoFactorCode : nil,
                otpSecretKey: twoFactorMode == .totp ? otpSecretKey : nil,
                mailboxPassword: mailboxPassword.isEmpty ? nil : mailboxPassword,
                saveCredentials: rememberCredentials
            )
            
            var updated = remote
            updated.isConfigured = true
            updated.customRcloneName = "proton"
            onSuccess?(updated)
            
            withAnimation {
                currentStep = .connected
            }
            
        } catch {
            testResult = TestResult(success: false, message: error.localizedDescription)
        }
        
        isConfiguring = false
    }
    
    private func get2FAValue() -> String? {
        switch twoFactorMode {
        case .none: return nil
        case .code: return twoFactorCode.isEmpty ? nil : twoFactorCode
        case .totp: return otpSecretKey.isEmpty ? nil : otpSecretKey
        }
    }
}

// MARK: - Preview

#Preview {
    ProtonDriveSetupView(
        remote: CloudRemote(name: "Proton Drive", type: .protonDrive)
    )
    .environmentObject(RemotesViewModel.shared)
}
