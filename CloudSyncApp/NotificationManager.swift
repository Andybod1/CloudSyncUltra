//
//  NotificationManager.swift
//  CloudSyncApp
//
//  Manages macOS notifications and Dock badge progress for file transfers
//  Issue #90: User Notifications for Completed Transfers
//

import Foundation
import UserNotifications
import AppKit
import os

/// Manages macOS notifications and Dock badge progress for CloudSync Ultra
/// Provides user feedback for transfer completion, errors, and progress
@MainActor
final class NotificationManager: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = NotificationManager()

    // MARK: - Properties

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "notifications")

    /// Whether notifications are enabled (persisted)
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    /// Whether notification sounds are enabled (persisted)
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled)
        }
    }

    /// Whether to show Dock badge progress (persisted)
    @Published var dockProgressEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dockProgressEnabled, forKey: Keys.dockProgressEnabled)
        }
    }

    /// Whether the system has granted notification permission
    @Published private(set) var permissionGranted: Bool = false

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let notificationsEnabled = "notificationsEnabled"
        static let soundEnabled = "notificationSoundEnabled"
        static let dockProgressEnabled = "dockProgressEnabled"
    }

    // MARK: - Notification Categories

    private enum Category {
        static let transferComplete = "TRANSFER_COMPLETE"
        static let transferError = "TRANSFER_ERROR"
        static let batchComplete = "BATCH_COMPLETE"
    }

    // MARK: - Initialization

    private override init() {
        // Load persisted preferences
        self.notificationsEnabled = UserDefaults.standard.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.soundEnabled = UserDefaults.standard.object(forKey: Keys.soundEnabled) as? Bool ?? true
        self.dockProgressEnabled = UserDefaults.standard.object(forKey: Keys.dockProgressEnabled) as? Bool ?? true

        super.init()

        // Set up notification categories for actions
        setupNotificationCategories()

        // Check current authorization status
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Setup

    /// Set up notification categories with actions
    private func setupNotificationCategories() {
        let showAction = UNNotificationAction(
            identifier: "SHOW_FILE",
            title: "Show in Finder",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: []
        )

        let retryAction = UNNotificationAction(
            identifier: "RETRY",
            title: "Retry",
            options: [.foreground]
        )

        let completeCategory = UNNotificationCategory(
            identifier: Category.transferComplete,
            actions: [showAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        let errorCategory = UNNotificationCategory(
            identifier: Category.transferError,
            actions: [retryAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        let batchCategory = UNNotificationCategory(
            identifier: Category.batchComplete,
            actions: [showAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            completeCategory,
            errorCategory,
            batchCategory
        ])
    }

    /// Check current authorization status without prompting
    private func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.permissionGranted = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Permission Request

    /// Request notification permission from the user
    /// - Returns: Whether permission was granted
    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])

            await MainActor.run {
                self.permissionGranted = granted
            }

            if granted {
                logger.info("Notification permission granted")
            } else {
                logger.warning("Notification permission denied by user")
            }

            return granted
        } catch {
            logger.error("Failed to request notification permission: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Send Notifications

    /// Send notification when a single file transfer completes successfully
    /// - Parameters:
    ///   - fileName: Name of the transferred file
    ///   - destination: Name of the destination (remote or local path)
    ///   - fileSize: Optional file size for display
    func sendTransferComplete(fileName: String, destination: String, fileSize: Int64? = nil) {
        guard notificationsEnabled && permissionGranted else {
            logger.debug("Notifications disabled or not permitted, skipping transfer complete notification")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Transfer Complete"

        if let size = fileSize {
            let sizeStr = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            content.body = "\(fileName) (\(sizeStr)) transferred to \(destination)"
        } else {
            content.body = "\(fileName) transferred to \(destination)"
        }

        content.sound = soundEnabled ? .default : nil
        content.categoryIdentifier = Category.transferComplete

        // Add user info for potential action handling
        content.userInfo = [
            "fileName": fileName,
            "destination": destination,
            "type": "transfer_complete"
        ]

        scheduleNotification(content: content)
        logger.info("Sent transfer complete notification for: \(fileName, privacy: .private)")
    }

    /// Send notification when a file transfer fails
    /// - Parameters:
    ///   - fileName: Name of the file that failed to transfer
    ///   - error: Error message describing what went wrong
    ///   - isRetryable: Whether the transfer can be retried
    func sendTransferError(fileName: String, error: String, isRetryable: Bool = true) {
        guard notificationsEnabled && permissionGranted else {
            logger.debug("Notifications disabled or not permitted, skipping transfer error notification")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Transfer Failed"
        content.body = "\(fileName): \(error)"

        // Use critical sound for errors if available, otherwise default
        if soundEnabled {
            if #available(macOS 12.0, *) {
                content.sound = .defaultCritical
            } else {
                content.sound = .default
            }
        }

        content.categoryIdentifier = Category.transferError

        // Add user info for retry action
        content.userInfo = [
            "fileName": fileName,
            "error": error,
            "isRetryable": isRetryable,
            "type": "transfer_error"
        ]

        scheduleNotification(content: content)
        logger.error("Sent transfer error notification for: \(fileName, privacy: .private) - \(error, privacy: .public)")
    }

    /// Send notification when a batch of files completes transfer
    /// - Parameters:
    ///   - count: Number of files transferred
    ///   - destination: Name of the destination
    ///   - totalSize: Optional total size of all files
    ///   - failedCount: Number of files that failed (0 if all succeeded)
    func sendBatchComplete(count: Int, destination: String, totalSize: Int64? = nil, failedCount: Int = 0) {
        guard notificationsEnabled && permissionGranted else {
            logger.debug("Notifications disabled or not permitted, skipping batch complete notification")
            return
        }

        let content = UNMutableNotificationContent()

        if failedCount > 0 {
            content.title = "Batch Transfer Completed with Errors"
            content.body = "\(count) files transferred, \(failedCount) failed - \(destination)"
            if soundEnabled {
                content.sound = .default
            }
        } else {
            content.title = "Batch Transfer Complete"
            if let size = totalSize {
                let sizeStr = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
                content.body = "\(count) files (\(sizeStr)) transferred to \(destination)"
            } else {
                content.body = "\(count) files transferred to \(destination)"
            }
            content.sound = soundEnabled ? .default : nil
        }

        content.categoryIdentifier = Category.batchComplete

        content.userInfo = [
            "count": count,
            "destination": destination,
            "failedCount": failedCount,
            "type": "batch_complete"
        ]

        scheduleNotification(content: content)
        logger.info("Sent batch complete notification: \(count) files to \(destination, privacy: .public)")
    }

    /// Send a custom notification with the specified title and body
    /// - Parameters:
    ///   - title: Notification title
    ///   - body: Notification body text
    ///   - isCritical: Whether to use critical sound
    func sendCustomNotification(title: String, body: String, isCritical: Bool = false) {
        guard notificationsEnabled && permissionGranted else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if soundEnabled {
            if isCritical {
                if #available(macOS 12.0, *) {
                    content.sound = .defaultCritical
                } else {
                    content.sound = .default
                }
            } else {
                content.sound = .default
            }
        }

        scheduleNotification(content: content)
    }

    /// Schedule a notification for immediate delivery
    private func scheduleNotification(content: UNMutableNotificationContent) {
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // nil trigger = immediate delivery
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                self?.logger.error("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Dock Badge Progress

    /// Update the Dock icon badge to show transfer progress
    /// - Parameter progress: Progress value from 0.0 to 1.0
    func updateDockProgress(_ progress: Double) {
        guard dockProgressEnabled else { return }

        DispatchQueue.main.async {
            if progress >= 1.0 || progress <= 0.0 {
                // Clear progress when complete or not started
                NSApp.dockTile.badgeLabel = nil
                NSApp.dockTile.contentView = nil
            } else {
                // Show percentage as badge
                let percent = Int(progress * 100)
                NSApp.dockTile.badgeLabel = "\(percent)%"
            }
            NSApp.dockTile.display()
        }
    }

    /// Update Dock badge with current file count
    /// - Parameters:
    ///   - current: Current file number being transferred
    ///   - total: Total number of files
    func updateDockFileProgress(current: Int, total: Int) {
        guard dockProgressEnabled else { return }

        DispatchQueue.main.async {
            if current >= total || current <= 0 {
                NSApp.dockTile.badgeLabel = nil
            } else {
                NSApp.dockTile.badgeLabel = "\(current)/\(total)"
            }
            NSApp.dockTile.display()
        }
    }

    /// Clear the Dock icon badge
    func clearDockProgress() {
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = nil
            NSApp.dockTile.contentView = nil
            NSApp.dockTile.display()
        }
    }

    // MARK: - Testing

    /// Send a test notification to verify settings
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "CloudSync Ultra"
        content.body = "Notifications are working correctly!"
        content.sound = soundEnabled ? .default : nil

        let request = UNNotificationRequest(
            identifier: "test-notification-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                self?.logger.error("Test notification failed: \(error.localizedDescription)")
            } else {
                self?.logger.info("Test notification sent successfully")
            }
        }
    }

    // MARK: - Cleanup

    /// Remove all pending notifications
    func clearPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        logger.debug("Cleared all pending notifications")
    }

    /// Remove all delivered notifications from Notification Center
    func clearDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        logger.debug("Cleared all delivered notifications")
    }
}

// MARK: - Notification Names Extension

extension Notification.Name {
    /// Posted when a transfer completes successfully
    static let transferDidComplete = Notification.Name("CloudSyncTransferDidComplete")

    /// Posted when a transfer fails
    static let transferDidFail = Notification.Name("CloudSyncTransferDidFail")

    /// Posted when notification settings change
    static let notificationSettingsChanged = Notification.Name("CloudSyncNotificationSettingsChanged")
}
