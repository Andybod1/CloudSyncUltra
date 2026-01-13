# Task: Dev-2 - Bandwidth Throttling Engine (#1)

> **Worker:** Dev-2 (Core Engine)
> **Model:** Sonnet (S-sized portion)
> **Sprint:** Quick Wins + Polish
> **Ticket:** #1 (Engine portion)

---

## Objective

Fix the bandwidth throttling implementation in RcloneManager to properly limit upload and download speeds.

---

## Current State

The app already has basic bandwidth code in `RcloneManager.swift` but it has issues:
1. Uses wrong rclone format (should be "upload:download")
2. Only adds one --bwlimit flag instead of using the proper combined format
3. Not applied consistently to all transfer methods

---

## File to Modify
`/Users/antti/Claude/CloudSyncApp/RcloneManager.swift`

---

## Task 1: Fix getBandwidthArgs()

Find the `getBandwidthArgs()` function (around line 49-73):

**CURRENT CODE (incorrect):**
```swift
private func getBandwidthArgs() -> [String] {
    var args: [String] = []
    
    if UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled") {
        let uploadLimit = UserDefaults.standard.double(forKey: "uploadLimit")
        let downloadLimit = UserDefaults.standard.double(forKey: "downloadLimit")
        
        if uploadLimit > 0 {
            args.append("--bwlimit")
            args.append("\(uploadLimit)M")
        }
        
        if downloadLimit > 0 && (uploadLimit == 0 || downloadLimit < uploadLimit) {
            args.append("--bwlimit")
            args.append("\(downloadLimit)M")
        }
    }
    
    return args
}
```

**REPLACE WITH:**
```swift
/// Get bandwidth limit arguments for rclone
/// Format: --bwlimit UPLOAD:DOWNLOAD where each can be "off" or "NM" for N megabytes/s
private func getBandwidthArgs() -> [String] {
    guard UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled") else {
        return []
    }
    
    let uploadLimit = UserDefaults.standard.double(forKey: "uploadLimit")
    let downloadLimit = UserDefaults.standard.double(forKey: "downloadLimit")
    
    // If both are 0 (unlimited), no need to add any args
    if uploadLimit <= 0 && downloadLimit <= 0 {
        return []
    }
    
    // rclone format: --bwlimit "UPLOAD:DOWNLOAD"
    // Use "off" for unlimited, or "NM" for N megabytes/sec
    let uploadStr = uploadLimit > 0 ? "\(Int(uploadLimit))M" : "off"
    let downloadStr = downloadLimit > 0 ? "\(Int(downloadLimit))M" : "off"
    
    return ["--bwlimit", "\(uploadStr):\(downloadStr)"]
}
```

---

## Task 2: Verify getBandwidthArgs() is Called in All Transfer Methods

Check that `getBandwidthArgs()` is added to args in these methods:
1. `copyFiles()` - around line 1340 ✅ (already there)
2. `syncFiles()` - find and verify
3. Any other file transfer methods

Search for methods that build rclone args with "copy" or "sync" commands and ensure they include:
```swift
args.append(contentsOf: self.getBandwidthArgs())
```

---

## Task 3: Add Bandwidth Args to Sync Methods

Find any sync methods that don't have bandwidth args. Example pattern to look for:

```swift
func syncFiles(...) {
    var args = [
        "sync",
        source,
        dest,
        "--config", self.configPath,
        // ... other args
    ]
    
    // ADD THIS if missing:
    args.append(contentsOf: self.getBandwidthArgs())
    
    // ...
}
```

---

## Verification

After making changes:
1. Build the app
2. Enable bandwidth limit in Settings (once Dev-1 adds UI)
3. Set upload/download to 5 MB/s
4. Start a transfer
5. Verify speed is limited (check Activity Monitor or transfer progress)

**Quick test command:**
```bash
# Test the rclone bwlimit format manually:
/opt/homebrew/bin/rclone copy test.txt google:test/ --bwlimit "5M:5M" --progress
```

---

## Completion Checklist

- [ ] getBandwidthArgs() uses correct "UPLOAD:DOWNLOAD" format
- [ ] Returns empty array when disabled or both limits are 0
- [ ] All transfer methods include getBandwidthArgs()
- [ ] Build succeeds

---

## Output

When complete, create a summary file:
```
/Users/antti/Claude/.claude-team/outputs/DEV2_COMPLETE.md
```

Include:
- Lines changed in getBandwidthArgs()
- Methods updated with bandwidth args
- Build status

---

*Task assigned by Strategic Partner*
