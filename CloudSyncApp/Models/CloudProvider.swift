//
//  CloudProvider.swift
//  CloudSyncApp
//
//  Cloud provider definitions and configurations
//

import SwiftUI

enum CloudProviderType: String, CaseIterable, Codable, Identifiable, Hashable {
    // Original providers
    case protonDrive = "proton"
    case googleDrive = "gdrive"
    case dropbox = "dropbox"
    case oneDrive = "onedrive"
    case s3 = "s3"
    case icloud = "icloud"
    case mega = "mega"
    case box = "box"
    case pcloud = "pcloud"
    case webdav = "webdav"
    case sftp = "sftp"
    case ftp = "ftp"
    case local = "local"
    
    // Phase 1, Week 1: Self-Hosted & International
    case nextcloud = "nextcloud"
    case owncloud = "owncloud"
    case seafile = "seafile"
    case koofr = "koofr"
    case yandexDisk = "yandex"
    case mailRuCloud = "mailru"
    
    // Phase 1, Week 2: Object Storage
    case backblazeB2 = "b2"
    case wasabi = "wasabi"
    case digitalOceanSpaces = "spaces"
    case cloudflareR2 = "r2"
    case scaleway = "scaleway"
    case oracleCloud = "oraclecloud"
    case storj = "storj"
    case filebase = "filebase"
    
    // Phase 1, Week 3: Enterprise Services
    case googleCloudStorage = "gcs"
    case azureBlob = "azureblob"
    case azureFiles = "azurefiles"
    case oneDriveBusiness = "onedrive-business"
    case sharepoint = "sharepoint"
    case alibabaOSS = "oss"
    
    // Additional Providers: Nordic & Unlimited Storage
    case jottacloud = "jottacloud"
    
    // OAuth Services Expansion: Media & Consumer
    case flickr = "flickr"
    case sugarsync = "sugarsync"
    case opendrive = "opendrive"
    
    // OAuth Services Expansion: Specialized & Enterprise
    case putio = "putio"
    case premiumizeme = "premiumizeme"
    case quatrix = "quatrix"
    case filefabric = "filefabric"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .protonDrive: return "Proton Drive"
        case .googleDrive: return "Google Drive"
        case .dropbox: return "Dropbox"
        case .oneDrive: return "OneDrive"
        case .s3: return "Amazon S3"
        case .icloud: return "iCloud Drive"
        case .mega: return "MEGA"
        case .box: return "Box"
        case .pcloud: return "pCloud"
        case .webdav: return "WebDAV"
        case .sftp: return "SFTP"
        case .ftp: return "FTP"
        case .local: return "Local Storage"
        
        // Phase 1, Week 1
        case .nextcloud: return "Nextcloud"
        case .owncloud: return "ownCloud"
        case .seafile: return "Seafile"
        case .koofr: return "Koofr"
        case .yandexDisk: return "Yandex Disk"
        case .mailRuCloud: return "Mail.ru Cloud"
        
        // Phase 1, Week 2
        case .backblazeB2: return "Backblaze B2"
        case .wasabi: return "Wasabi"
        case .digitalOceanSpaces: return "DigitalOcean Spaces"
        case .cloudflareR2: return "Cloudflare R2"
        case .scaleway: return "Scaleway"
        case .oracleCloud: return "Oracle Cloud"
        case .storj: return "Storj"
        case .filebase: return "Filebase"
        
        // Phase 1, Week 3
        case .googleCloudStorage: return "Google Cloud Storage"
        case .azureBlob: return "Azure Blob Storage"
        case .azureFiles: return "Azure Files"
        case .oneDriveBusiness: return "OneDrive for Business"
        case .sharepoint: return "SharePoint"
        case .alibabaOSS: return "Alibaba Cloud OSS"
        
        // Additional Providers
        case .jottacloud: return "Jottacloud"
        
        // OAuth Expansion: Media & Consumer
        case .flickr: return "Flickr"
        case .sugarsync: return "SugarSync"
        case .opendrive: return "OpenDrive"
        
        // OAuth Expansion: Specialized & Enterprise
        case .putio: return "Put.io"
        case .premiumizeme: return "Premiumize.me"
        case .quatrix: return "Quatrix"
        case .filefabric: return "File Fabric"
        }
    }
    
    var iconName: String {
        switch self {
        // Major cloud providers - SF Symbols with brand recognition
        case .protonDrive: return "lock.shield.fill"
        case .googleDrive: return "externaldrive.fill"
        case .dropbox: return "shippingbox.fill"
        case .oneDrive: return "cloud.fill"
        case .s3: return "cube.fill"
        case .icloud: return "icloud.fill"
        case .mega: return "m.square.fill"
        case .box: return "archivebox.fill"
        case .pcloud: return "cloud.fill"
        case .webdav: return "globe"
        case .sftp: return "terminal.fill"
        case .ftp: return "network"
        case .local: return "folder.fill"

        // Phase 1, Week 1: Self-Hosted & International
        case .nextcloud: return "cloud.circle"
        case .owncloud: return "cloud.circle.fill"
        case .seafile: return "server.rack"
        case .koofr: return "arrow.triangle.2.circlepath.circle"
        case .yandexDisk: return "y.circle.fill"
        case .mailRuCloud: return "envelope.circle.fill"

        // Phase 1, Week 2: Object Storage
        case .backblazeB2: return "externaldrive.fill"
        case .wasabi: return "leaf.fill"
        case .digitalOceanSpaces: return "water.waves"
        case .cloudflareR2: return "flame.fill"
        case .scaleway: return "square.stack.3d.up.fill"
        case .oracleCloud: return "building.2.fill"
        case .storj: return "lock.shield.fill"
        case .filebase: return "square.stack.3d.up.fill"

        // Phase 1, Week 3: Enterprise Services
        case .googleCloudStorage: return "cloud.fill"
        case .azureBlob: return "cylinder.fill"
        case .azureFiles: return "doc.on.doc.fill"
        case .oneDriveBusiness: return "briefcase.fill"
        case .sharepoint: return "folder.badge.person.crop"
        case .alibabaOSS: return "building.fill"

        // Additional Providers: Nordic & Unlimited Storage
        case .jottacloud: return "cloud.fill"

        // OAuth Expansion: Media & Consumer
        case .flickr: return "camera.fill"
        case .sugarsync: return "arrow.triangle.2.circlepath"
        case .opendrive: return "externaldrive.fill"

        // OAuth Expansion: Specialized & Enterprise
        case .putio: return "arrow.down.circle.fill"
        case .premiumizeme: return "star.circle.fill"
        case .quatrix: return "square.grid.3x3.fill"
        case .filefabric: return "rectangle.grid.2x2.fill"
        }
    }
    
    var brandColor: Color {
        switch self {
        // Major cloud providers - official brand colors (hex values)
        case .protonDrive: return Color(hex: "6D4AFF")  // Proton Purple
        case .googleDrive: return Color(hex: "4285F4")  // Google Blue
        case .dropbox: return Color(hex: "0061FF")      // Dropbox Blue
        case .oneDrive: return Color(hex: "0078D4")     // Microsoft Blue
        case .s3: return Color(hex: "FF9900")           // AWS Orange
        case .icloud: return Color(hex: "3693F3")       // iCloud Blue
        case .mega: return Color(hex: "D9272E")         // MEGA Red
        case .box: return Color(hex: "0061D5")          // Box Blue
        case .pcloud: return Color(hex: "00C0FF")       // pCloud Cyan
        case .webdav: return Color.gray
        case .sftp: return Color.green
        case .ftp: return Color.orange
        case .local: return Color.secondary

        // Phase 1, Week 1: Self-Hosted & International
        case .nextcloud: return Color(hex: "0082C9")    // Nextcloud Blue
        case .owncloud: return Color(hex: "0B427C")     // ownCloud Blue
        case .seafile: return Color(hex: "009E6B")      // Seafile Green
        case .koofr: return Color(hex: "3399DB")        // Koofr Blue
        case .yandexDisk: return Color(hex: "FF3333")   // Yandex Red
        case .mailRuCloud: return Color(hex: "0D85F8")  // Mail.ru Blue

        // Phase 1, Week 2: Object Storage
        case .backblazeB2: return Color(hex: "E21E29")  // Backblaze Red
        case .wasabi: return Color(hex: "00B64F")       // Wasabi Green
        case .digitalOceanSpaces: return Color(hex: "006BF4")  // DO Blue
        case .cloudflareR2: return Color(hex: "F87D1E") // Cloudflare Orange
        case .scaleway: return Color(hex: "4F0599")     // Scaleway Purple
        case .oracleCloud: return Color(hex: "F80000")  // Oracle Red
        case .storj: return Color(hex: "0078FF")        // Storj Blue
        case .filebase: return Color(hex: "2ECC71")     // Filebase Green

        // Phase 1, Week 3: Enterprise Services
        case .googleCloudStorage: return Color(hex: "4285F4")  // Google Blue
        case .azureBlob: return Color(hex: "0078D4")    // Azure Blue
        case .azureFiles: return Color(hex: "009EDA")   // Azure Light Blue
        case .oneDriveBusiness: return Color(hex: "0058AD")    // MS Business Blue
        case .sharepoint: return Color(hex: "0287BF")   // SharePoint Blue
        case .alibabaOSS: return Color(hex: "FF6A00")   // Alibaba Orange

        // Additional Providers: Nordic & Unlimited Storage
        case .jottacloud: return Color(hex: "0093C5")   // Jottacloud Blue

        // OAuth Expansion: Media & Consumer
        case .flickr: return Color(hex: "0063DC")       // Flickr Blue
        case .sugarsync: return Color(hex: "00ABE6")    // SugarSync Blue
        case .opendrive: return Color(hex: "4AAB4F")    // OpenDrive Green

        // OAuth Expansion: Specialized & Enterprise
        case .putio: return Color(hex: "F5A622")        // Put.io Gold
        case .premiumizeme: return Color(hex: "DA5500") // Premiumize Orange
        case .quatrix: return Color(hex: "3366CC")      // Quatrix Blue
        case .filefabric: return Color(hex: "663399")   // FileFabric Purple
        }
    }
    
    var rcloneType: String {
        switch self {
        case .protonDrive: return "protondrive"
        case .googleDrive: return "drive"
        case .dropbox: return "dropbox"
        case .oneDrive: return "onedrive"
        case .s3: return "s3"
        case .icloud: return "iclouddrive"
        case .mega: return "mega"
        case .box: return "box"
        case .pcloud: return "pcloud"
        case .webdav: return "webdav"
        case .sftp: return "sftp"
        case .ftp: return "ftp"
        case .local: return "local"
        
        // Phase 1, Week 1
        case .nextcloud: return "webdav"
        case .owncloud: return "webdav"
        case .seafile: return "seafile"
        case .koofr: return "koofr"
        case .yandexDisk: return "yandex"
        case .mailRuCloud: return "mailru"
        
        // Phase 1, Week 2
        case .backblazeB2: return "b2"
        case .wasabi: return "s3"
        case .digitalOceanSpaces: return "s3"
        case .cloudflareR2: return "s3"
        case .scaleway: return "s3"
        case .oracleCloud: return "s3"
        case .storj: return "storj"
        case .filebase: return "s3"
        
        // Phase 1, Week 3
        case .googleCloudStorage: return "google cloud storage"
        case .azureBlob: return "azureblob"
        case .azureFiles: return "azurefiles"
        case .oneDriveBusiness: return "onedrive"
        case .sharepoint: return "sharepoint"
        case .alibabaOSS: return "oss"
        
        // Additional Providers
        case .jottacloud: return "jottacloud"
        
        // OAuth Expansion: Media & Consumer
        case .flickr: return "flickr"
        case .sugarsync: return "sugarsync"
        case .opendrive: return "opendrive"
        
        // OAuth Expansion: Specialized & Enterprise
        case .putio: return "putio"
        case .premiumizeme: return "premiumizeme"
        case .quatrix: return "quatrix"
        case .filefabric: return "filefabric"
        }
    }
    
    /// Default rclone remote name for this provider type
    var defaultRcloneName: String {
        switch self {
        case .protonDrive: return "proton"
        case .googleDrive: return "google"
        case .dropbox: return "dropbox"
        case .oneDrive: return "onedrive"
        case .s3: return "s3"
        case .mega: return "mega"
        case .box: return "box"
        case .pcloud: return "pcloud"
        case .webdav: return "webdav"
        case .sftp: return "sftp"
        case .ftp: return "ftp"
        
        // Phase 1, Week 1
        case .nextcloud: return "nextcloud"
        case .owncloud: return "owncloud"
        case .seafile: return "seafile"
        case .koofr: return "koofr"
        case .yandexDisk: return "yandex"
        case .mailRuCloud: return "mailru"
        
        // Phase 1, Week 2
        case .backblazeB2: return "b2"
        case .wasabi: return "wasabi"
        case .digitalOceanSpaces: return "spaces"
        case .cloudflareR2: return "r2"
        case .scaleway: return "scaleway"
        case .oracleCloud: return "oraclecloud"
        case .storj: return "storj"
        case .filebase: return "filebase"
        
        // Phase 1, Week 3
        case .googleCloudStorage: return "gcs"
        case .azureBlob: return "azureblob"
        case .azureFiles: return "azurefiles"
        case .oneDriveBusiness: return "onedrive-business"
        case .sharepoint: return "sharepoint"
        case .alibabaOSS: return "oss"
        
        // Additional Providers
        case .jottacloud: return "jottacloud"
        
        // OAuth Expansion: Media & Consumer
        case .flickr: return "flickr"
        case .sugarsync: return "sugarsync"
        case .opendrive: return "opendrive"
        
        // OAuth Expansion: Specialized & Enterprise
        case .putio: return "putio"
        case .premiumizeme: return "premiumizeme"
        case .quatrix: return "quatrix"
        case .filefabric: return "filefabric"
        
        default: return rawValue
        }
    }
    
    var isSupported: Bool {
        switch self {
        case .icloud: return true  // Enable iCloud
        default: return true
        }
    }
    
    var isExperimental: Bool {
        switch self {
        case .jottacloud: return false
        default: return false
        }
    }
    
    var experimentalNote: String? {
        switch self {
        case .jottacloud: return "Requires Personal Login Token (generate at jottacloud.com/web/secure)"
        default: return nil
        }
    }
    
    /// Whether this provider uses OAuth for authentication
    var requiresOAuth: Bool {
        switch self {
        case .googleDrive, .dropbox, .oneDrive, .box, .yandexDisk,
             .googleCloudStorage, .oneDriveBusiness, .sharepoint,
             .flickr, .sugarsync, .opendrive,
             .putio, .premiumizeme, .quatrix, .filefabric, .pcloud:
            return true
        default:
            return false
        }
    }
}

struct CloudRemote: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var type: CloudProviderType
    var isConfigured: Bool
    var path: String
    var isEncrypted: Bool  // Current encryption view state (toggle)
    var customRcloneName: String?  // Optional custom rclone name
    var sortOrder: Int  // For custom ordering in sidebar
    var accountName: String?  // Email/username for the connected account
    
    init(id: UUID = UUID(), name: String, type: CloudProviderType, isConfigured: Bool = false, path: String = "", isEncrypted: Bool = false, customRcloneName: String? = nil, sortOrder: Int = 0, accountName: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.isConfigured = isConfigured
        self.path = path
        self.isEncrypted = isEncrypted
        self.customRcloneName = customRcloneName
        self.sortOrder = sortOrder
        self.accountName = accountName
    }
    
    var displayIcon: String { type.iconName }
    var displayColor: Color { type.brandColor }
    
    /// The name used in rclone config (base remote)
    var rcloneName: String {
        if let custom = customRcloneName, !custom.isEmpty {
            return custom
        }
        // Use provider's default rclone name
        return type.defaultRcloneName
    }
    
    /// The crypt remote name for this remote
    var cryptRemoteName: String {
        EncryptionManager.shared.getCryptRemoteName(for: rcloneName)
    }
    
    /// Check if encryption is configured for this remote
    var hasEncryptionConfigured: Bool {
        EncryptionManager.shared.isEncryptionConfigured(for: rcloneName)
    }
    
    /// Get the effective remote name based on encryption state
    /// Returns crypt remote if encryption is ON and configured, otherwise base remote
    var effectiveRemoteName: String {
        if isEncrypted && hasEncryptionConfigured {
            return cryptRemoteName
        }
        return rcloneName
    }
    
    /// Check if currently viewing through encrypted lens
    var isViewingEncrypted: Bool {
        isEncrypted && hasEncryptionConfigured
    }
    
    // Hashable conformance - hash by id only
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FileItem: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64
    let modifiedDate: Date
    let mimeType: String?
    
    init(id: UUID = UUID(), name: String, path: String, isDirectory: Bool, size: Int64 = 0, modifiedDate: Date = Date(), mimeType: String? = nil) {
        self.id = id
        self.name = name
        self.path = path
        self.isDirectory = isDirectory
        self.size = size
        self.modifiedDate = modifiedDate
        self.mimeType = mimeType
    }
    
    var icon: String {
        if isDirectory { return "folder.fill" }
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "doc.richtext.fill"
        case "jpg", "jpeg", "png", "gif", "webp", "heic": return "photo.fill"
        case "mp4", "mov", "avi", "mkv": return "film.fill"
        case "mp3", "wav", "aac", "flac": return "music.note"
        case "zip", "rar", "7z", "tar", "gz": return "doc.zipper"
        case "txt", "md": return "doc.plaintext.fill"
        case "swift", "py", "js", "ts", "html", "css": return "chevron.left.forwardslash.chevron.right"
        default: return "doc.fill"
        }
    }
    
    var formattedSize: String {
        if isDirectory { return "--" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: modifiedDate)
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Fast-List Support Extension (#71)
extension CloudProviderType {
    /// Whether this provider supports the --fast-list flag for efficient directory listing
    /// Fast-list uses more memory but reduces API calls significantly for large directories
    var supportsFastList: Bool {
        switch self {
        case .googleDrive, .googleCloudStorage, .s3, .dropbox, .box, .oneDrive, .oneDriveBusiness, .backblazeB2:
            return true
        // S3-compatible providers also support fast-list
        case .wasabi, .digitalOceanSpaces, .cloudflareR2, .scaleway, .oracleCloud, .filebase:
            return true
        default:
            return false
        }
    }

    /// Provider-specific parallelism configuration for optimal transfer performance (#70)
    var defaultParallelism: (transfers: Int, checkers: Int) {
        switch self {
        case .googleDrive, .googleCloudStorage:
            return (transfers: 8, checkers: 16)
        case .dropbox:
            return (transfers: 4, checkers: 8)
        case .s3, .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2, .scaleway, .oracleCloud, .filebase, .storj:
            return (transfers: 16, checkers: 32)
        case .local, .sftp:
            return (transfers: 8, checkers: 16)
        case .protonDrive:
            return (transfers: 2, checkers: 4) // Rate limited
        case .oneDrive, .oneDriveBusiness, .sharepoint:
            return (transfers: 4, checkers: 8)
        case .box:
            return (transfers: 4, checkers: 8)
        case .mega:
            return (transfers: 4, checkers: 8)
        case .jottacloud:
            return (transfers: 4, checkers: 8)
        default:
            return (transfers: 4, checkers: 16) // Conservative default
        }
    }
}

// MARK: - iCloud Detection Extension
extension CloudProviderType {
    /// Path to local iCloud Drive folder on macOS
    static let iCloudLocalPath: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
    }()

    /// Check if iCloud Drive is available locally
    static var isLocalICloudAvailable: Bool {
        FileManager.default.fileExists(atPath: iCloudLocalPath.path)
    }

    /// Get iCloud Drive status message
    static var iCloudStatusMessage: String {
        if isLocalICloudAvailable {
            return "iCloud Drive folder detected"
        } else {
            return "iCloud Drive not found. Make sure you're signed into iCloud on this Mac."
        }
    }
}
