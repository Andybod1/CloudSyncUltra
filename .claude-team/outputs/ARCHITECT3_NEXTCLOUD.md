# Integration Study: Nextcloud for CloudSync Ultra

**Sprint:** v2.0.34
**GitHub Issue:** #139
**Author:** Architect-3
**Date:** 2026-01-17
**Status:** Research Complete

---

## Executive Summary

Nextcloud is a self-hosted file sync and share platform that is fully supported through rclone's WebDAV backend with vendor-specific optimizations. Integration complexity is **EASY** as the application already has Nextcloud support partially implemented in the codebase. This study documents the technical requirements, authentication considerations, and recommendations for full integration.

---

## 1. Overview & rclone Backend Details

### Backend Type
Nextcloud uses rclone's **WebDAV backend** with a dedicated vendor setting (`vendor = nextcloud`). This is already implemented in the CloudSync Ultra codebase.

### Current Implementation Status
From `CloudSyncApp/RcloneManager.swift`:
```swift
func setupNextcloud(remoteName: String, url: String, username: String, password: String) async throws {
    let params: [String: String] = [
        "url": url,
        "vendor": "nextcloud",
        "user": username,
        "pass": password
    ]
    try await createRemote(name: remoteName, type: "webdav", parameters: params)
}
```

From `CloudSyncApp/Models/CloudProvider.swift`:
```swift
case .nextcloud: return "webdav"  // rcloneType
```

### rclone Configuration Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `type` | Yes | Must be `webdav` |
| `url` | Yes | WebDAV endpoint URL |
| `vendor` | Yes | Must be `nextcloud` for Nextcloud-specific optimizations |
| `user` | Yes* | Username (required unless using bearer token) |
| `pass` | Yes* | App password (required unless using bearer token) |
| `bearer_token` | No | Alternative to user/pass authentication |

### WebDAV Endpoints
Nextcloud provides multiple WebDAV endpoints:

| Endpoint | Purpose | Notes |
|----------|---------|-------|
| `/remote.php/dav/files/<USERNAME>` | Main files access | **Recommended** - supports chunked uploads |
| `/remote.php/webdav/` | Legacy endpoint | Limited functionality |
| `/public.php/dav/files/{share_token}` | Public shares | Available since Nextcloud 29 |

### Vendor-Specific Features
When `vendor = nextcloud` is set, rclone enables:
- **Modified times support** - Accurate file timestamps
- **Hash support** - SHA1 and MD5 checksums (version dependent)
- **Chunked uploads** - Large file support with resume capability

---

## 2. Authentication Requirements

### Primary Method: App Passwords (Recommended)

App passwords are the standard authentication method for third-party applications connecting to Nextcloud.

**How Users Generate App Passwords:**
1. Log into Nextcloud web interface
2. Navigate to **Settings** (top right avatar)
3. Go to **Security** section
4. Scroll to **Devices & Sessions**
5. Enter an app name (e.g., "CloudSync Ultra")
6. Click **Create new app password**
7. Copy the generated password (shown only once)

**App Password Format:** `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX` (e.g., `t7j8o-qpW3H-Wy2BW-XC82X-t5pkM`)

**Advantages:**
- Works with 2FA enabled
- Can be revoked independently
- Limited scope per application
- Standard Nextcloud security pattern

### Two-Factor Authentication (2FA) Considerations

**Critical:** When 2FA is enabled on a Nextcloud account, regular passwords will NOT work for WebDAV connections. Users MUST use app passwords.

**Known Issues:**
- Some configurations report authentication failures even with app passwords when TOTP 2FA is enabled
- Community discussions suggest this may be configuration-specific
- Workaround: Verify app password in Nextcloud web UI before configuration

**Recommendation for CloudSync Ultra:**
- Always instruct users to create an app password
- Provide clear warning: "If you have 2FA enabled, you must use an app password"
- Consider adding a "Test Connection" button during setup

### Alternative: OAuth2/Bearer Token

Nextcloud supports OAuth2 for third-party applications, but with significant limitations:

**Limitations:**
- No scoped access - tokens have full account access (read/write)
- Requires server-side OAuth2 app registration
- More complex setup for self-hosted instances
- Not recommended for general-purpose file sync applications

**Recommendation:** Stick with app password authentication for CloudSync Ultra.

---

## 3. Self-Hosted Setup Considerations

### URL Variability

Self-hosted Nextcloud instances can have many different URL patterns:

| Type | Example URL |
|------|-------------|
| Root domain | `https://cloud.example.com` |
| Subdirectory | `https://example.com/nextcloud` |
| Custom port | `https://example.com:8443` |
| Local network | `http://192.168.1.100` |
| With path prefix | `https://example.com/cloud/index.php/...` |

**WebDAV URL Construction:**
```
{base_url}/remote.php/dav/files/{username}
```

**Example:**
- Base URL: `https://cloud.example.com`
- Username: `john`
- Final URL: `https://cloud.example.com/remote.php/dav/files/john`

### Version Compatibility

Nextcloud maintains backward compatibility for WebDAV. All actively maintained versions should work:

| Version | Status | WebDAV Support |
|---------|--------|----------------|
| 29+ | Current | Full + public share endpoint |
| 25-28 | Maintained | Full support |
| 20-24 | Legacy | Full support |
| <20 | EOL | Should work but unsupported |

**Note:** Nextcloud has a built-in WebDAV server (SabreDAV). Users should NOT have Apache's `mod_webdav` enabled simultaneously.

### SSL/TLS Considerations

**Minimum Requirements:**
- TLSv1.2 or higher recommended
- OpenSSL 1.0.2b+ or 1.0.1d+
- Valid SSL certificate (self-signed may cause issues)

**Common Issues:**
- Self-signed certificates require explicit trust
- Some proxies may strip authentication headers
- Apache needs `mod_headers`, `mod_rewrite`, `mod_env` enabled

### Reverse Proxy Configurations

Many self-hosted instances sit behind reverse proxies (nginx, Apache, Traefik, Caddy). Common issues:

- **Header stripping**: Apache strips `Authorization: Bearer` headers by default
- **Chunked transfer encoding**: Some proxies don't support it properly
- **Timeouts**: Large uploads may timeout before completion

---

## 4. Step-by-Step Connection Flow

### User Experience Flow

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Select Provider                                     │
│  User selects "Nextcloud" from provider list                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Enter Server URL                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Server URL: [https://cloud.example.com          ]   │    │
│  └─────────────────────────────────────────────────────┘    │
│  Hint: "Enter your Nextcloud server address"                │
│  Example: "https://cloud.example.com or your-domain.com"    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Enter Credentials                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Username:    [john.doe                          ]   │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ App Password: [••••••••••••••••••••••••••       ]   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ⚠️ Note: Use an App Password, not your login password      │
│  📖 How to create an App Password:                          │
│     Settings → Security → Devices & Sessions → Create       │
│                                                              │
│  ℹ️ If you have 2FA enabled, App Password is required       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: Test Connection                                     │
│  [Testing connection to cloud.example.com...]               │
│                                                              │
│  ✓ Connected successfully                                   │
│  ✓ WebDAV endpoint verified                                 │
│  ✓ Account: john.doe                                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Complete Setup                                      │
│  Remote Name: [My Nextcloud                             ]   │
│                                                              │
│  [Complete Setup]                                           │
└─────────────────────────────────────────────────────────────┘
```

### Required User Input

| Field | Format | Validation |
|-------|--------|------------|
| Server URL | URL | Must be valid URL, auto-add `https://` if missing |
| Username | String | Non-empty, alphanumeric + common special chars |
| App Password | String | Non-empty (format: `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`) |

### URL Processing Logic

```swift
func constructNextcloudWebDAVURL(baseURL: String, username: String) -> String {
    var url = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)

    // Ensure HTTPS prefix
    if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
        url = "https://" + url
    }

    // Remove trailing slash
    url = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

    // Append WebDAV path with username
    return "\(url)/remote.php/dav/files/\(username)"
}
```

---

## 5. Known Limitations & Workarounds

### Chunked Upload Issues

**Problem:** Large file uploads (>2GB) may fail with "423 Locked" errors during chunk merge phase.

**Cause:** When rclone finishes uploading chunks, Nextcloud merges them server-side. This can take several minutes for large files, and rclone may retry before completion.

**Workarounds:**
1. Increase chunk size (up to 1GB) in Nextcloud server configuration
2. Set `--retries 1 --low-level-retries 1` for very large files
3. Avoid uploading very large individual files during peak server load

**Recommendation:** Add documentation for users experiencing this issue.

### Performance with Small Files

**Problem:** Uploading many small files is significantly slower than large files.

**Cause:** WebDAV protocol overhead per file + Nextcloud indexing.

**Workaround:** Consider zipping folders with many small files before upload.

### Hash Support Variability

**Issue:** Hash checksums (SHA1/MD5) may not be available on all files.

**Cause:** Depends on Nextcloud version and whether files were uploaded with hashes.

**Impact:** `--checksum` flag may not work reliably for sync operations.

**Recommendation:** Default to timestamp-based comparison for Nextcloud remotes.

### Rate Limiting

**Issue:** Some Nextcloud instances (especially hosted ones) may have rate limits.

**Recommendation:** Use conservative parallelism settings:
```swift
case .nextcloud: return (transfers: 4, checkers: 8)
```

### Connection Resets

**Issue:** Long-running operations may experience "connection reset by peer" errors.

**Cause:** Timeouts from reverse proxies, load balancers, or Nextcloud itself.

**Workaround:**
- Use `--timeout 5m` for longer operations
- Implement retry logic in transfer operations

### File Locking Conflicts

**Issue:** Nextcloud's collaborative editing file locks can cause upload failures.

**Cause:** Files open in Collabora/OnlyOffice are locked.

**Detection:** Look for "423 Locked" responses without ongoing chunk merge.

---

## 6. Implementation Recommendation

### Difficulty Rating: **EASY**

### Rationale
1. **Already Implemented:** Base Nextcloud support exists in `RcloneManager.swift`
2. **Standard Protocol:** Uses WebDAV which is well-supported by rclone
3. **No OAuth Required:** App password authentication is straightforward
4. **Vendor Support:** rclone has explicit Nextcloud vendor optimizations

### Remaining Work

| Task | Priority | Effort |
|------|----------|--------|
| Add URL validation/normalization | High | Low |
| Add "How to get App Password" help text | High | Low |
| Add connection test during setup | Medium | Medium |
| Add chunked upload documentation | Low | Low |
| Handle 2FA detection/warning | Medium | Low |

### Code Changes Required

#### 1. URL Normalization Helper (New)
Add to `RcloneManager.swift` or create utility:
```swift
static func normalizeNextcloudURL(_ input: String, username: String) -> String {
    var url = input.trimmingCharacters(in: .whitespacesAndNewlines)

    // Add scheme if missing
    if !url.lowercased().hasPrefix("http") {
        url = "https://" + url
    }

    // Remove trailing slashes
    while url.hasSuffix("/") {
        url.removeLast()
    }

    // Construct proper WebDAV URL
    return "\(url)/remote.php/dav/files/\(username)"
}
```

#### 2. Update setupNextcloud Function
Modify existing implementation to auto-construct URL:
```swift
func setupNextcloud(remoteName: String, serverURL: String, username: String, password: String) async throws {
    // Normalize URL with username
    let webdavURL = Self.normalizeNextcloudURL(serverURL, username: username)

    let params: [String: String] = [
        "url": webdavURL,
        "vendor": "nextcloud",
        "user": username,
        "pass": password
    ]
    try await createRemote(name: remoteName, type: "webdav", parameters: params)
}
```

#### 3. Connection Wizard UI Updates
In `ConfigureSettingsStep.swift`, add:
- Server URL field (instead of full WebDAV URL)
- Help text explaining app passwords
- Link or instructions for 2FA users

#### 4. No Changes to CloudProvider.swift
Nextcloud is already defined with:
- `rcloneType = "webdav"`
- `iconName = "cloud.circle"`
- `brandColor = Color(hex: "0082C9")`

---

## 7. Testing Recommendations

### Manual Testing Checklist

- [ ] Connect to standard Nextcloud Hub instance
- [ ] Connect with 2FA enabled (using app password)
- [ ] Connect to subdirectory installation (`/nextcloud/`)
- [ ] Connect to custom port installation
- [ ] Upload large file (>1GB)
- [ ] Upload many small files
- [ ] Download/sync operations
- [ ] Connection test during setup
- [ ] Invalid credentials handling
- [ ] Invalid URL handling

### Recommended Test Environments

1. **Nextcloud Hub** - Standard installation
2. **Nextcloud AIO** (All-In-One) - Docker-based
3. **Hosted Nextcloud** (e.g., Hetzner, Hostiso)
4. **Nextcloud behind reverse proxy**

---

## 8. References

### Official Documentation
- [rclone WebDAV Documentation](https://rclone.org/webdav/)
- [Nextcloud WebDAV Access Documentation](https://docs.nextcloud.com/server/latest/user_manual/en/files/access_webdav.html)
- [Nextcloud OAuth2 Documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/oauth2.html)
- [Nextcloud 2FA Documentation](https://docs.nextcloud.com/server/latest/user_manual/en/user_2fa.html)

### Community Resources
- [rclone Forum: Nextcloud Discussions](https://forum.rclone.org/t/rclone-w-nextcloud/42612)
- [Nextcloud Community: WebDAV with 2FA](https://help.nextcloud.com/t/how-make-webdav-work-with-2fa-turned-on/171868)
- [rclone GitHub: Nextcloud Chunked Upload Issues](https://github.com/rclone/rclone/issues/7199)

### Related CloudSync Ultra Files
- `/Users/antti/claude/CloudSyncApp/RcloneManager.swift` - Nextcloud setup function
- `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift` - Provider definitions

---

## Conclusion

Nextcloud integration for CloudSync Ultra is well-positioned for completion. The core rclone integration is already implemented. The primary remaining work involves UX improvements to guide users through the connection process, particularly around URL formatting and app password generation. With the documented changes, Nextcloud can be considered a fully supported provider.

**Final Assessment:** Ready for implementation with minimal code changes.
