//
//  CloudSyncAppApp.swift
//  CloudSyncApp
//
//  Main app entry point with menu bar and main window support
//

import SwiftUI

@main
struct CloudSyncAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var syncManager = SyncManager.shared
    @StateObject private var remotesVM = RemotesViewModel.shared
    @StateObject private var tasksVM = TasksViewModel.shared
    @StateObject private var errorManager = ErrorNotificationManager()
    
    var body: some Scene {
        // Main Window
        WindowGroup {
            MainWindow()
                .environmentObject(syncManager)
                .environmentObject(remotesVM)
                .environmentObject(tasksVM)
                .environmentObject(errorManager)
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Task...") {
                    NotificationCenter.default.post(name: .showNewTask, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(after: .sidebar) {
                Button("Refresh") {
                    NotificationCenter.default.post(name: .refreshContent, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        
        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(syncManager)
                .environmentObject(remotesVM)
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var mainWindowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup menu bar
        statusBarController = StatusBarController()
        statusBarController?.setupMenuBar()
        
        // Start monitoring if configured
        if UserDefaults.standard.bool(forKey: "isConfigured") {
            Task { @MainActor in
                await SyncManager.shared.startMonitoring()
            }
        }

        // Start the schedule manager
        Task { @MainActor in
            ScheduleManager.shared.startScheduler()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        SyncManager.shared.stopMonitoring()
        ScheduleManager.shared.stopScheduler()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running in menu bar even when windows are closed
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Reopen main window when clicking dock icon
        if !flag {
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showNewTask = Notification.Name("showNewTask")
    static let refreshContent = Notification.Name("refreshContent")
    static let syncStatusChanged = Notification.Name("SyncStatusChanged")
}
