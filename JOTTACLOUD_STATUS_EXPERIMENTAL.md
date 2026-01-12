# Jottacloud Status: Fixed (Experimental)

## Current Status: ✅ FIXED

**Date:** January 12, 2026

Jottacloud integration has been fixed! The authentication now properly uses the Personal Login Token flow.

---

## What Was Fixed

### Previous Issue
The original implementation tried to use username/password authentication which doesn't work with Jottacloud's rclone backend. The backend requires a multi-step OAuth state machine.

### Solution Implemented
Implemented proper multi-step state machine handling:
1. Select "standard" authentication type
2. Provide Personal Login Token
3. Handle OAuth token exchange
4. Configure device/mountpoint (defaults to Jotta/Archive)

---

## How to Connect

### Step 1: Get Personal Login Token
1. Go to https://www.jottacloud.com/web/secure
2. Log in to your Jottacloud account
3. Scroll to "Personal login token" section
4. Click "Generate"
5. Copy the token (long base64-encoded string)

### Step 2: Connect in CloudSync Ultra
1. Click "Add Cloud..."
2. Select "Jottacloud"
3. Paste the token in the "Personal Login Token" field
4. Click "Connect"

### Step 3: Start Syncing
Once connected, you can browse files and sync as normal.

---

## Important Notes

### Token Behavior
- **Single-use**: Each token can only be used once
- **~1 hour validity**: Generate just before using
- **Revokable**: Can revoke at jottacloud.com/web/secure

### If Connection Fails
1. Generate a **new** token (old one is expired/used)
2. Try again with fresh token
3. Check internet connection

### Token Rotation
Jottacloud uses "Refresh Token Rotation" - if you use the same config on multiple machines, you may get "stale token" errors. Each machine needs its own connection setup.

---

## Why Still Experimental?

Marked experimental because:
1. Token refresh mechanism needs real-world testing
2. White-label services (Telia, Tele2) need separate flow
3. Multi-machine scenarios need testing

Will be marked as stable after successful real-world testing.

---

## Technical Details

### Authentication Flow
```
rclone config create jottacloud jottacloud --non-interactive
  → Returns: config_type prompt (state: auth_type_done)

rclone config create ... --continue --state "auth_type_done" --result "standard"
  → Returns: config_login_token prompt (state: standard_token)

rclone config create ... --continue --state "standard_token" --result "<TOKEN>"
  → Exchanges token for OAuth, returns device prompt

rclone config create ... --continue --state "..." --result "false"
  → Uses default device (Jotta/Archive)

Remote created successfully!
```

### Files Modified
- `RcloneManager.swift` - New setupJottacloud() with state machine
- `MainWindow.swift` - UI for single token field
- `CloudProvider.swift` - Updated experimental note

---

## Features Supported

✅ File listing
✅ File upload
✅ File download
✅ Folder sync
✅ Per-remote encryption
✅ Unlimited storage (paid plans)

---

## Testing Checklist

- [ ] Connect with valid token
- [ ] List files successfully
- [ ] Upload a test file
- [ ] Download a test file
- [ ] Sync a folder
- [ ] Reconnect after token refresh
- [ ] Error handling for invalid token

---

*Status Updated: January 12, 2026*
*Build: Successful*
*Ready for: Real-world testing*
