//
//  RcloneManager.swift
//  CloudSyncApp
//
//  Manages rclone binary, configuration, and process execution
//

import Foundation

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
    
    // MARK: - Cloud Provider Setup Methods
    
    func setupProtonDrive(username: String, password: String, twoFactorCode: String? = nil) async throws {
        var params: [String: String] = [
            "username": username,
            "password": password
        ]
        if let code = twoFactorCode, !code.isEmpty {
            params["2fa"] = code
        }
        try await createRemote(
            name: "proton",
            type: "protondrive",
            parameters: params
        )
    }
    
    func setupGoogleDrive(remoteName: String) async throws {
        // Google Drive uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "drive")
    }
    
    func setupDropbox(remoteName: String) async throws {
        // Dropbox uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "dropbox")
    }
    
    func setupOneDrive(remoteName: String) async throws {
        // OneDrive uses OAuth - opens browser for authentication
        try await createRemoteInteractive(name: remoteName, type: "onedrive")
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
    
    func setupJottacloud(remoteName: String, username: String? = nil, password: String? = nil, device: String? = nil) async throws {
        if let username = username, let password = password {
            // Use personal login token (password field contains the token)
            var params: [String: String] = [
                "user": username,
                "pass": password  // This should be the personal login token from jottacloud.com
            ]
            
            if let device = device {
                params["device"] = device
            }
            
            try await createRemote(name: remoteName, type: "jottacloud", parameters: params)
        } else {
            // OAuth authentication (alternative)
            try await createRemoteInteractive(name: remoteName, type: "jottacloud")
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
        encryptFilenames: Bool = true,
        wrappedRemote: String = "proton:"
    ) async throws {
        // First, obscure the password and salt using rclone
        let obscuredPassword = try await obscurePassword(password)
        let obscuredSalt = try await obscurePassword(salt)
        
        // Determine filename encryption mode
        let filenameEncryption = encryptFilenames ? "standard" : "off"
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rclonePath)
        process.arguments = [
            "config", "create",
            EncryptionManager.shared.encryptedRemoteName,
            "crypt",
            "remote", wrappedRemote,
            "password", obscuredPassword,
            "password2", obscuredSalt,
            "filename_encryption", filenameEncryption,
            "directory_name_encryption", encryptFilenames ? "true" : "false",
            "--config", configPath,
            "--non-interactive"
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
            throw RcloneError.encryptionSetupFailed(errorString)
        }
    }
    
    /// Removes the encrypted remote configuration
    func removeEncryptedRemote() async throws {
        try await deleteRemote(name: EncryptionManager.shared.encryptedRemoteName)
    }
    
    /// Obscures a password using rclone's obscure command.
    /// Rclone requires passwords in its config to be obscured.
    private func obscurePassword(_ password: String) async throws -> String {
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
            Task {
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
                
                var args = [
                    "copy",
                    localPath,
                    "\(remoteName):\(remotePath)",
                    "--config", self.configPath,
                    "--progress",
                    "--stats", "500ms",  // Update every 500ms instead of 1s
                    "--stats-one-line",
                    "-v"  // Less verbose to reduce noise
                ]
                
                // Add bandwidth limits
                args.append(contentsOf: self.getBandwidthArgs())
                
                process.arguments = args
                
                let stderrPipe = Pipe()
                process.standardOutput = stderrPipe  // Redirect both to same pipe
                process.standardError = stderrPipe
                
                log("Starting upload: \(localPath) -> \(remoteName):\(remotePath)")
                
                // Read stderr in chunks
                let handle = stderrPipe.fileHandleForReading
                var buffer = Data()
                
                handle.readabilityHandler = { fileHandle in
                    let data = fileHandle.availableData
                    if !data.isEmpty {
                        buffer.append(data)
                        
                        // Process complete lines (split by both \n and \r)
                        if let output = String(data: buffer, encoding: .utf8) {
                            // Split by newline OR carriage return
                            let lines = output.components(separatedBy: CharacterSet(charactersIn: "\n\r"))
                            
                            // Process all complete lines (all but last)
                            for i in 0..<(lines.count - 1) {
                                let line = lines[i]
                                if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                                    log("Raw line: \(line)")
                                    if let progress = self.parseProgress(from: line) {
                                        log("Parsed progress: \(progress.percentage)% - \(progress.speed)")
                                        continuation.yield(progress)
                                    } else {
                                        log("Line did not parse as progress")
                                    }
                                }
                            }
                            
                            // Keep incomplete line in buffer
                            if let lastLine = lines.last?.data(using: .utf8) {
                                buffer = lastLine
                            } else {
                                buffer = Data()
                            }
                        }
                    }
                }
                
                do {
                    try process.run()
                    self.process = process
                    
                    process.waitUntilExit()
                    
                    handle.readabilityHandler = nil
                    
                    // Process any remaining buffer
                    if !buffer.isEmpty, let output = String(data: buffer, encoding: .utf8) {
                        log("Final buffer: \(output)")
                        if let progress = self.parseProgress(from: output) {
                            continuation.yield(progress)
                        }
                    }
                    
                    log("Upload exit code: \(process.terminationStatus)")
                    
                    if process.terminationStatus == 0 {
                        // Yield 100% completion
                        continuation.yield(SyncProgress(percentage: 100, speed: "", status: .completed))
                    }
                    
                    continuation.finish()
                } catch {
                    log("Upload error: \(error.localizedDescription)")
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
    
    // MARK: - Progress Parsing
    
    private func parseProgress(from output: String) -> SyncProgress? {
        // Parse rclone output for progress information
        // Format 1: "Transferred:   	    1.234 MiB / 10.567 MiB, 12%, 234.5 KiB/s, ETA 30s"
        // Format 2: "18 B / 18 B, 100%, 17 B/s, ETA 0s" (with --stats-one-line)
        
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            // Format 1: Look for "Transferred:" line
            if line.contains("Transferred:") {
                let components = line.components(separatedBy: ",")
                
                if components.count >= 3 {
                    // Parse percentage
                    let percentageStr = components[1].trimmingCharacters(in: .whitespaces)
                    let percentage = Double(percentageStr.replacingOccurrences(of: "%", with: "")) ?? 0
                    
                    // Parse speed
                    let speedStr = components[2].trimmingCharacters(in: .whitespaces)
                    
                    return SyncProgress(
                        percentage: percentage,
                        speed: speedStr,
                        status: .syncing
                    )
                }
            }
            
            // Format 2: Look for lines with percentage and speed (e.g., "18 B / 18 B, 100%, 17 B/s, ETA 0s")
            // This format appears with --stats-one-line
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.contains("%") && trimmedLine.contains("/") && trimmedLine.contains("B/s") {
                let components = trimmedLine.components(separatedBy: ",")
                
                if components.count >= 3 {
                    // Parse percentage (second component)
                    let percentageStr = components[1].trimmingCharacters(in: .whitespaces)
                    let percentage = Double(percentageStr.replacingOccurrences(of: "%", with: "")) ?? 0
                    
                    // Parse speed (third component)
                    let speedStr = components[2].trimmingCharacters(in: .whitespaces)
                    
                    return SyncProgress(
                        percentage: percentage,
                        speed: speedStr,
                        status: .syncing
                    )
                }
            }
            
            if line.contains("Checks:") || line.contains("Need to transfer") {
                return SyncProgress(percentage: 0, speed: "Checking files...", status: .checking)
            }
            
            if line.contains("ERROR") {
                return SyncProgress(percentage: 0, speed: "", status: .error(line))
            }
        }
        
        return nil
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

enum RcloneError: LocalizedError {
    case configurationFailed(String)
    case syncFailed(String)
    case notInstalled
    case encryptionSetupFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .configurationFailed(let message):
            return "Configuration failed: \(message)"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .notInstalled:
            return "rclone is not installed. Please install via: brew install rclone"
        case .encryptionSetupFailed(let message):
            return "Encryption setup failed: \(message)"
        }
    }
}
