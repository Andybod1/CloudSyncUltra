# Jottacloud Integration Fix - Complete

## Summary

Fixed Jottacloud authentication to use the correct **Personal Login Token** authentication method with proper state machine handling.

**Date:** January 12, 2026  
**Status:** ✅ Fixed and Tested

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
   - Uses `config create` with `isFirstStep: true` for first step
   - Uses `config create --continue` for subsequent steps
   - Safe JSON parsing for state/result extraction
   - Properly handles `--non-interactive` JSON responses

2. **MainWindow.swift** (already correct)
   - Single "Personal Login Token" field (no username)
   - Link to token generator at jottacloud.com/web/secure
   - Clear instructions for users

3. **CloudProvider.swift**
   - Updated experimental note to be informative

---

## Critical Bug Fixes

### Fix 1: Missing `isFirstStep: true` (Jan 12, 2026)

**Problem:** Step 1 wasn't using `isFirstStep: true`, causing rclone to try `config create --continue` instead of starting fresh.

**Error:** "couldn't find type field in config"

**Solution:**
```swift
let step1Result = try await runJottacloudConfigStep(
    remoteName: remoteName,
    state: "",
    result: "",
    isFirstStep: true  // ← Was missing!
)
```

### Fix 2: Unsafe String Range Parsing (Jan 12, 2026)

**Problem:** The `parseConfigState()` function used unsafe regex with string index manipulation, causing crash.

**Error:** "Range requires lowerBound <= upperBound" (SIGTRAP crash)

**Solution:** Rewrote parsing to use safe JSON decoding with string fallback:
```swift
private func parseConfigState(from output: String) -> String? {
    // Try JSON parsing first (reliable)
    if let data = output.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let state = json["State"] as? String {
        return state
    }
    
    // Fallback: Safe string search
    let patterns = ["\"State\": \"", "\"State\":\""]
    for pattern in patterns {
        if let startRange = output.range(of: pattern) {
            let afterPattern = output[startRange.upperBound...]
            if let endQuote = afterPattern.firstIndex(of: "\"") {
                return String(afterPattern[..<endQuote])
            }
        }
    }
    return nil
}
```

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

| Step | Command | State In | Result | State Out |
|------|---------|----------|--------|-----------|
| 1 | `config create jottacloud --non-interactive` | - | - | auth_type_done |
| 2 | `config create --continue --state X --result "standard"` | auth_type_done | "standard" | standard_token |
| 3 | `config create --continue --state X --result <token>` | standard_token | <token> | choose_device |
| 4 | `config create --continue --state X --result "false"` | choose_device | "false" | (empty = done) |

---

## User Experience

### Before (Confusing)
- Two fields: Username + Password
- Error: "outdated config - please reconfigure"
- Marked as "EXPERIMENTAL" with warning

### After (Clear)
- Single field: "Personal Login Token"
- Link to token generator page
- Step-by-step instructions
- Helpful error messages

---

## Testing

### Manual Test Procedure
1. Open CloudSync Ultra
2. Click "Add Cloud..." → Select Jottacloud
3. Click "Open Jottacloud Security Settings" link
4. At jottacloud.com: Settings → Security → Personal login token → Generate
5. Copy the token (~250 characters)
6. Paste into the Password field in CloudSync Ultra
7. Click "Connect"
8. ✅ Files should appear in the file browser

### Unit Tests
- `JottacloudProviderTests.swift` - Provider properties
- `JottacloudAuthenticationTests.swift` - State machine logic

### Build Status
```
✅ BUILD SUCCEEDED
✅ Zero warnings  
✅ Zero crashes
✅ Authentication working
```

---

## Known Limitations

1. **Single Token Per Machine**
   - Jottacloud uses refresh token rotation
   - Each rclone config needs its own token
   - Don't copy configs between machines

2. **White-Label Services**
   - Telia Cloud, Tele2 Cloud, Onlime need browser OAuth
   - Not implemented (uses standard auth only)

3. **Device Selection**
   - Uses default Jotta/Archive device
   - Advanced users may want Sync or custom devices

---

## Files Changed

| File | Changes |
|------|---------|
| `RcloneManager.swift` | New `setupJottacloud()` with state machine, safe JSON parsing |
| `CloudProvider.swift` | Updated experimental note |
| `MainWindow.swift` | Already had correct UI |

---

## References

- rclone docs: https://rclone.org/jottacloud/
- Token generator: https://www.jottacloud.com/web/secure
- rclone source: github.com/rclone/rclone/blob/master/backend/jottacloud/jottacloud.go

---

## Commits

```
b69ce5e Fix Jottacloud authentication with proper Personal Login Token flow
XXXXXXX Fix isFirstStep parameter and safe JSON parsing (crash fix)
```
