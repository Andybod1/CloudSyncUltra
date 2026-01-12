# Jottacloud Integration Fix Complete

## Date: January 12, 2026

## Summary

Fixed Jottacloud authentication to work properly with rclone's Personal Login Token system instead of the broken username/password approach.

---

## Root Cause

The original implementation tried to use `user` and `pass` parameters with rclone, but Jottacloud's rclone backend uses a **multi-step state machine** that requires:

1. Selecting authentication type ("standard" for jottacloud.com users)
2. Providing a **Personal Login Token** (generated at jottacloud.com/web/secure)
3. Exchanging the token for an OAuth token internally
4. Selecting device/mountpoint (defaults to Jotta/Archive)

The old approach simply couldn't work because Jottacloud doesn't accept username/password credentials directly.

---

## Changes Made

### 1. RcloneManager.swift

**Before (Broken):**
```swift
func setupJottacloud(remoteName: String, username: String?, password: String?, device: String?) async throws {
    var params: [String: String] = [
        "user": username,
        "pass": password  // Wrong! This doesn't work
    ]
    try await createRemote(name: remoteName, type: "jottacloud", parameters: params)
}
```

**After (Fixed):**
```swift
func setupJottacloud(remoteName: String, personalLoginToken: String, useDefaultDevice: Bool = true) async throws {
    // Multi-step state machine:
    // Step 1: Select "standard" auth type
    // Step 2: Provide personal login token
    // Step 3: Handle device/mountpoint selection
    // Uses --non-interactive and --continue flags to manage state
}
```

**New helper methods added:**
- `runJottacloudConfigStep()` - Runs a single step of the config state machine
- `parseConfigState()` - Parses the State field from rclone's JSON response
- `parseConfigError()` - Extracts error messages from rclone output

### 2. MainWindow.swift (UI)

**Form Section:**
- Username field hidden for Jottacloud (not needed)
- Password field renamed to "Personal Login Token"
- Section header changed to "Authentication Token"

**Credentials Help:**
- Added step-by-step instructions
- Added clickable link to jottacloud.com/web/secure
- Clear explanation that token != password

**Connect Logic:**
- `canConnect` updated to only require token (no username) for Jottacloud
- `configureRemote()` calls new `setupJottacloud(remoteName:personalLoginToken:)`

---

## How It Works Now

### User Flow:
1. User clicks "Add Cloud..." and selects Jottacloud
2. UI shows single "Personal Login Token" field with instructions
3. User clicks link to open jottacloud.com/web/secure
4. User generates token on website
5. User pastes token into CloudSync Ultra
6. App runs multi-step rclone config:
   - `rclone config create jottacloud jottacloud --non-interactive`
   - Responds with `--continue --state "auth_type_done" --result "standard"`
   - Responds with `--continue --state "standard_token" --result "<token>"`
   - Handles device/mountpoint prompts with defaults
7. Connection established ✅

### Technical Flow:
```
┌─────────────────────┐
│ User pastes token   │
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ Step 1: auth_type   │──► Returns config_type prompt
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ Step 2: standard    │──► Returns token prompt
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ Step 3: token       │──► Exchanges for OAuth token
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ Step 4: device      │──► Uses defaults (Jotta/Archive)
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ Remote created ✅   │
└─────────────────────┘
```

---

## Files Modified

| File | Changes |
|------|---------|
| `RcloneManager.swift` | New `setupJottacloud()` with state machine, helper methods |
| `MainWindow.swift` | UI updates for single token field, instructions, link |

---

## Build Status

```
✅ BUILD SUCCEEDED
✅ Zero compilation errors
✅ Zero warnings
```

---

## Testing Required

### To Test Jottacloud:

1. **Get a Jottacloud account** (free trial or paid)
2. **Generate Personal Login Token:**
   - Go to https://www.jottacloud.com/web/secure
   - Scroll to "Personal login token"
   - Click "Generate"
   - Copy the token (long base64 string)
3. **In CloudSync Ultra:**
   - Click "Add Cloud..."
   - Select Jottacloud
   - Paste the token
   - Click "Connect"
4. **Verify:**
   - Files should list correctly
   - Upload/download should work

### Known Behaviors:
- Token is single-use (can't be reused)
- If auth fails, generate a new token
- Token expires after ~1 hour if not used

---

## What's Still Experimental

The `isExperimental` flag remains `true` for Jottacloud because:
1. Token refresh rotation can cause issues with multiple machines
2. White-label services (Telia, Tele2, etc.) need separate OAuth flow
3. Real-world testing with actual Jottacloud account needed

Once tested successfully, `isExperimental` can be set to `false`.

---

## Error Messages

### Clear Error Handling:

| Scenario | Error Message |
|----------|---------------|
| Invalid token | "Invalid or expired personal login token. Please generate a new token at jottacloud.com/web/secure" |
| Token not provided | "Jottacloud requires a personal login token" |
| Network error | Standard network error messages |
| Config creation failed | "Jottacloud remote was not created. Token may be invalid or expired." |

---

## Summary

**Before:** ❌ Jottacloud didn't work - wrong auth method  
**After:** ✅ Proper Personal Login Token flow with state machine handling

The fix correctly implements rclone's multi-step Jottacloud configuration process, matching how `rclone config` works interactively but doing it programmatically through the `--non-interactive` and `--continue` flags.

---

*Fix completed: January 12, 2026*
*Build: Successful*
*Status: Ready for testing with real Jottacloud account*
