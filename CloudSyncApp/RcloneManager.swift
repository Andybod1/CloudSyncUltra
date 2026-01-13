//
//  RcloneManager.swift
//  CloudSyncApp
//
//  Manages rclone binary, configuration, and process execution
//

import Foundation

// MARK: - OneDrive Account Types

enum OneDriveAccountType: String {
    case personal = "onedrive"
    case business = "business"
    case sharepoint = "sharepoint"
}

class RcloneManager {
    static let shared = RcloneManager()
    
    private var rclonePath: String
    private var configPath: String
    private var process: Process?
    
    private init() {
        // Look for bundled rclone first, fall back to system rclone
        if let bundledPath = Bundle.main.path(forResource: "rclone", ofType: nil) {
            self.rclonePath = bundledPath
            // Make it executable
            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: bundledPath
            )
        } else {
            // Use system rclone (assumes installed via homebrew)
            self.rclonePath = "/opt/homebrew/bin/rclone"
        }
        
        // Store config in Application Support
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        let appFolder = appSupport.appendingPathComponent("CloudSyncApp", isDirectory: true)
        
        try? FileManager.default.createDirectory(
            at: appFolder,
            withIntermediateDirectories: true
        )
        
        self.configPath = appFolder.appendingPathComponent("rclone.conf").path
    }
    
    // MARK: - Bandwidth Throttling
    
    /// Get bandwidth limit arguments if enabled
    private func getBandwidthArgs() -> [String] {
        var args: [String] = []
        
        // Check if bandwidth limits are enabled
        if UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled") {
            let uploadLimit = UserDefaults.standard.double(forKey: "uploadLimit")
            let downloadLimit = UserDefaults.standard.double(forKey: "downloadLimit")
            
            // Add upload limit (--bwlimit-file for upload)
            if uploadLimit > 0 {
                args.append("--bwlimit")
                args.append("\(uploadLimit)M")
            }
            
            // rclone uses --bwlimit for both, but we can set different limits per operation
            // For now, we'll use the more restrictive of the two
            if downloadLimit > 0 && (uploadLimit == 0 || downloadLimit < uploadLimit) {
                args.append("--bwlimit")
                args.append("\(downloadLimit)M")
            }
        }
        
        return args
    }
    
    // MARK: - Configuration

    func isConfigured() -> Bool {
        FileManager.default.fileExists(atPath: configPath)
    }

    // MARK: - Debugging

    /// Logs the current rclone version for debugging
    func logRcloneVersion() async {
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: rclonePath)
            process.arguments = ["version"]

            let pipe = Pipe()
            process.standardOutput = pipe

            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("[RcloneManager] Rclone version: \(output.components(separatedBy: .newlines).first ?? "unknown")")
            }
        } catch {
            print("[RcloneManager] Failed to get rclone version: \(error.localizedDescription)")
        }
    }

    // MARK: - Cloud Provider Setup Methods
    
    /// Setup Proton Drive with proper password obscuring and full authentication support
    /// - Parameters:
    ///   - username: Proton account email
    ///   - password: Account password (will be obscured)
    ///   - twoFactorCode: Single-use 2FA code (optional, use for one-time setup)
    ///   - otpSecretKey: TOTP secret key for persistent 2FA (optional, recommended for 2FA accounts)
    ///   - mailboxPassword: Mailbox password for two-password accounts (optional)
    ///   - remoteName: Name for the remote in rclone config (default: "proton")
    func setupProtonDrive(
        username: String,
        password: String,
        twoFactorCode: String? = nil,
        otpSecretKey: String? = nil,
        mailboxPassword: String? = nil,
        remoteName: String = "proton"
    ) async throws {
        print("[RcloneManager] Setting up Proton Drive for: \(username)")
        
        // CRITICAL: Obscure the password - rclone requires this for protondrive
        let obscuredPassword = try await obscurePassword(password)
        print("[RcloneManager] Password obscured successfully")
        
        var params: [String: String] = [
            "username": username,
            "password": obscuredPassword
        ]
        
        // Handle 2FA - prefer OTP secret for persistent auth
        if let otpSecret = otpSecretKey, !otpSecret.isEmpty {
            // OTP secret allows rclone to generate TOTP codes automatically
            let obscuredOTP = try await obscurePassword(otpSecret)
            params["otp_secret_key"] = obscuredOTP
            print("[RcloneManager] Using OTP secret key for persistent 2FA")
        } else if let code = twoFactorCode, !code.isEmpty {
            // Single-use 2FA code (works once, then session may expire)
            params["2fa"] = code
            print("[RcloneManager] Using single-use 2FA code")
        }
        
        // Handle two-password Proton accounts
        if let mailbox = mailboxPassword, !mailbox.isEmpty {
            let obscuredMailbox = try await obscurePassword(mailbox)
            params["mailbox_password"] = obscuredMailbox
            print("[RcloneManager] Mailbox password configured")
        }
        
        // Recommended settings for better reliability
        params["replace_existing_draft"] = "true"  // Handle interrupted uploads
        params["enable_caching"] = "true"          // Improve performance
        
        // Delete existing remote if it exists (clean reconfigure)
        if isRemoteConfigured(name: remoteName) {
            print("[RcloneManager] Removing existing '\(remoteName)' remote")
            try? await deleteRemote(name: remoteName)
        }
        
        try await createRemote(
            name: remoteName,
            type: "protondrive",
            parameters: params
        )
        
        print("[RcloneManager] Proton Drive remote '\(remoteName)' created successfully!")
    }
    
    /// Test Proton Drive connection without creating a persistent remote
    /// Use this to validate credentials before full setup
    /// - Returns: Tuple of (success, errorMessage)
    func testProtonDriveConnection(
        username: String,
        password: String,
        twoFactorCode: String? = nil,
        mailboxPassword: String? = nil
    ) async throws -> (success: Bool, message: String) {
        print("[RcloneManager] Testing Proton Drive connection for: \(username)")
        
        let obscuredPassword = try await obscurePassword(password)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        
        // Build connection string with inline config
        var backendConfig = "protondrive,username=\(username),password=\(obscuredPassword)"
        
        if let code = twoFactorCode, !code.isEmpty {
            backendConfig += ",2fa=\(code)"
        }
        
        if let mailbox = mailboxPassword, !mailbox.isEmpty {
            let obscuredMailbox = try await obscurePassword(mailbox)
            backendConfig += ",mailbox_password=\(obscuredMailbox)"
        }
        
        process.arguments = [
            "lsd",
            ":\(backendConfig):",
            "--config", "/dev/null"  // Don't use any config file
        ]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        if process.terminationStatus == 0 {
            print("[RcloneManager] Proton Drive connection test: SUCCESS")
            return (true, "Connection successful!")
        } else {
            print("[RcloneManager] Proton Drive connection test: FAILED")
            print("[RcloneManager] Error: \(errorString)")
            
            // Parse error for user-friendly message
            let friendlyError = parseProtonDriveError(errorString)
            return (false, friendlyError)
        }
    }
    
    /// Parse Proton Drive errors into user-friendly messages
    private func parseProtonDriveError(_ error: String) -> String {
        let lowercased = error.lowercased()
        
        if lowercased.contains("encryption key") || lowercased.contains("no valid keyring") || lowercased.contains("keyring") {
            return "Proton Drive encryption keys not found. Please log in to Proton Drive via your web browser first to generate encryption keys."
        }
        if lowercased.contains("invalid access token") || lowercased.contains("401") {
            return "Session expired or invalid credentials. Please check your username and password."
        }
        if lowercased.contains("invalid password") || lowercased.contains("incorrect password") || lowercased.contains("wrong password") {
            return "Invalid password. Please check your credentials."
        }
        if lowercased.contains("2fa") || lowercased.contains("two-factor") || lowercased.contains("totp") {
            return "Two-factor authentication required. Please provide your 2FA code or OTP secret."
        }
        if lowercased.contains("429") || lowercased.contains("rate limit") || lowercased.contains("too many") {
            return "Too many requests. Please wait a moment before trying again."
        }
        if lowercased.contains("network") || lowercased.contains("connection") || lowercased.contains("timeout") {
            return "Network error. Please check your internet connection."
        }
        if lowercased.contains("mailbox password") {
            return "This is a two-password Proton account. Please provide your mailbox password."
        }
        
        // Return cleaned up error for unknown cases
        let cleanedError = error
            .components(separatedBy: .newlines)
            .first { !$0.isEmpty } ?? error
        return cleanedError.count > 150 ? String(cleanedError.prefix(150)) + "..." : cleanedError
    }
    
    func setupGoogleDrive(remoteName: String) async throws {
        // Google Drive uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "drive")
    }
    
    func setupDropbox(remoteName: String) async throws {
        // Dropbox uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "dropbox")
    }
    
    func setupOneDrive(remoteName: String, accountType: OneDriveAccountType = .personal) async throws {
        print("[RcloneManager]Setting up OneDrive: \(remoteName), type: \(accountType)")

        // OneDrive requires multiple steps:
        // 1. OAuth authentication (browser-based)
        // 2. Drive type selection
        // For now, we'll handle this by creating the config with proper parameters

        // Create a temporary process to handle OneDrive OAuth
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)

        // Use rclone config create with proper parameters
        var args = [
            "config", "create",
            remoteName,
            "onedrive",
            "--config", configPath,
            "config_is_local", "true"  // Use local browser for auth
        ]

        // Add drive_type based on account type
        switch accountType {
        case .personal:
            // For personal OneDrive, we don't set drive_type initially
            // It will be handled after OAuth
            break
        case .business:
            args.append("drive_type")
            args.append("business")
        case .sharepoint:
            args.append("drive_type")
            args.append("sharepoint")
        }

        process.arguments = args

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        print("[RcloneManager]Running OneDrive setup with args: \(args.joined(separator: " "))")

        try process.run()

        // For OneDrive, we need to handle the OAuth flow
        // The process will open a browser and wait for authentication
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        print("[RcloneManager] OneDrive setup output: \(output)")
        if !errorOutput.isEmpty {
            print("[RcloneManager] OneDrive setup error output: \(errorOutput)")
        }

        // After OAuth, we need to ensure proper drive configuration
        // Check if we got errors about invalid drive
        if errorOutput.contains("ObjectHandle is Invalid") || errorOutput.contains("Failed to query root") {
            print("[RcloneManager] OneDrive requires drive type configuration, fixing...")

            // For personal accounts, we need to update the config to use the correct drive
            let updateProcess = Process()
            updateProcess.executableURL = URL(fileURLWithPath: rclonePath)

            var updateArgs = [
                "config", "update",
                remoteName,
                "--config", configPath
            ]

            // Set proper drive configuration based on account type
            switch accountType {
            case .personal:
                // Personal OneDrive doesn't need explicit drive_id
                updateArgs.append(contentsOf: ["drive_type", "onedrive"])
            case .business:
                updateArgs.append(contentsOf: ["drive_type", "business"])
            case .sharepoint:
                updateArgs.append(contentsOf: ["drive_type", "sharepoint"])
            }

            updateProcess.arguments = updateArgs

            try updateProcess.run()
            updateProcess.waitUntilExit()

            print("[RcloneManager] Updated OneDrive configuration for \(accountType) account")
        }

        // Verify setup succeeded
        guard isRemoteConfigured(name: remoteName) else {
            throw RcloneError.configurationFailed("OneDrive OAuth did not complete successfully")
        }

        // Test the connection by listing directories
        print("[RcloneManager] Testing OneDrive connection...")
        let testProcess = Process()
        testProcess.executableURL = URL(fileURLWithPath: rclonePath)
        testProcess.arguments = [
            "lsd",
            "\(remoteName):",
            "--config", configPath,
            "--max-depth", "1"
        ]

        let testOutputPipe = Pipe()
        let testErrorPipe = Pipe()
        testProcess.standardOutput = testOutputPipe
        testProcess.standardError = testErrorPipe

        try testProcess.run()
        testProcess.waitUntilExit()

        if testProcess.terminationStatus != 0 {
            let testErrorData = testErrorPipe.fileHandleForReading.readDataToEndOfFile()
            let testError = String(data: testErrorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.configurationFailed("OneDrive connection test failed: \(testError)")
        }

        print("[RcloneManager] OneDrive setup successful: \(remoteName)")
    }
    
    func setupS3(remoteName: String, accessKey: String, secretKey: String, region: String = "us-east-1", endpoint: String = "") async throws {
        var params: [String: String] = [
            "access_key_id": accessKey,
            "secret_access_key": secretKey,
            "region": region
        ]
        if !endpoint.isEmpty {
            params["endpoint"] = endpoint
        }
        try await createRemote(name: remoteName, type: "s3", parameters: params)
    }
    
    func setupMega(remoteName: String, username: String, password: String) async throws {
        try await createRemote(
            name: remoteName,
            type: "mega",
            parameters: [
                "user": username,
                "pass": password
            ]
        )
    }
    
    func setupBox(remoteName: String) async throws {
        // Box uses OAuth
        try await createRemoteInteractive(name: remoteName, type: "box")
    }
    
    func setupPCloud(remoteName: String, username: String? = nil, password: String? = nil) async throws {
        // pCloud requires OAuth token - use interactive setup
        try await createRemoteInteractive(name: remoteName, type: "pcloud")
    }
    
    func setupWebDAV(remoteName: String, url: String, password: String, username: String = "") async throws {
        var params: [String: String] = [
            "url": url,
            "pass": password
        ]
        if !username.isEmpty {
            params["user"] = username
        }
        try await createRemote(name: remoteName, type: "webdav", parameters: params)
    }
    
    func setupSFTP(remoteName: String, host: String, password: String, user: String = "", port: String = "22") async throws {
        var params: [String: String] = [
            "host": host,
            "pass": password,
            "port": port
        ]
        if !user.isEmpty {
            params["user"] = user
        }
        try await createRemote(name: remoteName, type: "sftp", parameters: params)
    }
    
    func setupFTP(remoteName: String, host: String, password: String, user: String = "", port: String = "21") async throws {
        var params: [String: String] = [
            "host": host,
            "pass": password,
            "port": port
        ]
        if !user.isEmpty {
            params["user"] = user
        }
        try await createRemote(name: remoteName, type: "ftp", parameters: params)
    }
    
    // MARK: - Phase 1, Week 1: Self-Hosted & International Providers
    
    func setupNextcloud(remoteName: String, url: String, username: String, password: String) async throws {
        let params: [String: String] = [
            "url": url,
            "vendor": "nextcloud",
            "user": username,
            "pass": password
        ]
        try await createRemote(name: remoteName, type: "webdav", parameters: params)
    }
    
    func setupOwnCloud(remoteName: String, url: String, username: String, password: String) async throws {
        let params: [String: String] = [
            "url": url,
            "vendor": "owncloud",
            "user": username,
            "pass": password
        ]
        try await createRemote(name: remoteName, type: "webdav", parameters: params)
    }
    
    func setupSeafile(remoteName: String, url: String, username: String, password: String, library: String? = nil, authToken: String? = nil) async throws {
        var params: [String: String] = [
            "url": url,
            "user": username,
            "pass": password
        ]
        if let library = library, !library.isEmpty {
            params["library"] = library
        }
        if let authToken = authToken, !authToken.isEmpty {
            params["auth_token"] = authToken
        }
        try await createRemote(name: remoteName, type: "seafile", parameters: params)
    }
    
    func setupKoofr(remoteName: String, username: String, password: String, endpoint: String? = nil) async throws {
        var params: [String: String] = [
            "user": username,
            "password": password
        ]
        if let endpoint = endpoint, !endpoint.isEmpty {
            params["endpoint"] = endpoint
        }
        try await createRemote(name: remoteName, type: "koofr", parameters: params)
    }
    
    func setupYandexDisk(remoteName: String) async throws {
        // Yandex Disk uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "yandex")
    }
    
    func setupMailRuCloud(remoteName: String, username: String, password: String) async throws {
        try await createRemote(
            name: remoteName,
            type: "mailru",
            parameters: [
                "user": username,
                "pass": password
            ]
        )
    }
    
    // MARK: - Phase 1, Week 2: Object Storage Providers
    
    func setupBackblazeB2(remoteName: String, accountId: String, applicationKey: String) async throws {
        try await createRemote(
            name: remoteName,
            type: "b2",
            parameters: [
                "account": accountId,
                "key": applicationKey
            ]
        )
    }
    
    func setupWasabi(remoteName: String, accessKey: String, secretKey: String, region: String = "us-east-1", endpoint: String? = nil) async throws {
        var params: [String: String] = [
            "type": "s3",
            "provider": "Wasabi",
            "access_key_id": accessKey,
            "secret_access_key": secretKey,
            "region": region
        ]
        
        // Wasabi endpoint format: s3.{region}.wasabisys.com
        let wasabiEndpoint = endpoint ?? "https://s3.\(region).wasabisys.com"
        params["endpoint"] = wasabiEndpoint
        
        try await createRemote(name: remoteName, type: "s3", parameters: params)
    }
    
    func setupDigitalOceanSpaces(remoteName: String, accessKey: String, secretKey: String, region: String = "nyc3", endpoint: String? = nil) async throws {
        var params: [String: String] = [
            "type": "s3",
            "provider": "DigitalOcean",
            "access_key_id": accessKey,
            "secret_access_key": secretKey,
            "region": region
        ]
        
        // DO Spaces endpoint format: {region}.digitaloceanspaces.com
        let doEndpoint = endpoint ?? "https://\(region).digitaloceanspaces.com"
        params["endpoint"] = doEndpoint
        
        try await createRemote(name: remoteName, type: "s3", parameters: params)
    }
    
    func setupCloudflareR2(remoteName: String, accountId: String, accessKey: String, secretKey: String) async throws {
        let params: [String: String] = [
            "type": "s3",
            "provider": "Cloudflare",
            "access_key_id": accessKey,
            "secret_access_key": secretKey,
            "endpoint": "https://\(accountId).r2.cloudflarestorage.com",
            "region": "auto"
        ]
        
        try await createRemote(name: remoteName, type: "s3", parameters: params)
    }
    
    func setupScaleway(remoteName: String, accessKey: String, secretKey: String, region: String = "fr-par", endpoint: String? = nil) async throws {
        var params: [String: String] = [
            "type": "s3",
            "provider": "Scaleway",
            "access_key_id": accessKey,
            "secret_access_key": secretKey,
            "region": region
        ]
        
        // Scaleway endpoint format: s3.{region}.scw.cloud
        let scalewayEndpoint = endpoint ?? "https://s3.\(region).scw.cloud"
        params["endpoint"] = scalewayEndpoint
        
        try await createRemote(name: remoteName, type: "s3", parameters: params)
    }
    
    func setupOracleCloud(remoteName: String, namespace: String, compartment: String, region: String, accessKey: String, secretKey: String) async throws {
        let params: [String: String] = [
            "type": "s3",
            "provider": "Other",
            "access_key_id": accessKey,
            "secret_access_key": secretKey,
            "region": region,
            "endpoint": "https://\(namespace).compat.objectstorage.\(region).oraclecloud.com"
        ]
        
        try await createRemote(name: remoteName, type: "s3", parameters: params)
    }
    
    func setupStorj(remoteName: String, accessGrant: String) async throws {
        try await createRemote(
            name: remoteName,
            type: "storj",
            parameters: [
                "access_grant": accessGrant
            ]
        )
    }
    
    func setupFilebase(remoteName: String, accessKey: String, secretKey: String) async throws {
        let params: [String: String] = [
            "type": "s3",
            "provider": "Other",
            "access_key_id": accessKey,
            "secret_access_key": secretKey,
            "endpoint": "https://s3.filebase.com",
            "region": "us-east-1"
        ]
        
        try await createRemote(name: remoteName, type: "s3", parameters: params)
    }
    
    // MARK: - Phase 1, Week 3: Enterprise Services
    
    func setupGoogleCloudStorage(remoteName: String, projectId: String, serviceAccountKey: String? = nil) async throws {
        // Google Cloud Storage can use OAuth or service account
        if let serviceAccountKey = serviceAccountKey {
            // Service account authentication
            try await createRemote(
                name: remoteName,
                type: "google cloud storage",
                parameters: [
                    "project_number": projectId,
                    "service_account_credentials": serviceAccountKey
                ]
            )
        } else {
            // OAuth authentication
            try await createRemoteInteractive(name: remoteName, type: "google cloud storage")
        }
    }
    
    func setupAzureBlob(remoteName: String, accountName: String, accountKey: String? = nil, sasURL: String? = nil) async throws {
        var params: [String: String] = [
            "account": accountName
        ]
        
        if let accountKey = accountKey {
            params["key"] = accountKey
        } else if let sasURL = sasURL {
            params["sas_url"] = sasURL
        }
        
        try await createRemote(name: remoteName, type: "azureblob", parameters: params)
    }
    
    func setupAzureFiles(remoteName: String, accountName: String, accountKey: String, shareName: String? = nil) async throws {
        var params: [String: String] = [
            "account": accountName,
            "key": accountKey
        ]
        
        if let shareName = shareName {
            params["share_name"] = shareName
        }
        
        try await createRemote(name: remoteName, type: "azurefiles", parameters: params)
    }
    
    func setupOneDriveBusiness(remoteName: String, driveType: String = "business") async throws {
        // OneDrive for Business uses OAuth with drive_type parameter
        // We'll use the interactive setup and document the drive_type in config
        try await createRemoteInteractive(name: remoteName, type: "onedrive")
        // Note: drive_type should be set to "business" in the config
    }
    
    func setupSharePoint(remoteName: String) async throws {
        // SharePoint uses OneDrive backend with different configuration
        try await createRemoteInteractive(name: remoteName, type: "sharepoint")
    }
    
    func setupAlibabaOSS(remoteName: String, accessKey: String, secretKey: String, endpoint: String, region: String = "oss-cn-hangzhou") async throws {
        let params: [String: String] = [
            "access_key_id": accessKey,
            "access_key_secret": secretKey,
            "endpoint": endpoint,
            "region": region
        ]
        
        try await createRemote(name: remoteName, type: "oss", parameters: params)
    }
    
    // MARK: - Additional Providers: Nordic & Unlimited Storage
    
    /// Setup Jottacloud using Personal Login Token (standard authentication)
    /// 
    /// Jottacloud uses a multi-step state machine authentication:
    /// 1. Select auth type (standard)
    /// 2. Provide personal login token (from jottacloud.com/web/secure)
    /// 3. Select device/mountpoint (defaults to Jotta/Archive)
    ///
    /// - Parameters:
    ///   - remoteName: Name for the remote in rclone config
    ///   - personalLoginToken: Single-use token from jottacloud.com/web/secure
    ///   - useDefaultDevice: If true, uses Jotta/Archive (recommended). If false, may prompt for device.
    func setupJottacloud(remoteName: String, personalLoginToken: String, useDefaultDevice: Bool = true) async throws {
        print("[RcloneManager] Setting up Jottacloud with personal login token")
        
        // Delete existing remote if it exists (clean reconfigure)
        if isRemoteConfigured(name: remoteName) {
            print("[RcloneManager] Removing existing '\(remoteName)' remote")
            try? await deleteRemote(name: remoteName)
        }
        
        // Step 1: Initial call to start the config state machine
        // Step 1: Select authentication type (standard)
        print("[RcloneManager] Step 1: Selecting standard authentication type")
        let step1Result = try await runJottacloudConfigStep(
            remoteName: remoteName,
            state: "",
            result: "",
            isFirstStep: true  // Must be true for initial config create
        )
        
        // Parse the response to get the next state
        guard let step1State = parseConfigState(from: step1Result) else {
            throw RcloneError.configurationFailed("Failed to parse Jottacloud config state (step 1)")
        }
        
        // Step 2: Continue with "standard" auth type
        print("[RcloneManager] Step 2: Continuing with standard auth, state: \(step1State)")
        let step2Result = try await runJottacloudConfigStep(
            remoteName: remoteName,
            state: step1State,
            result: "standard"
        )
        
        guard let step2State = parseConfigState(from: step2Result) else {
            throw RcloneError.configurationFailed("Failed to parse Jottacloud config state (step 2)")
        }
        
        // Step 3: Provide the personal login token
        print("[RcloneManager] Step 3: Providing personal login token, state: \(step2State)")
        let step3Result = try await runJottacloudConfigStep(
            remoteName: remoteName,
            state: step2State,
            result: personalLoginToken
        )
        
        // Check for token exchange errors
        if step3Result.contains("invalid") || step3Result.contains("error") || step3Result.contains("failed") {
            let errorMsg = parseConfigError(from: step3Result) ?? "Invalid token or authentication failed"
            throw RcloneError.configurationFailed(errorMsg)
        }
        
        // Step 4: Handle device/mountpoint selection (use defaults)
        if let step3State = parseConfigState(from: step3Result), !step3State.isEmpty {
            print("[RcloneManager] Step 4: Handling device selection, state: \(step3State)")
            
            // Answer "no" to non-standard device question (use defaults)
            let step4Result = try await runJottacloudConfigStep(
                remoteName: remoteName,
                state: step3State,
                result: useDefaultDevice ? "false" : "true",
                isFirstStep: false
            )
            
            // Continue handling any remaining prompts until state is empty
            var lastResult = step4Result
            var iterations = 0
            let maxIterations = 10  // Safety limit
            
            while let nextState = parseConfigState(from: lastResult), 
                  !nextState.isEmpty,
                  iterations < maxIterations {
                iterations += 1
                print("[RcloneManager] Additional step \(iterations): state: \(nextState)")
                
                // For remaining prompts, use defaults (empty result or first option)
                lastResult = try await runJottacloudConfigStep(
                    remoteName: remoteName,
                    state: nextState,
                    result: "",
                    isFirstStep: false
                )
            }
        }
        
        // Verify the remote was created
        if isRemoteConfigured(name: remoteName) {
            print("[RcloneManager] ✅ Jottacloud remote '\(remoteName)' created successfully!")
        } else {
            throw RcloneError.configurationFailed("Jottacloud remote was not created. Token may be invalid or expired.")
        }
    }
    
    /// Run a single step of Jottacloud config state machine
    private func runJottacloudConfigStep(remoteName: String, state: String, result: String, isFirstStep: Bool = false) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        
        var args: [String]
        
        if isFirstStep {
            // First step: use "config create" to start the configuration
            args = [
                "config", "create",
                remoteName,
                "jottacloud",
                "--non-interactive",
                "--config", configPath
            ]
        } else {
            // Subsequent steps: use "config create" with --continue to progress state machine
            // Note: Must use "config create" (not "config update") because the remote
            // doesn't exist until the entire state machine completes
            args = [
                "config", "create",
                remoteName,
                "jottacloud",
                "--continue",
                "--state", state,
                "--result", result,
                "--non-interactive",
                "--config", configPath
            ]
        }
        
        process.arguments = args
        
        print("[RcloneManager] Running: rclone \(args.joined(separator: " "))")
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        // Combine output and error for parsing
        let fullOutput = output + errorOutput
        
        print("[RcloneManager] Output: \(fullOutput.prefix(500))")
        
        // Check for fatal errors
        if fullOutput.contains("Fatal error") || fullOutput.contains("NOTICE: Fatal error") {
            throw RcloneError.configurationFailed(errorOutput.isEmpty ? output : errorOutput)
        }
        
        return fullOutput
    }
    
    /// Parse the State field from rclone's JSON response
    private func parseConfigState(from output: String) -> String? {
        // Try to decode as JSON first for reliability
        if let data = output.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let state = json["State"] as? String {
            return state
        }
        
        // Fallback: Look for "State": "value" pattern using simple string search
        // Pattern: "State": "xxx" or "State":"xxx"
        let patterns = ["\"State\": \"", "\"State\":\""]
        for pattern in patterns {
            if let startRange = output.range(of: pattern) {
                let afterPattern = output[startRange.upperBound...]
                if let endQuote = afterPattern.firstIndex(of: "\"") {
                    return String(afterPattern[..<endQuote])
                }
            }
        }
        
        return nil
    }
    
    /// Parse error message from rclone output
    private func parseConfigError(from output: String) -> String? {
        // Try to decode as JSON first
        if let data = output.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = json["Error"] as? String,
           !error.isEmpty {
            return error
        }
        
        // Fallback: Look for "Error": "value" pattern
        let patterns = ["\"Error\": \"", "\"Error\":\""]
        for pattern in patterns {
            if let startRange = output.range(of: pattern) {
                let afterPattern = output[startRange.upperBound...]
                if let endQuote = afterPattern.firstIndex(of: "\"") {
                    let error = String(afterPattern[..<endQuote])
                    if !error.isEmpty {
                        return error
                    }
                }
            }
        }
        
        // Also check for fatal error messages
        if output.contains("failed to get oauth token") {
            return "Invalid or expired personal login token. Please generate a new token at jottacloud.com/web/secure"
        }
        
        return nil
    }
    
    /// Legacy method for backward compatibility - redirects to token-based setup
    /// The password field should contain the personal login token
    @available(*, deprecated, message: "Use setupJottacloud(remoteName:personalLoginToken:) instead")
    func setupJottacloudLegacy(remoteName: String, username: String? = nil, password: String? = nil, device: String? = nil) async throws {
        // If password is provided, treat it as the personal login token
        if let token = password, !token.isEmpty {
            try await setupJottacloud(remoteName: remoteName, personalLoginToken: token)
        } else {
            throw RcloneError.configurationFailed("Jottacloud requires a personal login token. Generate one at https://www.jottacloud.com/web/secure")
        }
    }
    
    // MARK: - OAuth Services Expansion: Media & Consumer
    
    func setupGooglePhotos(remoteName: String) async throws {
        // Google Photos uses OAuth with read-only scope
        // Scope "1" = read_only = photoslibrary.readonly
        try await createRemoteInteractive(
            name: remoteName, 
            type: "gphotos",
            additionalParams: ["read_only": "true"]
        )
    }
    
    func setupFlickr(remoteName: String) async throws {
        // Flickr uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "flickr")
    }
    
    func setupSugarSync(remoteName: String) async throws {
        // SugarSync uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "sugarsync")
    }
    
    func setupOpenDrive(remoteName: String) async throws {
        // OpenDrive uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "opendrive")
    }
    
    // MARK: - OAuth Services Expansion: Specialized & Enterprise
    
    func setupPutio(remoteName: String) async throws {
        // Put.io uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "putio")
    }
    
    func setupPremiumizeme(remoteName: String) async throws {
        // Premiumize.me uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "premiumizeme")
    }
    
    func setupQuatrix(remoteName: String) async throws {
        // Quatrix uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "quatrix")
    }
    
    func setupFileFabric(remoteName: String) async throws {
        // File Fabric uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "filefabric")
    }
    
    // MARK: - Generic Remote Creation
    
    private func createRemote(name: String, type: String, parameters: [String: String]) async throws {
        var args = [
            "config", "create",
            name,
            type
        ]
        
        // Add parameters
        for (key, value) in parameters {
            args.append(key)
            args.append(value)
        }
        
        args.append(contentsOf: ["--config", configPath, "--non-interactive"])
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = args
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.configurationFailed(errorString)
        }
    }
    
    private func createRemoteInteractive(name: String, type: String, additionalParams: [String: String] = [:]) async throws {
        // For OAuth providers, we need to run rclone config interactively
        // This will open a browser for authentication
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        
        var args = [
            "config", "create",
            name,
            type,
            "--config", configPath
        ]
        
        // Add any additional parameters (e.g., scope for Google Photos)
        for (key, value) in additionalParams {
            args.append(key)
            args.append(value)
        }
        
        process.arguments = args
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        // Check if config was created successfully
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            
            // Some OAuth flows return non-zero but still succeed
            // Check if the remote was actually created
            if !isRemoteConfigured(name: name) {
                throw RcloneError.configurationFailed(errorString)
            }
        }
    }
    
    func isRemoteConfigured(name: String) -> Bool {
        guard FileManager.default.fileExists(atPath: configPath) else { return false }
        
        do {
            let content = try String(contentsOfFile: configPath, encoding: .utf8)
            return content.contains("[\(name)]")
        } catch {
            return false
        }
    }
    
    func deleteRemote(name: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "config", "delete",
            name,
            "--config", configPath
        ]
        
        try process.run()
        process.waitUntilExit()
    }
    
    // MARK: - Sync Operations
    
    func sync(localPath: String, remotePath: String, mode: SyncMode = .oneWay, encrypted: Bool = false, remoteName: String = "proton") async throws -> AsyncStream<SyncProgress> {
        // Determine which remote to use
        let remote = encrypted ? EncryptionManager.shared.encryptedRemoteName : remoteName
        
        return AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: rclonePath)
                
                // Build arguments based on mode
                var args: [String] = []
                
                switch mode {
                case .oneWay:
                    args = [
                        "sync",
                        localPath,
                        "\(remote):\(remotePath)",
                        "--config", configPath,
                        "--progress",
                        "--stats", "1s",
                        "--transfers", "4",
                        "--checkers", "8",
                        "--verbose"
                    ]
                    // Add bandwidth limits
                    args.append(contentsOf: self.getBandwidthArgs())
                case .biDirectional:
                    args = [
                        "bisync",
                        localPath,
                        "\(remote):\(remotePath)",
                        "--config", configPath,
                        "--resilient",
                        "--recover",
                        "--conflict-resolve", "newer",
                        "--conflict-loser", "num",
                        "--verbose",
                        "--max-delete", "50"
                    ]
                    // Add bandwidth limits
                    args.append(contentsOf: self.getBandwidthArgs())
                }
                
                process.arguments = args
                
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                
                // Read output asynchronously
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty {
                        if let output = String(data: data, encoding: .utf8) {
                            if let progress = self.parseProgress(from: output) {
                                continuation.yield(progress)
                            }
                        }
                    }
                }
                
                try process.run()
                self.process = process
                
                process.waitUntilExit()
                
                pipe.fileHandleForReading.readabilityHandler = nil
                continuation.finish()
            }
        }
    }
    
    /// Sync between any two remotes with encryption support
    /// - Parameters:
    ///   - sourceRemote: Source remote name (can be crypt remote for decryption)
    ///   - sourcePath: Path on source remote
    ///   - destRemote: Destination remote name (can be crypt remote for encryption)
    ///   - destPath: Path on destination remote
    ///   - mode: Sync mode (oneWay or biDirectional)
    func syncBetweenRemotes(
        sourceRemote: String,
        sourcePath: String,
        destRemote: String,
        destPath: String,
        mode: SyncMode = .oneWay
    ) async throws -> AsyncStream<SyncProgress> {
        return AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: self.rclonePath)
                
                // Build source and destination strings
                let source = sourceRemote.isEmpty || sourceRemote == "local" ? sourcePath : "\(sourceRemote):\(sourcePath)"
                let dest = destRemote.isEmpty || destRemote == "local" ? destPath : "\(destRemote):\(destPath)"
                
                var args: [String] = []
                
                switch mode {
                case .oneWay:
                    args = [
                        "sync",
                        source,
                        dest,
                        "--config", self.configPath,
                        "--progress",
                        "--stats", "1s",
                        "--transfers", "4",
                        "--checkers", "8",
                        "--verbose"
                    ]
                case .biDirectional:
                    args = [
                        "bisync",
                        source,
                        dest,
                        "--config", self.configPath,
                        "--resilient",
                        "--recover",
                        "--conflict-resolve", "newer",
                        "--conflict-loser", "num",
                        "--verbose",
                        "--max-delete", "50"
                    ]
                }
                
                // Add bandwidth limits
                args.append(contentsOf: self.getBandwidthArgs())
                
                process.arguments = args
                
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty {
                        if let output = String(data: data, encoding: .utf8) {
                            if let progress = self.parseProgress(from: output) {
                                continuation.yield(progress)
                            }
                        }
                    }
                }
                
                try process.run()
                self.process = process
                
                process.waitUntilExit()
                
                pipe.fileHandleForReading.readabilityHandler = nil
                continuation.finish()
            }
        }
    }
    
    func copyFiles(from sourcePath: String, to destPath: String, sourceRemote: String, destRemote: String) async throws -> AsyncStream<SyncProgress> {
        return AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: self.rclonePath)
                
                // Handle local paths - don't add remote prefix for local files
                let source: String
                if sourceRemote == "local" || sourceRemote.isEmpty {
                    source = sourcePath
                } else {
                    source = "\(sourceRemote):\(sourcePath)"
                }
                
                let dest: String
                if destRemote == "local" || destRemote.isEmpty {
                    dest = destPath
                } else {
                    dest = "\(destRemote):\(destPath)"
                }
                
                var args = [
                    "copy",
                    source,
                    dest,
                    "--config", self.configPath,
                    "--progress",
                    "--stats", "1s",
                    "--stats-one-line",
                    "--stats-file-name-length", "0",
                    "--transfers", "4",
                    "--verbose",
                    "--ignore-existing"  // Skip files that already exist at destination
                ]
                
                // Add bandwidth limits
                args.append(contentsOf: self.getBandwidthArgs())
                
                process.arguments = args
                
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty {
                        if let output = String(data: data, encoding: .utf8) {
                            if let progress = self.parseProgress(from: output) {
                                continuation.yield(progress)
                            }
                        }
                    }
                }
                
                try process.run()
                self.process = process
                
                process.waitUntilExit()
                
                pipe.fileHandleForReading.readabilityHandler = nil
                continuation.finish()
            }
        }
    }
    
    func listRemoteFiles(remotePath: String, encrypted: Bool = false, remoteName: String = "proton") async throws -> [RemoteFile] {
        let remote = encrypted ? EncryptionManager.shared.encryptedRemoteName : remoteName
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "lsjson",
            "\(remote):\(remotePath)",
            "--config", configPath
        ]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.syncFailed(errorString)
        }
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        
        // Handle empty response
        if data.isEmpty {
            return []
        }
        
        do {
            let files = try JSONDecoder().decode([RemoteFile].self, from: data)
            return files
        } catch {
            // Return empty array if parsing fails (might be empty folder)
            return []
        }
    }
    
    func stopCurrentSync() {
        process?.terminate()
        process = nil
    }
    
    // MARK: - Encryption Setup
    
    /// Sets up an encrypted (crypt) remote that wraps another remote.
    /// This provides client-side E2E encryption before files are uploaded.
    func setupEncryptedRemote(
        password: String,
        salt: String,
        encryptFilenames: String = "standard", // standard, obfuscate, off
        encryptDirectories: Bool = true,
        wrappedRemote: String,
        wrappedPath: String = ""
    ) async throws {
        print("[RcloneManager] setupEncryptedRemote called")
        print("[RcloneManager] Wrapped remote: \(wrappedRemote):\(wrappedPath)")
        print("[RcloneManager] Filename encryption: \(encryptFilenames), Directory encryption: \(encryptDirectories)")
        
        // First, obscure the password and salt using rclone
        let obscuredPassword = try await obscurePassword(password)
        let obscuredSalt = try await obscurePassword(salt)
        
        print("[RcloneManager] Passwords obscured successfully")
        
        // Build the full remote path
        // If wrappedPath is empty, wrap the entire remote (e.g., "googledrive:")
        // If wrappedPath is provided, wrap a specific path (e.g., "googledrive:/encrypted")
        let fullRemotePath = wrappedPath.isEmpty ? "\(wrappedRemote):" : "\(wrappedRemote):\(wrappedPath)"
        
        // Encrypted remote name: baseremote-encrypted (e.g., "googledrive-encrypted")
        let encryptedRemoteName = EncryptionManager.shared.getEncryptedRemoteName(for: wrappedRemote)
        
        // Delete existing encrypted remote if it exists
        try? await deleteRemote(name: encryptedRemoteName)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "config", "create",
            encryptedRemoteName,
            "crypt",
            "remote", fullRemotePath,
            "password", obscuredPassword,
            "password2", obscuredSalt,
            "filename_encryption", encryptFilenames,
            "directory_name_encryption", encryptDirectories ? "true" : "false",
            "--config", configPath,
            "--non-interactive"
        ]
        
        print("[RcloneManager] Creating encrypted remote: \(encryptedRemoteName)")
        print("[RcloneManager] Wrapping: \(fullRemotePath)")
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        print("[RcloneManager] rclone output: \(outputString)")
        print("[RcloneManager] rclone errors: \(errorString)")
        print("[RcloneManager] Exit code: \(process.terminationStatus)")
        
        if process.terminationStatus != 0 {
            throw RcloneError.encryptionSetupFailed(errorString.isEmpty ? "Unknown error" : errorString)
        }
        
        print("[RcloneManager] Encrypted remote '\(encryptedRemoteName)' created successfully!")
    }
    
    /// Removes the encrypted remote configuration
    func removeEncryptedRemote() async throws {
        try await deleteRemote(name: EncryptionManager.shared.encryptedRemoteName)
    }
    
    /// Obscures a password using rclone's obscure command.
    /// Rclone requires passwords in its config to be obscured.
    func obscurePassword(_ password: String) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = ["obscure", password]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.encryptionSetupFailed("Failed to obscure password: \(errorString)")
        }
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let obscured = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return obscured
    }
    
    /// Checks if the encrypted remote is configured in rclone
    func isEncryptedRemoteConfigured() -> Bool {
        return isRemoteConfigured(name: EncryptionManager.shared.encryptedRemoteName)
    }
    
    // MARK: - Per-Remote Encryption Setup
    
    /// Sets up a crypt remote for a specific base remote.
    /// Creates "{baseRemote}-crypt" that wraps "{baseRemote}:"
    func setupCryptRemote(
        for baseRemoteName: String,
        config: RemoteEncryptionConfig
    ) async throws {
        print("[RcloneManager] setupCryptRemote called for \(baseRemoteName)")
        
        // Obscure the password and salt
        let obscuredPassword = try await obscurePassword(config.password)
        let obscuredSalt = try await obscurePassword(config.salt)
        
        // Crypt remote name: {baseRemote}-crypt
        let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: baseRemoteName)
        
        // The crypt remote wraps the entire base remote
        let wrappedRemote = "\(baseRemoteName):"
        
        // Delete existing crypt remote if it exists
        try? await deleteRemote(name: cryptRemoteName)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "config", "create",
            cryptRemoteName,
            "crypt",
            "remote", wrappedRemote,
            "password", obscuredPassword,
            "password2", obscuredSalt,
            "filename_encryption", config.filenameEncryptionMode,
            "directory_name_encryption", config.encryptFolders ? "true" : "false",
            "--config", configPath,
            "--non-interactive"
        ]
        
        print("[RcloneManager] Creating crypt remote: \(cryptRemoteName)")
        print("[RcloneManager] Wrapping: \(wrappedRemote)")
        print("[RcloneManager] Filename encryption: \(config.filenameEncryptionMode)")
        print("[RcloneManager] Directory encryption: \(config.encryptFolders)")
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            throw RcloneError.encryptionSetupFailed(errorString.isEmpty ? "Failed to create crypt remote" : errorString)
        }
        
        print("[RcloneManager] Crypt remote '\(cryptRemoteName)' created successfully!")
        
        // Save the config to EncryptionManager
        try EncryptionManager.shared.saveConfig(config, for: baseRemoteName)
    }
    
    /// Check if a crypt remote is configured for a base remote
    func isCryptRemoteConfigured(for baseRemoteName: String) -> Bool {
        let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: baseRemoteName)
        return isRemoteConfigured(name: cryptRemoteName)
    }
    
    /// Delete the crypt remote for a base remote
    func deleteCryptRemote(for baseRemoteName: String) async throws {
        let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: baseRemoteName)
        try await deleteRemote(name: cryptRemoteName)
        EncryptionManager.shared.deleteConfig(for: baseRemoteName)
        print("[RcloneManager] Deleted crypt remote '\(cryptRemoteName)'")
    }
    
    // MARK: - File Operations
    
    /// Delete a file or folder from a remote
    func deleteFile(remoteName: String, path: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "deletefile",
            "\(remoteName):\(path)",
            "--config", configPath
        ]
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.syncFailed(errorString)
        }
    }
    
    /// Delete a folder and its contents from a remote
    func deleteFolder(remoteName: String, path: String) async throws {
        print("[RcloneManager] deleteFolder called: remoteName=\(remoteName), path=\(path)")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "purge",
            "\(remoteName):\(path)",
            "--config", configPath
        ]
        
        print("[RcloneManager] Running: \(rclonePath) purge \(remoteName):\(path)")
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        // rclone purge returns 0 on success, but may have notices in stderr
        if process.terminationStatus != 0 {
            throw RcloneError.syncFailed(errorString.isEmpty ? "Delete failed" : errorString)
        }
    }
    
    /// Rename/move a file or folder on a remote
    func renameFile(remoteName: String, oldPath: String, newPath: String) async throws {
        print("[RcloneManager] renameFile called: remoteName=\(remoteName), oldPath=\(oldPath), newPath=\(newPath)")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "moveto",
            "\(remoteName):\(oldPath)",
            "\(remoteName):\(newPath)",
            "--config", configPath
        ]
        
        print("[RcloneManager] Running: \(rclonePath) moveto \(remoteName):\(oldPath) \(remoteName):\(newPath)")
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            throw RcloneError.syncFailed(errorString.isEmpty ? "Rename failed" : errorString)
        }
    }
    
    /// Create a new folder on a remote
    func createFolder(remoteName: String, path: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "mkdir",
            "\(remoteName):\(path)",
            "--config", configPath
        ]
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.syncFailed(errorString)
        }
    }
    
    /// Create a new directory on a remote (alias for createFolder)
    func createDirectory(remoteName: String, path: String) async throws {
        try await createFolder(remoteName: remoteName, path: path)
    }
    
    /// Download a file or folder from a remote to local
    func download(remoteName: String, remotePath: String, localPath: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        
        var args = [
            "copy",
            "\(remoteName):\(remotePath)",
            localPath,
            "--config", configPath,
            "--progress",
            "--verbose"
        ]
        
        // Add bandwidth limits
        args.append(contentsOf: getBandwidthArgs())
        
        process.arguments = args
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        // Get both output and error data
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        // Check for specific scenarios
        let combinedOutput = outputString + errorString
        
        // If file exists, rclone will show "There was nothing to transfer"
        if combinedOutput.contains("There was nothing to transfer") || 
           combinedOutput.contains("Unchanged skipping") {
            throw RcloneError.syncFailed("File already exists at destination")
        }
        
        if process.terminationStatus != 0 {
            throw RcloneError.syncFailed(errorString.isEmpty ? "Download failed" : errorString)
        }
    }
    
    /// Upload a file or folder from local to a remote with progress streaming
    func uploadWithProgress(localPath: String, remoteName: String, remotePath: String) async throws -> AsyncStream<SyncProgress> {
        return AsyncStream { continuation in
            Task.detached {
                let logPath = "/tmp/cloudsync_upload_debug.log"
                let log = { (msg: String) in
                    let timestamp = Date().description
                    let line = "\(timestamp): [RcloneManager] \(msg)\n"
                    if let data = line.data(using: .utf8) {
                        let fileURL = URL(fileURLWithPath: logPath)
                        if FileManager.default.fileExists(atPath: logPath) {
                            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                                fileHandle.seekToEndOfFile()
                                fileHandle.write(data)
                                fileHandle.closeFile()
                            }
                        } else {
                            try? data.write(to: fileURL)
                        }
                    }
                }
                
                let process = Process()
                process.executableURL = URL(fileURLWithPath: self.rclonePath)
                
                // Detect if this is a folder and count files for optimization
                var fileCount = 0
                var isDirectory = false
                var isDirectoryValue: ObjCBool = false
                if FileManager.default.fileExists(atPath: localPath, isDirectory: &isDirectoryValue) {
                    isDirectory = isDirectoryValue.boolValue
                    if isDirectory {
                        // Count files in directory (using Array to avoid async iteration warning)
                        if let enumerator = FileManager.default.enumerator(atPath: localPath) {
                            fileCount = enumerator.allObjects.count
                        }
                    }
                }
                
                print("[RcloneManager]Upload info - isDirectory: \(isDirectory), fileCount: \(fileCount)")
                
                var args = [
                    "copy",
                    localPath,
                    "\(remoteName):\(remotePath)",
                    "--config", self.configPath,
                    "--progress",
                    "--stats", "500ms",
                    "--stats-one-line",
                    "--stats-file-name-length", "0",  // Show full filenames
                    "-v"
                ]
                
                // Increase parallelism for folders with many small files
                // More parallel transfers = faster upload of many small files
                if isDirectory && fileCount > 20 {
                    let transfers = min(16, max(8, fileCount / 10))  // 8-16 parallel transfers
                    args.append("--transfers")
                    args.append("\(transfers)")
                    print("[RcloneManager]Using \(transfers) parallel transfers for \(fileCount) files")
                } else {
                    args.append("--transfers")
                    args.append("4")  // Default for single files or small folders
                }
                
                args.append(contentsOf: self.getBandwidthArgs())
                
                process.arguments = args
                
                let stderrPipe = Pipe()
                process.standardOutput = stderrPipe
                process.standardError = stderrPipe
                
                print("[RcloneManager]Starting upload: \(localPath) -> \(remoteName):\(remotePath)")
                
                let handle = stderrPipe.fileHandleForReading
                
                do {
                    try process.run()
                    self.process = process
                    
                    print("[RcloneManager]Process started, beginning to read output")
                    
                    // Read output in a loop while process is running
                    var buffer = Data()
                    
                    while process.isRunning {
                        // Non-blocking read with small chunks
                        let data = handle.availableData
                        if !data.isEmpty {
                            buffer.append(data)
                            
                            if let output = String(data: buffer, encoding: .utf8) {
                                // Split by newline OR carriage return - this handles both \n and \r separated lines
                                let lines = output.components(separatedBy: CharacterSet(charactersIn: "\n\r"))
                                
                                // Process ALL lines, including the last one if it's complete
                                for line in lines {
                                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                                    if !trimmedLine.isEmpty {
                                        // Check if this looks like a progress line (has percentage and slashes)
                                        if trimmedLine.contains("%") && trimmedLine.contains("/") {
                                            print("[RcloneManager]Progress line: \(trimmedLine)")
                                            if let progress = self.parseProgress(from: trimmedLine) {
                                                print("[RcloneManager]Parsed progress: \(progress.percentage)% - \(progress.speed)")
                                                continuation.yield(progress)
                                            }
                                        } else if !trimmedLine.starts(with: "2026/") { // Skip debug timestamps
                                            print("[RcloneManager]Non-progress line: \(trimmedLine)")
                                        }
                                    }
                                }
                                
                                // Clear buffer after processing - we don't need to keep incomplete lines
                                // since progress lines are self-contained
                                buffer = Data()
                            }
                        }
                        
                        // Small sleep to avoid busy-waiting
                        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                    }
                    
                    // Read any remaining data
                    if let data = try? handle.readToEnd(), !data.isEmpty {
                        buffer.append(data)
                        if let output = String(data: buffer, encoding: .utf8) {
                            print("[RcloneManager]Final output: \(output)")
                            if let progress = self.parseProgress(from: output) {
                                continuation.yield(progress)
                            }
                        }
                    }
                    
                    print("[RcloneManager]Upload exit code: \(process.terminationStatus)")
                    
                    if process.terminationStatus == 0 {
                        continuation.yield(SyncProgress(percentage: 100, speed: "", status: .completed))
                    }
                    
                    continuation.finish()
                } catch {
                    print("[RcloneManager]Upload error: \(error.localizedDescription)")
                    continuation.finish()
                }
            }
        }
    }
    
    /// Upload a file or folder from local to a remote (blocking version)
    func upload(localPath: String, remoteName: String, remotePath: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        
        var args = [
            "copy",
            localPath,
            "\(remoteName):\(remotePath)",
            "--config", configPath,
            "--progress",
            "--verbose",
            "--stats", "1s"
        ]
        
        // Add bandwidth limits
        args.append(contentsOf: getBandwidthArgs())
        
        process.arguments = args
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        print("[RcloneManager] Starting upload: \(localPath) -> \(remoteName):\(remotePath)")
        
        try process.run()
        process.waitUntilExit()
        
        // Get both output and error data
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        print("[RcloneManager] Upload output: \(outputString)")
        print("[RcloneManager] Upload errors: \(errorString)")
        print("[RcloneManager] Exit code: \(process.terminationStatus)")
        
        // Check for specific scenarios
        let combinedOutput = outputString + errorString
        
        // If file exists, rclone will show "There was nothing to transfer"
        if combinedOutput.contains("There was nothing to transfer") || 
           combinedOutput.contains("Unchanged skipping") ||
           combinedOutput.contains("Transferred:") && combinedOutput.contains("0 / 0") {
            print("[RcloneManager] File appears to already exist")
            throw RcloneError.syncFailed("File already exists at destination")
        }
        
        if process.terminationStatus != 0 {
            throw RcloneError.syncFailed(errorString.isEmpty ? "Upload failed" : errorString)
        }
    }
    
    /// Copy directly between two remotes (cloud to cloud) without downloading locally
    func copyBetweenRemotes(source: String, destination: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)

        var args = [
            "copyto",
            source,
            destination,
            "--config", configPath,
            "--progress",
            "--verbose"
        ]

        // Add bandwidth limits
        args.append(contentsOf: getBandwidthArgs())

        process.arguments = args

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        // Get both output and error data
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""

        // Check for specific scenarios
        let combinedOutput = outputString + errorString

        // If file exists, rclone will show "There was nothing to transfer"
        if combinedOutput.contains("There was nothing to transfer") ||
           combinedOutput.contains("Unchanged skipping") {
            throw RcloneError.syncFailed("File already exists at destination")
        }

        if process.terminationStatus != 0 {
            throw RcloneError.syncFailed(errorString.isEmpty ? "Copy failed" : errorString)
        }
    }

    /// Copy directly between two remotes (cloud to cloud) with progress streaming
    /// Use this for cloud-to-cloud transfers that need progress updates in the UI
    /// - Parameters:
    ///   - source: Full source path (e.g., "proton:folder/file.txt")
    ///   - destination: Full destination path (e.g., "jottacloud:folder/file.txt")
    ///   - isDirectory: Whether the source is a directory (uses "copy" vs "copyto")
    /// - Returns: AsyncStream of SyncProgress updates
    func copyBetweenRemotesWithProgress(source: String, destination: String, isDirectory: Bool = false) async throws -> AsyncStream<SyncProgress> {
        return AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: self.rclonePath)

                // Use "copy" for directories, "copyto" for single files
                let command = isDirectory ? "copy" : "copyto"

                var args = [
                    command,
                    source,
                    destination,
                    "--config", self.configPath,
                    "--progress",
                    "--stats", "1s",
                    "--stats-one-line",
                    "--stats-file-name-length", "0",
                    "--transfers", "4",
                    "--verbose"
                ]

                // Add bandwidth limits
                args.append(contentsOf: self.getBandwidthArgs())

                process.arguments = args

                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe

                print("[RcloneManager] Cloud-to-cloud with progress: \(source) -> \(destination)")

                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty {
                        if let output = String(data: data, encoding: .utf8) {
                            if let progress = self.parseProgress(from: output) {
                                continuation.yield(progress)
                            }
                        }
                    }
                }

                do {
                    try process.run()
                    self.process = process

                    process.waitUntilExit()

                    pipe.fileHandleForReading.readabilityHandler = nil

                    if process.terminationStatus == 0 {
                        continuation.yield(SyncProgress(percentage: 100, speed: "", status: .completed))
                    }

                    continuation.finish()
                } catch {
                    print("[RcloneManager] Cloud-to-cloud error: \(error.localizedDescription)")
                    continuation.finish()
                }
            }
        }
    }
    
    /// Copy files/folders between remotes using rclone copy (for directories)
    func copy(source: String, destination: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        
        var args = [
            "copy",
            source,
            destination,
            "--config", configPath,
            "--progress",
            "--verbose"
        ]
        
        // Add bandwidth limits
        args.append(contentsOf: getBandwidthArgs())
        
        process.arguments = args
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        // Get error output
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            throw RcloneError.syncFailed(errorString.isEmpty ? "Copy failed" : errorString)
        }
    }
    
    // MARK: - Progress Parsing
    
    private func parseProgress(from output: String) -> SyncProgress? {
        // Parse rclone output for progress information
        // Format 1: "Transferred:   	    1.234 MiB / 10.567 MiB, 12%, 234.5 KiB/s, ETA 30s"
        // Format 2: "18 B / 18 B, 100%, 17 B/s, ETA 0s" (with --stats-one-line)
        // Format 3: "Transferred:   5 / 100, 5%" (file counts when transferring directories)
        
        let lines = output.components(separatedBy: .newlines)
        
        var filesTransferred: Int?
        var totalFiles: Int?
        var percentage: Double = 0
        var speed: String = ""
        var bytesTransferred: Int64?
        var totalBytes: Int64?
        
        for line in lines {
            // Check for file count info: "Transferred: 5 / 100, 5%"
            if line.contains("Transferred:") && line.contains("/") {
                // Try to extract "X / Y" pattern
                let pattern = "Transferred:\\s*(\\d+)\\s*/\\s*(\\d+)"
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                    if let transferredRange = Range(match.range(at: 1), in: line),
                       let totalRange = Range(match.range(at: 2), in: line) {
                        filesTransferred = Int(line[transferredRange])
                        totalFiles = Int(line[totalRange])
                    }
                }
            }
            
            // Format 1: Look for "Transferred:" line with bytes
            if line.contains("Transferred:") && (line.contains("MiB") || line.contains("KiB") || line.contains("GiB") || line.contains(" B")) {
                let components = line.components(separatedBy: ",")
                
                if components.count >= 3 {
                    // Parse percentage
                    let percentageStr = components[1].trimmingCharacters(in: .whitespaces)
                    percentage = Double(percentageStr.replacingOccurrences(of: "%", with: "")) ?? 0
                    
                    // Parse speed
                    speed = components[2].trimmingCharacters(in: .whitespaces)
                }
            }
            
            // Format 2: Look for lines with percentage and speed (e.g., "18 B / 18 B, 100%, 17 B/s, ETA 0s")
            // Also extract bytes: "1.371 MiB / 1 GiB, 0%, ..."
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.contains("%") && trimmedLine.contains("/") && trimmedLine.contains("B/s") {
                let components = trimmedLine.components(separatedBy: ",")
                
                if components.count >= 3 {
                    // Extract bytes from first component: "transferred / total"
                    let bytesPart = components[0].trimmingCharacters(in: .whitespaces)
                    let bytesComponents = bytesPart.components(separatedBy: "/")
                    if bytesComponents.count == 2 {
                        let transferredStr = bytesComponents[0].trimmingCharacters(in: .whitespaces)
                        let totalStr = bytesComponents[1].trimmingCharacters(in: .whitespaces)
                        bytesTransferred = parseSizeString(transferredStr)
                        totalBytes = parseSizeString(totalStr)
                    }
                    
                    // Parse percentage (second component)
                    let percentageStr = components[1].trimmingCharacters(in: .whitespaces)
                    percentage = Double(percentageStr.replacingOccurrences(of: "%", with: "")) ?? 0
                    
                    // Parse speed (third component)
                    speed = components[2].trimmingCharacters(in: .whitespaces)
                }
            }
            
            if line.contains("Checks:") || line.contains("Need to transfer") {
                return SyncProgress(percentage: 0, speed: "Checking files...", status: .checking)
            }
            
            if line.contains("ERROR") {
                return SyncProgress(percentage: 0, speed: "", status: .error(line))
            }
        }
        
        // Return progress if we found any useful info
        if percentage > 0 || !speed.isEmpty || filesTransferred != nil {
            return SyncProgress(
                percentage: percentage,
                speed: speed,
                status: .syncing,
                filesTransferred: filesTransferred,
                totalFiles: totalFiles,
                bytesTransferred: bytesTransferred,
                totalBytes: totalBytes
            )
        }
        
        return nil
    }
    
    // Helper to parse size strings like "1.5 MiB", "652.6 MB", "128 B"
    private func parseSizeString(_ sizeStr: String) -> Int64? {
        let parts = sizeStr.components(separatedBy: " ")
        guard parts.count == 2,
              let value = Double(parts[0]) else {
            return nil
        }
        
        let unit = parts[1].uppercased()
        let multiplier: Double
        
        switch unit {
        case "B": multiplier = 1
        case "KB", "KIB": multiplier = 1024
        case "MB", "MIB": multiplier = 1024 * 1024
        case "GB", "GIB": multiplier = 1024 * 1024 * 1024
        case "TB", "TIB": multiplier = 1024 * 1024 * 1024 * 1024
        default: return nil
        }
        
        return Int64(value * multiplier)
    }
}

// MARK: - Supporting Types

enum SyncMode {
    case oneWay
    case biDirectional
}

struct SyncProgress {
    let percentage: Double
    let speed: String
    let status: SyncStatus
    let filesTransferred: Int?  // Number of files transferred
    let totalFiles: Int?        // Total number of files
    let bytesTransferred: Int64? // Bytes transferred so far
    let totalBytes: Int64?      // Total bytes to transfer
    
    init(percentage: Double, speed: String, status: SyncStatus, filesTransferred: Int? = nil, totalFiles: Int? = nil, bytesTransferred: Int64? = nil, totalBytes: Int64? = nil) {
        self.percentage = percentage
        self.speed = speed
        self.status = status
        self.filesTransferred = filesTransferred
        self.totalFiles = totalFiles
        self.bytesTransferred = bytesTransferred
        self.totalBytes = totalBytes
    }
}

enum SyncStatus: Equatable {
    case idle
    case checking
    case syncing
    case completed
    case error(String)
    
    static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.checking, .checking), (.syncing, .syncing), (.completed, .completed):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

struct RemoteFile: Codable {
    let Path: String
    let Name: String
    let Size: Int64
    let MimeType: String
    let ModTime: String
    let IsDir: Bool
}
