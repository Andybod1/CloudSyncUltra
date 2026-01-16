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
    @StateObject private var storeKitManager = StoreKitManager.shared
    
    var body: some Scene {
        // Main Window
        WindowGroup {
            MainWindow()
                .environmentObject(syncManager)
                .environmentObject(remotesVM)
                .environmentObject(tasksVM)
                .environmentObject(errorManager)
                .environmentObject(storeKitManager)
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

            CommandGroup(after: .newItem) {
                Divider()
                Button("Quick Actions...") {
                    NotificationCenter.default.post(name: .showQuickActions, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }

            CommandGroup(after: .sidebar) {
                Divider()
                Button("Dashboard") {
                    NotificationCenter.default.post(name: NSNotification.Name("OpenDashboard"), object: nil)
                }
                .keyboardShortcut("1", modifiers: .command)

                Button("Transfer") {
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToTransfer"), object: nil)
                }
                .keyboardShortcut("2", modifiers: .command)

                Button("Schedules") {
                    NotificationCenter.default.post(name: NSNotification.Name("OpenScheduleSettings"), object: nil)
                }
                .keyboardShortcut("3", modifiers: .command)
            }

            // Help menu - Send Feedback (Issue #97)
            CommandGroup(replacing: .help) {
                Button("Send Feedback...") {
                    NotificationCenter.default.post(name: .showFeedback, object: nil)
                }
                .keyboardShortcut("?", modifiers: [.command, .shift])

                Divider()

                Button("CloudSync Ultra Help") {
                    if let url = URL(string: "https://github.com/Andybod1/CloudSyncUltra/wiki") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        
        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(syncManager)
                .environmentObject(remotesVM)
                .environmentObject(storeKitManager)
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var mainWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup crash reporting
        CrashReportingManager.shared.setup()

        // Setup menu bar
        statusBarController = StatusBarController()
        statusBarController?.setupMenuBar()

        // Request notification permissions on first launch
        Task { @MainActor in
            await NotificationManager.shared.requestPermission()
        }

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
        // Clear dock badge on app termination
        NotificationManager.shared.clearDockProgress()
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
    static let showQuickActions = Notification.Name("showQuickActions")
    static let showFeedback = Notification.Name("showFeedback")
}
