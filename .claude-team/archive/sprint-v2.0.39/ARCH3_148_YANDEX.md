# Integration Study #148: Yandex Disk

**Architect:** Architect-3
**Date:** 2026-01-18
**Status:** Complete

---

## Executive Summary

Yandex Disk is a Russian cloud storage service operated by Yandex, one of the largest technology companies in Russia. The service is fully integrated into CloudSync Ultra with OAuth 2.0 authentication via rclone's native `yandex` backend. This study documents the implementation status, configuration requirements, and regional considerations.

---

## 1. Implementation Status in CloudSync Ultra

### Current Implementation: COMPLETE

| Component | Status | Location |
|-----------|--------|----------|
| CloudProviderType enum | Implemented | `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift` |
| rclone backend mapping | Configured | `rcloneType: "yandex"` |
| OAuth support | Enabled | `requiresOAuth: true` |
| Brand color | Set | `#FF3333` (Yandex Red) |
| Icon | Assigned | `y.circle.fill` |
| Setup function | Implemented | `RcloneManager.setupYandexDisk()` |
| Transfer optimization | Configured | 8MB chunk size |
| Unit tests | Passing | `Phase1Week1ProvidersTests.swift` |

### Code References

```swift
// CloudProvider.swift - Line 31
case yandexDisk = "yandex"

// Display name - Line 90
case .yandexDisk: return "Yandex Disk"

// rclone type - Line 269
case .yandexDisk: return "yandex"

// OAuth requirement - Line 391
case .googleDrive, .dropbox, .oneDrive, .box, .yandexDisk, ...
    return true
```

```swift
// RcloneManager.swift - Line 1406-1408
func setupYandexDisk(remoteName: String) async throws {
    // Yandex Disk uses OAuth - opens browser for authentication
    try await createRemoteInteractive(name: remoteName, type: "yandex")
}
```

---

## 2. Authentication

### OAuth 2.0 Flow

Yandex Disk uses OAuth 2.0 via the Yandex ID authentication system.

| Parameter | Value |
|-----------|-------|
| Auth Type | OAuth 2.0 |
| Auth URL | `https://oauth.yandex.com/authorize` |
| Token URL | `https://oauth.yandex.com/token` |
| Redirect URI | `http://127.0.0.1:53682/` (rclone default) |
| Token Lifetime | 12 months |
| Refresh | Manual re-authentication required after expiry |

### Client ID/Secret Requirements

| Option | Description |
|--------|-------------|
| Default | rclone's built-in client ID (recommended for most users) |
| Custom | Register app at [Yandex OAuth Console](https://oauth.yandex.com/) |

**Custom App Registration Steps:**
1. Go to https://oauth.yandex.com/
2. Create new application
3. Select "Web services" platform
4. Add redirect URI: `http://127.0.0.1:53682/`
5. Request Yandex Disk access scopes
6. Note the Client ID and Secret

### Required Scopes for Yandex Disk

- `cloud_api:disk.read` - Read files
- `cloud_api:disk.write` - Write files
- `cloud_api:disk.app_folder` - App folder access
- `cloud_api:disk.info` - Account info

### Account Requirement

**IMPORTANT:** A Yandex Mail account is mandatory. Operations fail without one, displaying error:
```
[403 - DiskUnsupportedUserAccountTypeError]
```

---

## 3. rclone Backend Configuration

### Backend Details

| Parameter | Value |
|-----------|-------|
| Backend Name | `yandex` |
| Config Type | `yandex` |
| Hash Support | MD5 (native) |
| Modification Times | Yes (nanosecond precision via `rclone_modified` metadata) |

### Standard Configuration

```ini
[yandex]
type = yandex
token = {"access_token":"...","token_type":"bearer","expiry":"..."}
```

### Optional Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `client_id` | (built-in) | Custom OAuth client ID |
| `client_secret` | (built-in) | Custom OAuth client secret |
| `hard_delete` | false | Skip trash, permanently delete |
| `auth_url` | - | Custom auth server URL |
| `token_url` | - | Custom token server URL |

### rclone Commands

```bash
# Configure
rclone config create yandex yandex

# List files
rclone ls yandex:

# Check quota
rclone about yandex:

# Clean trash
rclone cleanup yandex:
```

---

## 4. Features and Limitations

### Storage Limits

| Plan | Storage | Notes |
|------|---------|-------|
| Free | 5-10 GB | Varies by account type |
| Yandex 360 (200 GB) | 200 GB | Subscription required |
| Yandex 360 (1 TB) | 1 TB | Subscription required |
| Yandex 360 (3 TB) | 3 TB | Subscription required |

### Upload Limits

- Maximum upload per month: 2x storage capacity
- Example: 5 GB plan = 10 GB monthly upload limit
- Limit resets 30 days after first upload

### Special Features

| Feature | Availability |
|---------|--------------|
| Unlimited video storage | Paid plans (mobile upload only) |
| Unlimited photo upload | Auto-upload feature |
| File versioning | 14 days (free), 90 days (paid) |

### File Size Limits

| Limit | Value | Notes |
|-------|-------|-------|
| Max file size | ~50 GB | Practical limit |
| Recommended timeout | 2 min per GiB | For large files |
| Large file threshold | ~5 GiB | Requires timeout adjustment |

**Large File Handling:**
Files exceeding ~5 GiB require timeout adjustments. Recommended formula:
```
timeout = 2 * file_size_in_GiB (minutes)
```
Example: 30 GiB file = 60 minute timeout

### Supported Operations

| Operation | Supported |
|-----------|-----------|
| List | Yes |
| Read | Yes |
| Write | Yes |
| Delete | Yes |
| Copy | Yes |
| Move | Yes |
| Mkdir | Yes |
| Rmdir | Yes |
| Purge | Yes |
| About (quota) | Yes |
| Cleanup (trash) | Yes |
| Server-side copy | Yes |

### Trash/Recycle Bin

- Deleted files go to trash by default
- Use `rclone cleanup remote:` to permanently delete trashed files
- Set `hard_delete = true` to skip trash

### Character Handling

- Restricted characters are automatically replaced
- Invalid UTF-8 bytes are automatically replaced
- Default user agent spoofing enabled for better upload performance

---

## 5. CloudSync Integration

### Wizard Flow Requirements

**Recommended Steps:**

1. **Welcome Step**
   - Provider introduction
   - Regional notice (Russia-focused service)
   - Account requirement warning (Yandex Mail needed)

2. **Account Type Selection**
   - Personal account
   - Note: Business accounts may have different requirements

3. **OAuth Authentication**
   - Opens browser to Yandex login
   - User grants permissions
   - rclone captures token via localhost redirect

4. **Connection Test**
   - Verify token works
   - Display account info and quota

5. **Success Confirmation**
   - Show connected account
   - Display storage usage

### OAuth Redirect Handling

The current implementation uses rclone's interactive mode which:
1. Starts a local web server on `http://127.0.0.1:53682/`
2. Opens browser to Yandex OAuth
3. Captures redirect with authorization code
4. Exchanges code for tokens

**No custom redirect handling needed** - rclone manages this automatically.

### Test Connection Method

```swift
// Recommended test: List root directory
func testYandexConnection(remoteName: String) async throws -> Bool {
    let result = try await rcloneManager.listDirectory(
        remote: remoteName,
        path: ""
    )
    return result != nil
}

// Alternative: Check quota
func checkYandexQuota(remoteName: String) async throws -> StorageQuota {
    return try await rcloneManager.getStorageInfo(remoteName)
}
```

### Transfer Optimization

Current configuration in `TransferOptimizer.swift`:

```swift
case .seafile, .koofr, .yandexDisk, .mailRuCloud, .jottacloud:
    return 8 * 1024 * 1024   // 8MB default chunk size
```

**Recommended parallelism** (not yet implemented):
```swift
case .yandexDisk:
    return (transfers: 4, checkers: 8)  // Conservative for Russia-based servers
```

---

## 6. Regional Considerations

### Russia-Focused Service

Yandex Disk is primarily designed for the Russian market:

| Aspect | Consideration |
|--------|---------------|
| Data Center Location | Russia |
| Primary Language | Russian (English available) |
| Latency | Higher from non-Russian locations |
| Account Creation | May require Russian phone for verification |
| Support | Primarily in Russian |

### Potential Issues for Non-Russian Users

1. **Latency**: Higher latency for users outside Russia/CIS
2. **Account Verification**: Phone verification may require Russian number
3. **Terms of Service**: Subject to Russian data protection laws
4. **Accessibility**: Service may be blocked in some regions
5. **Payment**: Subscription payments may require Russian payment methods

### Sanctions and Compliance

**Warning:** Users should verify compliance with their local regulations regarding Russian services. Some organizations may prohibit use of Russian cloud services.

### Recommendation

- Display regional notice in wizard
- Recommend for users with existing Yandex accounts
- Note potential latency for non-CIS users
- Include compliance warning for enterprise users

---

## 7. Testing Recommendations

### Manual Testing Checklist

- [ ] OAuth flow completes successfully
- [ ] Token stored correctly in rclone config
- [ ] List operation works
- [ ] Upload small file (< 1 MB)
- [ ] Upload medium file (10-100 MB)
- [ ] Upload large file (> 1 GB) with extended timeout
- [ ] Download file
- [ ] Delete file (goes to trash)
- [ ] Cleanup trash
- [ ] Quota display accurate
- [ ] Connection test works
- [ ] Token refresh after expiry

### Test Account Setup

Registration URL: https://passport.yandex.com/registration

**Requirements:**
- Valid email address
- Phone number (may require Russian number)
- CAPTCHA completion

---

## 8. References

### Official Documentation
- [rclone Yandex Disk](https://rclone.org/yandex/)
- [Yandex OAuth Registration](https://yandex.com/dev/id/doc/en/register-client)
- [Yandex OAuth Documentation](https://yandex.com/dev/oauth/)
- [Yandex 360 Plans](https://360.yandex.com/premium-plans/)
- [Yandex Disk Storage Info](https://yandex.com/support/disk/enlarge.html)

### CloudSync Ultra Implementation
- `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`
- `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`
- `/Users/antti/claude/CloudSyncApp/Models/TransferOptimizer.swift`
- `/Users/antti/claude/CloudSyncAppTests/Phase1Week1ProvidersTests.swift`

---

## 9. Conclusion

Yandex Disk integration in CloudSync Ultra is **fully implemented** and functional. The provider uses standard OAuth 2.0 authentication through rclone's native backend, requiring no custom implementation beyond the existing interactive setup flow.

### Key Takeaways

1. **Implementation Complete**: All required components are in place
2. **OAuth Handled by rclone**: No custom OAuth code needed
3. **Regional Focus**: Best suited for Russian/CIS users
4. **Account Requirement**: Users must have Yandex Mail account
5. **Large File Consideration**: Timeout adjustments needed for files > 5 GiB

### Recommendations

1. Add regional notice to wizard flow
2. Implement parallelism settings for optimal performance
3. Consider adding timeout configuration for large files
4. Document account requirement prominently in UI
5. Add compliance warning for enterprise deployments

---

*Study completed by Architect-3 on 2026-01-18*
