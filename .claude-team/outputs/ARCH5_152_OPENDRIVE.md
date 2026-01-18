# Integration Study #152: OpenDrive

**Architect:** Architect-5
**Date:** 2026-01-18
**Status:** Complete

---

## Executive Summary

OpenDrive is a cloud storage service offering unlimited storage for personal use. This study examines the current CloudSync Ultra implementation and identifies a **critical bug**: OpenDrive is incorrectly classified as an OAuth provider when it actually uses username/password authentication via the rclone backend.

---

## 1. Current Implementation Status in CloudSync Ultra

### Existing Code Locations

| File | Status | Notes |
|------|--------|-------|
| `CloudSyncApp/Models/CloudProvider.swift` | Implemented | Provider type, display name, icons, colors defined |
| `CloudSyncApp/RcloneManager.swift` | **BUG** | Uses `createRemoteInteractive()` - incorrectly treats as OAuth |
| `CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift` | Implemented | Calls `setupOpenDrive()` |
| `CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift` | **Incomplete** | Shows OAuth flow instead of credentials form |
| `CloudSyncApp/Styles/AppTheme+ProviderColors.swift` | Implemented | Brand color defined (#4AAB4F) |
| `CloudSyncAppTests/OAuthExpansionProvidersTests.swift` | **Incorrect** | Tests assume OAuth which is wrong |

### Provider Configuration

```swift
// From CloudProvider.swift
case opendrive = "opendrive"

displayName: "OpenDrive"
iconName: "externaldrive.fill"
brandColor: Color(hex: "4AAB4F")  // OpenDrive Green
rcloneType: "opendrive"
defaultRcloneName: "opendrive"
requiresOAuth: true  // <-- BUG: Should be false
```

---

## 2. Authentication Requirements

### rclone Backend Configuration

**Backend name:** `opendrive`

**Required parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `username` | string | OpenDrive account email |
| `password` | obscured | OpenDrive account password (must be obscured via `rclone obscure`) |

**Optional/Advanced parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| `chunk_size` | 10Mi | Chunk size for uploads (buffered in memory) |
| `access` | private | File access permissions: `private`, `public`, or `hidden` |
| `encoding` | Custom | Filename character encoding for restricted chars |

### Authentication Method

**OpenDrive uses direct username/password authentication - NOT OAuth.**

The rclone documentation explicitly states:
- Username is required
- Password is required and must be obscured via `rclone obscure`

This is fundamentally different from the current CloudSync implementation which sends users through an OAuth browser flow.

---

## 3. Storage Tiers and Limitations

### Free Plan (5GB)

| Feature | Limit |
|---------|-------|
| Storage | 5 GB |
| Max file size | 100 MB |
| Download bandwidth | 1 GB/day |
| Speed limit | 200 KB/s |
| Notes | Max 5 notes |
| Tasks | Max 10 tasks |
| Users | 1 account user |
| **Inactivity warning** | Account files deleted after 90 days of inactivity |

### Paid Plans

| Plan | Price | Storage | Features |
|------|-------|---------|----------|
| Personal Unlimited | $9.95/month | Unlimited | Zero-knowledge encryption, unlimited bandwidth, unlimited file size |
| Enterprise | Custom | Unlimited | Team features, API access, priority support |

### Security Features

- AES 256-bit encryption at rest
- TLS/SSL encryption in transit
- Zero-knowledge encrypted folder (paid plans only)

---

## 4. rclone Feature Support

### Supported Operations

| Feature | Supported | Notes |
|---------|-----------|-------|
| Read | Yes | Full support |
| Write | Yes | Full support |
| Move | Yes | Server-side moves |
| Copy | Yes | Server-side copies |
| Delete | Yes | Full support |
| List | Yes | Directory listing |
| Hash (MD5) | Yes | For sync detection |
| Modification times | Yes | 1-second accuracy |

### Known Limitations

| Limitation | Impact |
|------------|--------|
| `rclone about` not supported | Cannot determine free space |
| Case-insensitive filesystem | Cannot have `Hello.doc` and `hello.doc` |
| `rclone mount` not supported | Cannot mount as local filesystem |
| Union remote "mfs" policy | Not compatible |
| Character restrictions | Certain characters require Unicode replacement |

### Restricted Filename Characters

OpenDrive restricts these characters (auto-mapped by rclone):
- `/`, `"`, `*`, `:`, `<`, `>`, `?`, `\`, `|`
- Whitespace/control characters at filename boundaries
- Invalid UTF-8 bytes

---

## 5. Recommended Wizard Flow

### Current (Incorrect) Flow
1. Select OpenDrive provider
2. Enter email (optional)
3. OAuth browser redirect
4. Test connection

### Correct Flow (To Be Implemented)

```
Step 1: Choose Provider
  -> Select OpenDrive from provider list

Step 2: Configure Settings
  -> Show credentials form (NOT OAuth)
  -> Username field: "Email address"
  -> Password field: "Password" (SecureField)
  -> Help link: https://www.opendrive.com/login

Step 3: Test Connection
  -> Create rclone config with obscured password
  -> Test with `rclone lsd opendrive:`
  -> Verify authentication succeeded

Step 4: Success
  -> Display connected account
  -> Show storage tier if detectable
```

### Required Code Changes

1. **CloudProvider.swift** - Fix `requiresOAuth`:
```swift
var requiresOAuth: Bool {
    switch self {
    case .googleDrive, .dropbox, .oneDrive, .box, .yandexDisk,
         .googleCloudStorage, .oneDriveBusiness, .sharepoint,
         .googlePhotos, .flickr, .sugarsync,  // Remove .opendrive
         .putio, .premiumizeme, .quatrix, .filefabric, .pcloud:
        return true
    default:
        return false
    }
}
```

2. **RcloneManager.swift** - Implement proper setup:
```swift
func setupOpenDrive(remoteName: String, username: String, password: String) async throws {
    // Obscure password first
    let obscuredPassword = try await obscurePassword(password)

    let params: [String: String] = [
        "username": username,
        "password": obscuredPassword
    ]

    try await createRemote(name: remoteName, type: "opendrive", parameters: params)
}
```

3. **TestConnectionStep.swift** - Update case handling:
```swift
case .opendrive:
    try await rclone.setupOpenDrive(
        remoteName: rcloneName,
        username: username,
        password: password
    )
```

4. **ConfigureSettingsStep.swift** - Add provider-specific instructions:
```swift
case .opendrive:
    return "Enter your OpenDrive email and password."
```

---

## 6. Testing Recommendations

### Unit Tests to Update

1. `OAuthExpansionProvidersTests.swift`:
   - Rename or move OpenDrive tests to a separate file
   - Update `testOpenDriveRequiresOAuth()` to assert `false`

2. Add new integration test:
```swift
func testOpenDriveCredentialsFlow() {
    let provider = CloudProviderType.opendrive
    XCTAssertFalse(provider.requiresOAuth)
    XCTAssertEqual(provider.rcloneType, "opendrive")
}
```

### Manual Testing Checklist

- [ ] Verify credentials form appears (not OAuth)
- [ ] Test with valid OpenDrive account
- [ ] Test with invalid credentials (error handling)
- [ ] Verify password is obscured in rclone config
- [ ] Test file listing after connection
- [ ] Test upload/download operations

---

## 7. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Current OAuth flow fails | High | Users cannot connect to OpenDrive with current implementation |
| Password storage security | Medium | Use rclone's built-in obscure function |
| Account inactivity deletion | Low | Document 90-day warning for free accounts |
| Character encoding issues | Low | rclone handles automatically |

---

## 8. Implementation Priority

**Priority: HIGH**

The current implementation is fundamentally broken for OpenDrive. Users attempting to connect will encounter OAuth flow which OpenDrive does not support, resulting in connection failures.

### Recommended Sprint Tasks

1. **Fix `requiresOAuth`** - Remove `.opendrive` from OAuth list
2. **Implement `setupOpenDrive(username:password:)`** - Proper credentials flow
3. **Update wizard step handling** - Show credentials form
4. **Update tests** - Fix incorrect OAuth assumptions
5. **Add documentation** - Note free tier limitations

---

## References

- rclone OpenDrive documentation: https://rclone.org/opendrive/
- OpenDrive official site: https://www.opendrive.com/
- Cloudwards OpenDrive Review: https://www.cloudwards.net/review/opendrive/

---

## Appendix: rclone Configuration Example

```ini
[opendrive]
type = opendrive
username = user@example.com
password = OBSCURED_PASSWORD_HERE
```

Interactive setup command:
```bash
rclone config create opendrive opendrive username=user@example.com password=$(rclone obscure "mypassword")
```

Test connection:
```bash
rclone lsd opendrive:
rclone about opendrive:  # Note: Not supported - will fail
```
