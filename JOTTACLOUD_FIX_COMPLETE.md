# Jottacloud Integration Fix - Complete

## Summary

Fixed Jottacloud authentication to use the correct **Personal Login Token** authentication method instead of the incorrect username/password approach.

**Date:** January 12, 2026
**Status:** ✅ Fixed

---

## The Problem (Was)

The previous implementation tried to use username/password authentication:

```swift
// OLD (Wrong)
func setupJottacloud(remoteName: String, username: String?, password: String?, device: String?) async throws {
    var params = ["user": username, "pass": password]  // ❌ Doesn't work!
    try await createRemote(name: remoteName, type: "jottacloud", parameters: params)
}
```

This failed because Jottacloud's **standard authentication** requires:
1. A **Personal Login Token** (not password)
2. Multi-step OAuth state machine
3. Token exchange via rclone's config system

---

## The Solution (Now)

Implemented proper multi-step authentication flow:

```swift
// NEW (Correct)
func setupJottacloud(remoteName: String, personalLoginToken: String, useDefaultDevice: Bool = true) async throws {
    // Step 1: Create config, get auth_type_done state
    // Step 2: Select "standard" authentication
    // Step 3: Provide personal login token → rclone exchanges for OAuth token
    // Step 4: Accept default device/mountpoint (Jotta/Archive)
}
```

### Key Changes

1. **RcloneManager.swift**
   - Replaced simple `createRemote()` with multi-step state machine
   - Uses `config create` for first step, `config update --continue` for subsequent steps
   - Properly handles `--non-interactive` JSON responses
   - Parses state/result from rclone's responses

2. **MainWindow.swift** (already correct)
   - Single "Personal Login Token" field (no username)
   - Link to token generator at jottacloud.com/web/secure
   - Clear instructions for users

3. **CloudProvider.swift**
   - Updated experimental note to be informative rather than warning

---

## How It Works

### Authentication Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  User visits    │ -> │ User generates  │ -> │ User pastes     │
│  jottacloud.com │    │ login token     │    │ token in app    │
│  /web/secure    │    │ (single-use)    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                      │
                                                      ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  App stores     │ <- │ rclone gets     │ <- │ rclone sends    │
│  OAuth token    │    │ OAuth token     │    │ token to Jotta  │
│  in config      │    │ from Jottacloud │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### State Machine Steps

| Step | State | Result | Action |
|------|-------|--------|--------|
| 1 | (empty) | - | `config create jottacloud --non-interactive` |
| 2 | auth_type_done | "standard" | `config update --continue` |
| 3 | standard_token | <token> | Exchange token for OAuth |
| 4 | choose_device* | "false" | Use default device (Jotta/Archive) |

*May vary based on account configuration

---

## User Experience

### Before (Confusing)
- Two fields: Username + Password
- Error: "outdated config - please reconfigure"
- Marked as "EXPERIMENTAL" with warning

### After (Clear)
- One field: Personal Login Token
- Link: "Open Jottacloud Security Settings →"
- Instructions for generating token
- Still marked experimental but with helpful note

---

## Files Modified

```
CloudSyncApp/
├── RcloneManager.swift          [Major update - new state machine]
├── Models/CloudProvider.swift   [Updated experimental note]
└── Views/MainWindow.swift       [Already correct - token-only UI]
```

---

## Testing

### Build Status
```
✅ BUILD SUCCEEDED
```

### Manual Test Steps
1. Add Jottacloud provider
2. Click "Open Jottacloud Security Settings"
3. Generate Personal Login Token at jottacloud.com
4. Paste token and click Connect
5. Verify files appear

### Edge Cases Handled
- Invalid/expired token → Clear error message
- Already configured remote → Clean reconfigure
- Multiple config steps → Loop with safety limit

---

## Technical Details

### rclone State Machine

The Jottacloud backend uses a complex state machine:

```json
// Step 1 response
{
  "State": "auth_type_done",
  "Option": { "Name": "config_type", ... }
}

// Step 2 response  
{
  "State": "standard_token",
  "Option": { "Name": "config_login_token", ... }
}

// Step 3 response (after token exchange)
{
  "State": "choose_device",  // or empty if using defaults
  ...
}
```

### Token Format
- Length: ~250+ characters
- Contains: Base64-encoded JSON with endpoints
- Single-use: Must generate new one for each auth

### Refresh Token Rotation
- Jottacloud uses aggressive token rotation
- Each refresh invalidates previous token
- Sharing config between machines causes "stale token" errors
- Solution: Generate separate token per machine

---

## Known Limitations

1. **Single Machine Per Token**
   - Each rclone config should use its own token
   - Copying config to another machine will eventually fail

2. **White-Label Services**
   - Telia Cloud, Tele2 Cloud, etc. need browser OAuth
   - Not currently supported in CloudSync Ultra

3. **Device Selection**
   - Currently uses default Jotta/Archive
   - Advanced users may want Sync or custom devices

---

## Future Improvements

- [ ] Add browser OAuth flow for white-label services
- [ ] Add device/mountpoint selection UI
- [ ] Add reconnect button for stale tokens
- [ ] Consider removing experimental flag after user testing

---

## References

- [rclone Jottacloud Documentation](https://rclone.org/jottacloud/)
- [Jottacloud Security Settings](https://www.jottacloud.com/web/secure)
- [rclone GitHub - jottacloud.go](https://github.com/rclone/rclone/blob/master/backend/jottacloud/jottacloud.go)

---

*Fix completed: January 12, 2026*
*Build status: ✅ Successful*
*Ready for testing with real Jottacloud account*
