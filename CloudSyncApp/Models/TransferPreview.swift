//
//  TransferPreview.swift
//  CloudSyncApp
//
//  Preview model for dry-run transfer operations
//

import Foundation

/// Represents a preview of what a transfer operation will do
struct TransferPreview {
    let filesToTransfer: [PreviewItem]
    let filesToDelete: [PreviewItem]
    let filesToUpdate: [PreviewItem]
    let totalSize: Int64
    let estimatedTime: TimeInterval?

    var totalItems: Int {
        filesToTransfer.count + filesToDelete.count + filesToUpdate.count
    }

    var isEmpty: Bool {
        totalItems == 0
    }

    /// Human-readable summary of the preview
    var summary: String {
        var parts: [String] = []
        if !filesToTransfer.isEmpty {
            parts.append("\(filesToTransfer.count) to transfer")
        }
        if !filesToUpdate.isEmpty {
            parts.append("\(filesToUpdate.count) to update")
        }
        if !filesToDelete.isEmpty {
            parts.append("\(filesToDelete.count) to delete")
        }
        if parts.isEmpty {
            return "No changes needed"
        }
        return parts.joined(separator: ", ")
    }

    /// Total size formatted for display
    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

struct PreviewItem: Identifiable {
    let id = UUID()
    let path: String
    let size: Int64
    let operation: PreviewOperation
    let modifiedDate: Date?

    /// Formatted size for display
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

enum PreviewOperation: String, Codable {
    case transfer = "Transfer"
    case delete = "Delete"
    case update = "Update"
    case skip = "Skip"

    var iconName: String {
        switch self {
        case .transfer: return "arrow.right.circle"
        case .delete: return "trash"
        case .update: return "arrow.triangle.2.circlepath"
        case .skip: return "forward"
        }
    }

    var colorName: String {
        switch self {
        case .transfer: return "blue"
        case .delete: return "red"
        case .update: return "orange"
        case .skip: return "gray"
        }
    }
}

/// Error type for preview operations
enum PreviewError: LocalizedError {
    case rcloneNotFound
    case invalidPath(String)
    case executionFailed(String)
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .rcloneNotFound:
            return "rclone binary not found"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .executionFailed(let message):
            return "Dry-run failed: \(message)"
        case .parseError(let message):
            return "Failed to parse output: \(message)"
        }
    }
}
