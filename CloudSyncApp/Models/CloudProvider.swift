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
    case googlePhotos = "gphotos"
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
        case .googlePhotos: return "Google Photos"
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
        case .protonDrive: return "shield.checkered"
        case .googleDrive: return "g.circle.fill"
        case .dropbox: return "shippingbox.fill"
        case .oneDrive: return "cloud.fill"
        case .s3: return "externaldrive.fill.badge.icloud"
        case .icloud: return "icloud.fill"
        case .mega: return "m.circle.fill"
        case .box: return "cube.fill"
        case .pcloud: return "cloud.circle.fill"
        case .webdav: return "globe"
        case .sftp: return "terminal.fill"
        case .ftp: return "network"
        case .local: return "folder.fill"
        
        // Phase 1, Week 1
        case .nextcloud: return "cloud.circle"
        case .owncloud: return "cloud.circle.fill"
        case .seafile: return "server.rack"
        case .koofr: return "arrow.triangle.2.circlepath.circle"
        case .yandexDisk: return "y.circle.fill"
        case .mailRuCloud: return "envelope.circle.fill"
        
        // Phase 1, Week 2
        case .backblazeB2: return "b.circle.fill"
        case .wasabi: return "w.circle.fill"
        case .digitalOceanSpaces: return "water.waves"
        case .cloudflareR2: return "r.circle.fill"
        case .scaleway: return "s.circle.fill"
        case .oracleCloud: return "o.circle.fill"
        case .storj: return "lock.trianglebadge.exclamationmark.fill"
        case .filebase: return "square.stack.3d.up.fill"
        
        // Phase 1, Week 3
        case .googleCloudStorage: return "cloud.fill"
        case .azureBlob: return "cylinder.fill"
        case .azureFiles: return "doc.on.doc.fill"
        case .oneDriveBusiness: return "briefcase.fill"
        case .sharepoint: return "folder.badge.person.crop"
        case .alibabaOSS: return "a.circle.fill"
        
        // Additional Providers
        case .jottacloud: return "j.circle.fill"
        
        // OAuth Expansion: Media & Consumer
        case .googlePhotos: return "photo.stack.fill"
        case .flickr: return "camera.fill"
        case .sugarsync: return "arrow.triangle.2.circlepath"
        case .opendrive: return "externaldrive.fill"
        
        // OAuth Expansion: Specialized & Enterprise
        case .putio: return "arrow.down.circle.fill"
        case .premiumizeme: return "star.circle.fill"
        case .quatrix: return "q.circle.fill"
        case .filefabric: return "fabric.circle.fill"
        }
    }
    
    var brandColor: Color {
        switch self {
        case .protonDrive: return Color(red: 0.42, green: 0.31, blue: 0.78)
        case .googleDrive: return Color(red: 0.26, green: 0.52, blue: 0.96)
        case .dropbox: return Color(red: 0.0, green: 0.38, blue: 1.0)
        case .oneDrive: return Color(red: 0.0, green: 0.47, blue: 0.84)
        case .s3: return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .icloud: return Color(red: 0.2, green: 0.68, blue: 0.9)
        case .mega: return Color(red: 0.85, green: 0.0, blue: 0.0)
        case .box: return Color(red: 0.0, green: 0.38, blue: 0.65)
        case .pcloud: return Color(red: 0.0, green: 0.75, blue: 0.65)
        case .webdav: return Color.gray
        case .sftp: return Color.green
        case .ftp: return Color.orange
        case .local: return Color.secondary
        
        // Phase 1, Week 1
        case .nextcloud: return Color(red: 0.0, green: 0.51, blue: 0.79)
        case .owncloud: return Color(red: 0.04, green: 0.26, blue: 0.49)
        case .seafile: return Color(red: 0.0, green: 0.62, blue: 0.42)
        case .koofr: return Color(red: 0.2, green: 0.6, blue: 0.86)
        case .yandexDisk: return Color(red: 1.0, green: 0.2, blue: 0.0)
        case .mailRuCloud: return Color(red: 0.05, green: 0.52, blue: 0.97)
        
        // Phase 1, Week 2
        case .backblazeB2: return Color(red: 0.9, green: 0.11, blue: 0.14)
        case .wasabi: return Color(red: 0.0, green: 0.71, blue: 0.31)
        case .digitalOceanSpaces: return Color(red: 0.0, green: 0.42, blue: 0.98)
        case .cloudflareR2: return Color(red: 0.97, green: 0.49, blue: 0.09)
        case .scaleway: return Color(red: 0.31, green: 0.15, blue: 0.55)
        case .oracleCloud: return Color(red: 0.93, green: 0.22, blue: 0.13)
        case .storj: return Color(red: 0.0, green: 0.47, blue: 1.0)
        case .filebase: return Color(red: 0.18, green: 0.8, blue: 0.44)
        
        // Phase 1, Week 3
        case .googleCloudStorage: return Color(red: 0.26, green: 0.52, blue: 0.96)
        case .azureBlob: return Color(red: 0.0, green: 0.47, blue: 0.84)
        case .azureFiles: return Color(red: 0.0, green: 0.62, blue: 0.89)
        case .oneDriveBusiness: return Color(red: 0.0, green: 0.35, blue: 0.67)
        case .sharepoint: return Color(red: 0.01, green: 0.53, blue: 0.75)
        case .alibabaOSS: return Color(red: 1.0, green: 0.42, blue: 0.0)
        
        // Additional Providers
        case .jottacloud: return Color(red: 0.0, green: 0.58, blue: 0.77)
        
        // OAuth Expansion: Media & Consumer
        case .googlePhotos: return Color(red: 0.93, green: 0.35, blue: 0.35)
        case .flickr: return Color(red: 0.0, green: 0.42, blue: 0.98)
        case .sugarsync: return Color(red: 0.0, green: 0.67, blue: 0.93)
        case .opendrive: return Color(red: 0.29, green: 0.67, blue: 0.31)
        
        // OAuth Expansion: Specialized & Enterprise
        case .putio: return Color(red: 0.96, green: 0.65, blue: 0.14)
        case .premiumizeme: return Color(red: 0.85, green: 0.33, blue: 0.0)
        case .quatrix: return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .filefabric: return Color(red: 0.4, green: 0.2, blue: 0.6)
        }
    }
    
    var rcloneType: String {
        switch self {
        case .protonDrive: return "protondrive"
        case .googleDrive: return "drive"
        case .dropbox: return "dropbox"
        case .oneDrive: return "onedrive"
        case .s3: return "s3"
        case .icloud: return "icloud"
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
        case .googlePhotos: return "gphotos"
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
        case .googlePhotos: return "gphotos"
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
        case .icloud: return false
        default: return true
        }
    }
    
    var isExperimental: Bool {
        switch self {
        case .jottacloud: return true
        default: return false
        }
    }
    
    var experimentalNote: String? {
        switch self {
        case .jottacloud: return "⚠️ Experimental: Requires manual rclone OAuth setup due to backend limitations"
        default: return nil
        }
    }
}

struct CloudRemote: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var type: CloudProviderType
    var isConfigured: Bool
    var path: String
    var isEncrypted: Bool
    var customRcloneName: String?  // Optional custom rclone name
    
    init(id: UUID = UUID(), name: String, type: CloudProviderType, isConfigured: Bool = false, path: String = "", isEncrypted: Bool = false, customRcloneName: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.isConfigured = isConfigured
        self.path = path
        self.isEncrypted = isEncrypted
        self.customRcloneName = customRcloneName
    }
    
    var displayIcon: String { type.iconName }
    var displayColor: Color { type.brandColor }
    
    /// The name used in rclone config
    var rcloneName: String {
        if let custom = customRcloneName, !custom.isEmpty {
            return custom
        }
        // Use provider's default rclone name
        return type.defaultRcloneName
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
