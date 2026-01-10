import SwiftUI
import AppKit

@main
struct CloudSyncApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var syncManager = SyncManager.shared
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(syncManager)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon for menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "CloudSync")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView())
        self.popover = popover
        
        // Start sync manager
        SyncManager.shared.startMonitoring()
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        SyncManager.shared.stopMonitoring()
    }
}
