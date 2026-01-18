//
//  TestConnectionStep.swift
//  CloudSyncApp
//
//  Step 3: Test the connection to the cloud provider
//

import SwiftUI

struct TestConnectionStep: View {
    let provider: CloudProviderType
    let remoteName: String
    let username: String
    let password: String
    let twoFactorCode: String
    // SFTP SSH key authentication
    let sshKeyFile: String
    let sshKeyPassphrase: String
    // FTP security options
    let useFTPS: Bool
    let useImplicitTLS: Bool
    let skipCertVerify: Bool
    @Binding var isConnecting: Bool
    @Binding var connectionError: String?
    @Binding var isConnected: Bool

    @State private var testPhase = TestPhase.preparing
    @State private var testProgress: Double = 0
    @State private var progressTimer: Timer?

    enum TestPhase {
        case preparing
        case authenticating
        case verifying
        case listingFiles
        case complete
        case failed

        var description: String {
            switch self {
            case .preparing:
                return "Preparing connection..."
            case .authenticating:
                return "Authenticating with \(CloudProviderType.googleDrive.displayName)..."
            case .verifying:
                return "Verifying credentials..."
            case .listingFiles:
                return "Testing file access..."
            case .complete:
                return "Connection successful!"
            case .failed:
                return "Connection failed"
            }
        }

        var icon: String {
            switch self {
            case .preparing:
                return "gear"
            case .authenticating:
                return "key.fill"
            case .verifying:
                return "checkmark.shield.fill"
            case .listingFiles:
                return "folder.fill"
            case .complete:
                return "checkmark.circle.fill"
            case .failed:
                return "xmark.circle.fill"
            }
        }

        var iconColor: Color {
            switch self {
            case .complete:
                return .green
            case .failed:
                return .red
            default:
                return .blue
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Testing Connection")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Verifying your connection to \(provider.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)

            Spacer()

            // Connection animation and status
            VStack(spacing: 32) {
                // Animated icon
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 120, height: 120)

                    // Progress circle
                    Circle()
                        .trim(from: 0, to: testProgress)
                        .stroke(testPhase.iconColor, lineWidth: 4)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: testProgress)

                    // Center icon
                    Image(systemName: testPhase.icon)
                        .font(.system(size: 48))
                        .foregroundColor(testPhase.iconColor)
                        .scaleEffect(testPhase == .complete ? 1.2 : 1.0)
                        .animation(.spring(), value: testPhase)
                }

                // Status text
                VStack(spacing: 8) {
                    Text(getPhaseDescription())
                        .font(.headline)
                        .foregroundColor(testPhase == .failed ? .red : .primary)

                    if let error = connectionError, testPhase == .failed {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                // Progress steps
                VStack(alignment: .leading, spacing: 12) {
                    TestStepRow(
                        title: "Initialize connection",
                        isComplete: testProgress > 0.25,
                        isActive: testPhase == .preparing
                    )

                    TestStepRow(
                        title: "Authenticate credentials",
                        isComplete: testProgress > 0.5,
                        isActive: testPhase == .authenticating
                    )

                    TestStepRow(
                        title: "Verify access permissions",
                        isComplete: testProgress > 0.75,
                        isActive: testPhase == .verifying
                    )

                    TestStepRow(
                        title: "Test file operations",
                        isComplete: testProgress >= 1.0,
                        isActive: testPhase == .listingFiles
                    )
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)

                // Retry button for failed connections
                if testPhase == .failed {
                    Button("Retry Connection") {
                        startConnectionTest()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Spacer()
            }
            .padding()
        }
        .onAppear {
            startConnectionTest()
        }
        .onDisappear {
            progressTimer?.invalidate()
        }
    }

    private func getPhaseDescription() -> String {
        switch testPhase {
        case .preparing:
            return "Preparing connection..."
        case .authenticating:
            return "Authenticating with \(provider.displayName)..."
        case .verifying:
            return "Verifying credentials..."
        case .listingFiles:
            return "Testing file access..."
        case .complete:
            return "Connection successful!"
        case .failed:
            return "Connection failed"
        }
    }

    private func startConnectionTest() {
        // Reset state
        testPhase = .preparing
        testProgress = 0
        connectionError = nil
        isConnecting = true

        // Simulate connection test with progress
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateTestProgress()
        }

        // Start actual connection test
        Task {
            await performConnectionTest()
        }
    }

    private func updateTestProgress() {
        guard testPhase != .complete && testPhase != .failed else {
            progressTimer?.invalidate()
            return
        }

        testProgress += 0.02

        // Update phase based on progress
        switch testProgress {
        case 0..<0.25:
            testPhase = .preparing
        case 0.25..<0.5:
            testPhase = .authenticating
        case 0.5..<0.75:
            testPhase = .verifying
        case 0.75..<1.0:
            testPhase = .listingFiles
        default:
            break
        }
    }

    private func performConnectionTest() async {
        do {
            // Actually configure the remote with rclone
            try await configureRemoteWithRclone()

            // Connection successful
            await MainActor.run {
                testProgress = 1.0
                testPhase = .complete
                isConnected = true
                isConnecting = false
                progressTimer?.invalidate()
            }
        } catch {
            await MainActor.run {
                testPhase = .failed
                connectionError = "Failed to connect: \(error.localizedDescription)"
                isConnecting = false
                progressTimer?.invalidate()
            }
        }
    }

    private func configureRemoteWithRclone() async throws {
        let rclone = RcloneManager.shared
        // Use remoteName as the rclone config name (sanitized)
        let rcloneName = remoteName.lowercased().replacingOccurrences(of: " ", with: "_")

        switch provider {
        case .icloud:
            // iCloud uses local folder, no rclone config needed
            break
        case .protonDrive:
            try await rclone.setupProtonDrive(
                username: username,
                password: password,
                twoFactorCode: twoFactorCode.isEmpty ? nil : twoFactorCode,
                remoteName: rcloneName
            )
        case .googleDrive:
            try await rclone.setupGoogleDrive(remoteName: rcloneName)
        case .dropbox:
            try await rclone.setupDropbox(remoteName: rcloneName)
        case .oneDrive:
            try await rclone.setupOneDrive(remoteName: rcloneName)
        case .s3:
            try await rclone.setupS3(remoteName: rcloneName, accessKey: username, secretKey: password)
        case .mega:
            try await rclone.setupMega(
                remoteName: rcloneName,
                username: username,
                password: password,
                mfaCode: twoFactorCode.isEmpty ? nil : twoFactorCode
            )
        case .box:
            try await rclone.setupBox(remoteName: rcloneName)
        case .pcloud:
            try await rclone.setupPCloud(remoteName: rcloneName)
        case .webdav:
            try await rclone.setupWebDAV(remoteName: rcloneName, url: username, password: password)
        case .owncloud:
            // Construct WebDAV URL: {baseURL}/remote.php/webdav/
            let owncloudWebdavURL = username.hasSuffix("/") ? "\(username)remote.php/webdav/" : "\(username)/remote.php/webdav/"
            try await rclone.setupOwnCloud(
                remoteName: rcloneName,
                url: owncloudWebdavURL,
                username: username,  // Note: username field is used for server URL in WebDAV providers
                password: password
            )
        case .nextcloud:
            // Construct WebDAV URL: {baseURL}/remote.php/webdav/
            let nextcloudWebdavURL = username.hasSuffix("/") ? "\(username)remote.php/webdav/" : "\(username)/remote.php/webdav/"
            try await rclone.setupNextcloud(
                remoteName: rcloneName,
                url: nextcloudWebdavURL,
                username: username,  // Note: username field is used for server URL in WebDAV providers
                password: password
            )
        case .sftp:
            try await rclone.setupSFTP(
                remoteName: rcloneName,
                host: username,
                password: password,
                keyFile: sshKeyFile,
                keyPassphrase: sshKeyPassphrase
            )
        case .ftp:
            try await rclone.setupFTP(
                remoteName: rcloneName,
                host: username,
                password: password,
                useTLS: useFTPS && !useImplicitTLS,  // Explicit TLS when FTPS enabled and not implicit
                useImplicitTLS: useFTPS && useImplicitTLS,  // Implicit TLS when both FTPS and implicit are enabled
                skipCertVerify: skipCertVerify
            )
        case .jottacloud:
            try await rclone.setupJottacloud(remoteName: rcloneName, personalLoginToken: password)
        case .googlePhotos:
            try await rclone.setupGooglePhotos(remoteName: rcloneName)
        case .sugarsync:
            try await rclone.setupSugarSync(remoteName: rcloneName)
        case .opendrive:
            try await rclone.setupOpenDrive(
                remoteName: rcloneName,
                username: username,
                password: password
            )
        case .putio:
            try await rclone.setupPutio(remoteName: rcloneName)
        case .premiumizeme:
            try await rclone.setupPremiumizeme(remoteName: rcloneName)
        case .quatrix:
            try await rclone.setupQuatrix(remoteName: rcloneName)
        case .filefabric:
            try await rclone.setupFileFabric(remoteName: rcloneName)
        case .azureFiles:
            // Azure Files uses account name and key
            try await rclone.setupAzureFiles(
                remoteName: rcloneName,
                accountName: username,
                accountKey: password
            )
        default:
            throw RcloneError.configurationFailed("Provider \(provider.displayName) not yet supported")
        }
    }
}

struct TestStepRow: View {
    let title: String
    let isComplete: Bool
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if isActive {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }

            Text(title)
                .font(.subheadline)
                .foregroundColor(isComplete ? .primary : .secondary)

            Spacer()
        }
    }
}

struct TestConnectionStep_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var isConnecting = false
        @State var connectionError: String?
        @State var isConnected = false

        var body: some View {
            TestConnectionStep(
                provider: .sftp,
                remoteName: "My SFTP Server",
                username: "server.example.com",
                password: "password",
                twoFactorCode: "",
                sshKeyFile: "",
                sshKeyPassphrase: "",
                useFTPS: true,
                useImplicitTLS: false,
                skipCertVerify: false,
                isConnecting: $isConnecting,
                connectionError: $connectionError,
                isConnected: $isConnected
            )
            .frame(width: 700, height: 600)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}