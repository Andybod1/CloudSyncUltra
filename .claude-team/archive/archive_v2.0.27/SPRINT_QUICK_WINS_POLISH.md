# Sprint: Quick Wins + Polish

> **Sprint Start:** 2026-01-13
> **Sprint Goal:** UI polish and feature enhancements
> **Estimated Duration:** 2-3 hours with parallel workers

---

## Sprint Overview

This sprint focuses on three tickets:
1. **#14** - Drag & drop cloud service reordering [Medium, S]
2. **#25** - Account name in encryption view [Low, S]
3. **#1** - Bandwidth throttling controls [Medium, L]

---

## Ticket #14: Drag & Drop Cloud Service Reordering

### Problem
Users cannot reorder cloud services in the sidebar. The order is determined by when services were added, not user preference.

### Solution
Add SwiftUI drag-and-drop to the sidebar's ForEach for cloud remotes.

### Technical Approach

**Files to Modify:**
- `CloudSyncApp/Views/MainWindow.swift` - Add `.onMove` modifier to sidebar
- `CloudSyncApp/ViewModels/RemotesViewModel.swift` - Add `moveRemote(from:to:)` method
- `CloudSyncApp/Models/CloudProvider.swift` - Add `sortOrder` property to CloudRemote

**Implementation:**
```swift
// In SidebarView, modify the ForEach for cloud remotes:
ForEach(remotes.filter { $0.type != .local }) { remote in
    remoteSidebarItem(remote)
        .contextMenu { ... }
}
.onMove(perform: moveRemotes)

private func moveRemotes(from source: IndexSet, to destination: Int) {
    RemotesViewModel.shared.moveRemotes(from: source, to: destination)
}

// In RemotesViewModel:
func moveRemotes(from source: IndexSet, to destination: Int) {
    var cloudRemotes = remotes.filter { $0.type != .local }
    cloudRemotes.move(fromOffsets: source, toOffset: destination)
    
    // Update sort order
    for (index, var remote) in cloudRemotes.enumerated() {
        remote.sortOrder = index
        // Update in main array
    }
    saveRemotes()
}

// In CloudRemote model:
var sortOrder: Int = 0
```

### Worker Assignment
- **Dev-1** (UI): Implement drag & drop in SidebarView
- **Dev-3** (Services): Add sortOrder to CloudRemote model and RemotesViewModel logic

### Size Estimate: S (30 min - 1 hour)

### Test Cases
1. Drag Google Drive below Dropbox → order persists after app restart
2. Drag service to first position → becomes first in sidebar
3. Add new service → appears at end of list
4. Remove service → others maintain relative order

---

## Ticket #25: Account Name in Encryption View

### Problem
In the encryption settings view, cloud services show only the service name (e.g., "Google Drive") but not which account is connected (e.g., "user@gmail.com").

### Solution
Display the connected account username/email below the service name in the encryption view.

### Technical Approach

**Challenge:** rclone doesn't store account email directly. We have options:
1. Parse OAuth token for email (unreliable, varies by provider)
2. Store username during OAuth setup flow
3. Use `rclone config show` and extract any user-related fields

**Recommended Approach:** Store username during OAuth connection and save to CloudRemote model.

**Files to Modify:**
- `CloudSyncApp/Models/CloudProvider.swift` - Add `accountName: String?` to CloudRemote
- `CloudSyncApp/SettingsView.swift` - Display accountName in `remoteEncryptionRow()`
- `CloudSyncApp/Components/ConnectRemoteSheet.swift` - Capture account name during OAuth

**Implementation:**
```swift
// In CloudRemote model:
var accountName: String?  // e.g., "user@gmail.com" or "john_doe"

// In remoteEncryptionRow() in SettingsView.swift:
VStack(alignment: .leading, spacing: 4) {
    Text(remote.name)
        .fontWeight(.semibold)
    
    if let accountName = remote.accountName, !accountName.isEmpty {
        Text(accountName)
            .font(.caption)
            .foregroundColor(.blue)
    }
    
    if isConfigured {
        // existing encryption status...
    }
}

// During OAuth completion, try to extract email from token or prompt user
```

**Account Name Sources by Provider:**
- Google Drive/Photos: Extract from OAuth response or userinfo endpoint
- Dropbox: Available in token response
- OneDrive: Available in token response
- pCloud: Store username from login
- Proton Drive: Store username from login

### Worker Assignment
- **Dev-1** (UI): Display accountName in EncryptionSettingsView
- **Dev-3** (Services): Add accountName field, implement extraction logic

### Size Estimate: S (30 min - 1 hour)

### Test Cases
1. Connect Google Drive → shows email below service name
2. Connect Proton Drive → shows username
3. Service without accountName → shows only service name (graceful fallback)
4. Account name persists after app restart

---

## Ticket #1: Bandwidth Throttling Controls

### Problem
Users cannot control upload/download speeds. The app uses full bandwidth which can:
- Saturate network connections
- Interfere with other applications
- Cause provider rate limiting

### Solution
Add UI controls for bandwidth limits with per-direction throttling.

### Current State
Basic bandwidth code exists in `RcloneManager.swift` (lines 49-73) using UserDefaults:
- `bandwidthLimitEnabled` (Bool)
- `uploadLimit` (Double, MB/s)
- `downloadLimit` (Double, MB/s)

But there's no UI to control these settings!

### Technical Approach

**Files to Modify:**
- `CloudSyncApp/SettingsView.swift` - Add Bandwidth section to SettingsView
- `CloudSyncApp/RcloneManager.swift` - Fix getBandwidthArgs() to handle up/down separately
- `CloudSyncApp/Views/TransferView.swift` - Show current bandwidth limit in transfer UI

**Implementation:**
```swift
// New section in SettingsView:
Section("Bandwidth") {
    Toggle("Limit bandwidth", isOn: $bandwidthEnabled)
    
    if bandwidthEnabled {
        HStack {
            Text("Upload limit:")
            TextField("MB/s", value: $uploadLimit, format: .number)
                .frame(width: 80)
            Text("MB/s")
        }
        
        HStack {
            Text("Download limit:")
            TextField("MB/s", value: $downloadLimit, format: .number)
                .frame(width: 80)
            Text("MB/s")
        }
        
        // Preset buttons
        HStack {
            ForEach([1, 5, 10, 50, 0], id: \.self) { speed in
                Button(speed == 0 ? "∞" : "\(speed)") {
                    uploadLimit = Double(speed)
                    downloadLimit = Double(speed)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// Fix RcloneManager.getBandwidthArgs():
private func getBandwidthArgs() -> [String] {
    guard UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled") else {
        return []
    }
    
    let upload = UserDefaults.standard.double(forKey: "uploadLimit")
    let download = UserDefaults.standard.double(forKey: "downloadLimit")
    
    var args: [String] = []
    
    // rclone uses --bwlimit with format "upload:download"
    if upload > 0 || download > 0 {
        let uploadStr = upload > 0 ? "\(Int(upload))M" : "off"
        let downloadStr = download > 0 ? "\(Int(download))M" : "off"
        args.append("--bwlimit")
        args.append("\(uploadStr):\(downloadStr)")
    }
    
    return args
}
```

### Worker Assignment
- **Dev-1** (UI): Create BandwidthSettingsSection in SettingsView
- **Dev-2** (Engine): Fix getBandwidthArgs() for proper rclone format, add to all transfer methods

### Size Estimate: L (2-4 hours)

### Test Cases
1. Enable bandwidth limit at 5 MB/s → transfer speed limited
2. Set different upload/download limits → both applied correctly
3. Disable bandwidth limit → full speed transfers
4. Settings persist after app restart
5. Show current limit in transfer progress (optional enhancement)

---

## Sprint Execution Plan

### Phase 1: Model Updates (15 min)
**Dev-3:** Add `sortOrder` and `accountName` to CloudRemote model
- Modify CloudProvider.swift
- Update Codable conformance
- Bump storage version key

### Phase 2: Parallel Implementation (1-1.5 hours)

| Worker | Task | Duration |
|--------|------|----------|
| Dev-1 | Drag & drop in sidebar (#14 UI) | 30 min |
| Dev-1 | Account name display (#25 UI) | 20 min |
| Dev-1 | Bandwidth settings UI (#1 UI) | 40 min |
| Dev-2 | Fix getBandwidthArgs() (#1 Engine) | 30 min |
| Dev-3 | RemotesViewModel.moveRemotes() (#14) | 20 min |
| Dev-3 | Account name extraction logic (#25) | 30 min |

### Phase 3: Integration & Testing (30 min)
**QA:** Test all three features
- Write unit tests for new functionality
- Manual verification checklist

### Phase 4: Documentation (15 min)
**Strategic Partner:**
- Update CHANGELOG
- Commit all changes
- Push to GitHub

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Drag & drop conflicts with context menu | Use onMove modifier which handles both |
| Account name not available for all providers | Graceful fallback to showing nothing |
| Bandwidth args format wrong | Test with actual transfers |

---

## Success Criteria

- [ ] Cloud services can be reordered via drag & drop
- [ ] Order persists after app restart
- [ ] Account names display in encryption view (where available)
- [ ] Bandwidth limits can be set in Settings
- [ ] Bandwidth limits are applied to transfers
- [ ] All existing tests pass
- [ ] New tests for each feature

---

*Sprint planned by Strategic Partner*
*Ready for worker assignment*
