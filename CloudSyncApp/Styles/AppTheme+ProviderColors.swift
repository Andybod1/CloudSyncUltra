//
//  AppTheme+ProviderColors.swift
//  CloudSyncApp
//
//  Extension providing provider brand colors for the AppTheme design system.
//  Colors sourced from official brand guidelines for accuracy.
//

import SwiftUI

// MARK: - Provider Color Constants

extension AppTheme {

    /// Provider brand colors with official hex values
    struct ProviderColors {
        // Major Cloud Providers
        static let googleDrive = Color(hex: "4285F4")
        static let dropbox = Color(hex: "0061FF")
        static let oneDrive = Color(hex: "0078D4")
        static let iCloud = Color(hex: "3693F3")
        static let box = Color(hex: "0061D5")
        static let mega = Color(hex: "D9272E")
        static let pCloud = Color(hex: "00C0FF")

        // Security-focused
        static let protonDrive = Color(hex: "6D4AFF")

        // Object Storage
        static let amazonS3 = Color(hex: "FF9900")
        static let backblazeB2 = Color(hex: "E21E29")
        static let wasabi = Color(hex: "00B64F")
        static let cloudflareR2 = Color(hex: "F87D1E")
        static let digitalOceanSpaces = Color(hex: "006BF4")
        static let storj = Color(hex: "0078FF")

        // Enterprise
        static let googleCloudStorage = Color(hex: "4285F4")
        static let azureBlob = Color(hex: "0078D4")
        static let azureFiles = Color(hex: "009EDA")
        static let oneDriveBusiness = Color(hex: "0058AD")
        static let sharepoint = Color(hex: "0287BF")
        static let alibabaOSS = Color(hex: "FF6A00")

        // Self-hosted
        static let nextcloud = Color(hex: "0082C9")
        static let owncloud = Color(hex: "0B427C")
        static let seafile = Color(hex: "009E6B")
        static let koofr = Color(hex: "3399DB")

        // International
        static let yandexDisk = Color(hex: "FF3333")
        static let mailRuCloud = Color(hex: "0D85F8")
        static let jottacloud = Color(hex: "0093C5")

        // Media & Specialty
        static let flickr = Color(hex: "0063DC")
        static let sugarsync = Color(hex: "00ABE6")
        static let opendrive = Color(hex: "4AAB4F")
        static let putio = Color(hex: "F5A622")
        static let premiumizeme = Color(hex: "DA5500")
        static let quatrix = Color(hex: "3366CC")
        static let filefabric = Color(hex: "663399")

        // Protocols (generic)
        static let webdav = Color.gray
        static let sftp = Color.green
        static let ftp = Color.orange
        static let local = Color.secondary
    }

    /// Returns the brand color for a provider type string (rclone name)
    /// - Parameter providerType: The provider type string (e.g., "gdrive", "dropbox")
    /// - Returns: The brand color for the provider, or a default gray if not found
    static func providerColor(for providerType: String) -> Color {
        switch providerType.lowercased() {
        case "gdrive", "drive", "google":
            return ProviderColors.googleDrive
        case "dropbox":
            return ProviderColors.dropbox
        case "onedrive":
            return ProviderColors.oneDrive
        case "icloud", "iclouddrive":
            return ProviderColors.iCloud
        case "s3", "amazon":
            return ProviderColors.amazonS3
        case "proton", "protondrive":
            return ProviderColors.protonDrive
        case "box":
            return ProviderColors.box
        case "mega":
            return ProviderColors.mega
        case "pcloud":
            return ProviderColors.pCloud
        case "b2", "backblaze":
            return ProviderColors.backblazeB2
        case "wasabi":
            return ProviderColors.wasabi
        case "r2", "cloudflare":
            return ProviderColors.cloudflareR2
        case "spaces", "digitalocean":
            return ProviderColors.digitalOceanSpaces
        case "storj":
            return ProviderColors.storj
        case "gcs", "googlecloud":
            return ProviderColors.googleCloudStorage
        case "azureblob":
            return ProviderColors.azureBlob
        case "azurefiles":
            return ProviderColors.azureFiles
        case "onedrive-business":
            return ProviderColors.oneDriveBusiness
        case "sharepoint":
            return ProviderColors.sharepoint
        case "oss", "alibaba":
            return ProviderColors.alibabaOSS
        case "nextcloud":
            return ProviderColors.nextcloud
        case "owncloud":
            return ProviderColors.owncloud
        case "seafile":
            return ProviderColors.seafile
        case "koofr":
            return ProviderColors.koofr
        case "yandex":
            return ProviderColors.yandexDisk
        case "mailru":
            return ProviderColors.mailRuCloud
        case "jottacloud":
            return ProviderColors.jottacloud
        case "flickr":
            return ProviderColors.flickr
        case "sugarsync":
            return ProviderColors.sugarsync
        case "opendrive":
            return ProviderColors.opendrive
        case "putio":
            return ProviderColors.putio
        case "premiumizeme":
            return ProviderColors.premiumizeme
        case "quatrix":
            return ProviderColors.quatrix
        case "filefabric":
            return ProviderColors.filefabric
        case "webdav":
            return ProviderColors.webdav
        case "sftp":
            return ProviderColors.sftp
        case "ftp":
            return ProviderColors.ftp
        case "local":
            return ProviderColors.local
        default:
            return Color.secondary
        }
    }

    /// Returns the SF Symbol name for a provider type string
    /// - Parameter providerType: The provider type string (e.g., "gdrive", "dropbox")
    /// - Returns: The SF Symbol name for the provider
    static func providerIcon(for providerType: String) -> String {
        switch providerType.lowercased() {
        case "gdrive", "drive", "google":
            return "externaldrive.fill"
        case "dropbox":
            return "shippingbox.fill"
        case "onedrive":
            return "cloud.fill"
        case "icloud", "iclouddrive":
            return "icloud.fill"
        case "s3", "amazon":
            return "cube.fill"
        case "proton", "protondrive":
            return "lock.shield.fill"
        case "box":
            return "archivebox.fill"
        case "mega":
            return "m.square.fill"
        case "pcloud":
            return "cloud.fill"
        case "b2", "backblaze":
            return "externaldrive.fill"
        default:
            return "cloud.fill"
        }
    }
}

// MARK: - Color Extension for Provider Lookup

extension Color {
    /// Get a provider brand color by type string
    static func provider(_ type: String) -> Color {
        AppTheme.providerColor(for: type)
    }
}
