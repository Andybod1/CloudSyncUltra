//
//  StatusBarController.swift
//  CloudSyncApp
//
//  Manages the menu bar icon and menu
//

import Cocoa
import SwiftUI

@MainActor
class StatusBarController: NSObject {
    private var statusItem: NSStatusItem?
    private let syncManager = SyncManager.shared
    private var statusObserver: NSKeyValueObservation?
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateIcon(status: .idle)
            button.action = #selector(toggleMenu)
            button.target = self
        }
        
        // Observe sync status changes
        Task { @MainActor in
            for await _ in NotificationCenter.default.notifications(named: NSNotification.Name("SyncStatusChanged")) {
                updateIcon(status: syncManager.syncStatus)
            }
        }
        
        updateMenu()
    }
    
    private func updateIcon(status: SyncStatus) {
        guard let button = statusItem?.button else { return }
        
        switch status {
        case .idle:
            button.image = NSImage(systemSymbolName: "cloud", accessibilityDescription: "Idle")
        case .checking:
            button.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "Checking")
        case .syncing:
            button.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: "Syncing")
        case .completed:
            button.image = NSImage(systemSymbolName: "checkmark.circle", accessibilityDescription: "Completed")
        case .error:
            button.image = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Error")
        }
    }
    
    @objc private func toggleMenu() {
        updateMenu()
    }
    
    private func updateMenu() {
        let menu = NSMenu()
        
        // Status indicator
        let statusMenuItem: NSMenuItem
        switch syncManager.syncStatus {
        case .idle:
            statusMenuItem = NSMenuItem(title: "Idle", action: nil, keyEquivalent: "")
        case .checking:
            statusMenuItem = NSMenuItem(title: "Checking...", action: nil, keyEquivalent: "")
        case .syncing:
            if let progress = syncManager.currentProgress {
                statusMenuItem = NSMenuItem(title: "Syncing: \(Int(progress.percentage))%", action: nil, keyEquivalent: "")
            } else {
                statusMenuItem = NSMenuItem(title: "Syncing...", action: nil, keyEquivalent: "")
            }
        case .completed:
            statusMenuItem = NSMenuItem(title: "✓ Up to date", action: nil, keyEquivalent: "")
        case .error(_):
            statusMenuItem = NSMenuItem(title: "⚠️ Error", action: nil, keyEquivalent: "")
        }
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        // Last sync time
        if let lastSync = syncManager.lastSyncTime {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            let timeString = formatter.localizedString(for: lastSync, relativeTo: Date())
            let lastSyncItem = NSMenuItem(title: "Last sync: \(timeString)", action: nil, keyEquivalent: "")
            lastSyncItem.isEnabled = false
            menu.addItem(lastSyncItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Open main window
        let openItem = NSMenuItem(title: "Open CloudSync Ultra", action: #selector(openMainWindow), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Sync now
        let syncNowItem = NSMenuItem(title: "Sync Now", action: #selector(syncNow), keyEquivalent: "s")
        syncNowItem.target = self
        syncNowItem.isEnabled = syncManager.syncStatus != .syncing
        menu.addItem(syncNowItem)
        
        // Pause/Resume
        if syncManager.isMonitoring {
            let pauseItem = NSMenuItem(title: "Pause Sync", action: #selector(pauseSync), keyEquivalent: "")
            pauseItem.target = self
            menu.addItem(pauseItem)
        } else {
            let resumeItem = NSMenuItem(title: "Resume Sync", action: #selector(resumeSync), keyEquivalent: "")
            resumeItem.target = self
            menu.addItem(resumeItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Open sync folder
        if !syncManager.localPath.isEmpty {
            let openFolderItem = NSMenuItem(title: "Open Sync Folder", action: #selector(openSyncFolder), keyEquivalent: "")
            openFolderItem.target = self
            menu.addItem(openFolderItem)
        }
        
        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit CloudSync Ultra", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func syncNow() {
        Task { @MainActor in
            await syncManager.performSync()
            updateMenu()
        }
    }
    
    @objc private func openMainWindow() {
        // First, activate the app
        NSApp.activate(ignoringOtherApps: true)
        
        // Post notification to open dashboard
        NotificationCenter.default.post(name: NSNotification.Name("OpenDashboard"), object: nil)
        
        // Bring window to front with delay to ensure activation happens
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Try to find and show the main window
            if let mainWindow = NSApp.windows.first(where: { 
                $0.contentViewController != nil && 
                $0.isVisible || !$0.isVisible 
            }) {
                mainWindow.makeKeyAndOrderFront(nil)
                mainWindow.orderFrontRegardless()
            } else {
                // If no window found, try to open a new one
                NSApp.keyWindow?.makeKeyAndOrderFront(nil)
            }
            
            // Force app to front again
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc private func pauseSync() {
        Task { @MainActor in
            syncManager.stopMonitoring()
            updateMenu()
        }
    }
    
    @objc private func resumeSync() {
        Task { @MainActor in
            await syncManager.startMonitoring()
            updateMenu()
        }
    }
    
    @objc private func openSyncFolder() {
        let url = URL(fileURLWithPath: syncManager.localPath)
        NSWorkspace.shared.open(url)
    }
    
    @objc private func showSettings() {
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
        
        // Post notification to open settings
        NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
        
        // Bring main window to front
        DispatchQueue.main.async {
            for window in NSApp.windows {
                if window.contentView != nil && !window.title.isEmpty {
                    window.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                    break
                }
            }
        }
        
        updateMenu()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
