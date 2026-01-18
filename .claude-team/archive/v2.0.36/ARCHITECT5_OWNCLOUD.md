# Integration Study: ownCloud for CloudSync Ultra

**Sprint:** v2.0.34
**GitHub Issue:** #140
**Author:** Architect-5
**Date:** 2026-01-17
**Status:** Research Complete

---

## Executive Summary

ownCloud is a mature self-hosted file sync and share platform that integrates with CloudSync Ultra through rclone's WebDAV backend with vendor-specific optimizations (`vendor = owncloud`). The application already has the core ownCloud support implemented in the codebase. This study documents the technical requirements, differences from Nextcloud (its fork), authentication considerations, and recommendations for full integration.

**Key Finding:** ownCloud exists in two distinct forms - the traditional PHP-based ownCloud 10 and the newer Go-based ownCloud Infinite Scale (oCIS). Both use WebDAV but have different authentication requirements.

---

## 1. Overview & rclone Backend Details

### Backend Type
ownCloud uses rclone's **WebDAV backend** with vendor-specific settings. rclone supports two ownCloud vendor options:

| Vendor Setting | Platform | Description |
|---------------|----------|-------------|
| `owncloud` | ownCloud 10 | PHP-based WebDAV server |
| `infinitescale` | ownCloud Infinite Scale | Go-based with TUS chunked uploads |

### Current Implementation Status

From `CloudSyncApp/Models/CloudProvider.swift`:
```swift
case .owncloud: return "webdav"  // rcloneType
case .owncloud: return "ownCloud"  // displayName
case .owncloud: return Color(hex: "0B427C")  // brandColor (ownCloud Blue)
case .owncloud: return "cloud.circle.fill"  // iconName
```

From `CloudSyncApp/RcloneManager.swift`:
```swift
func setupOwnCloud(remoteName: String, url: String, username: String, password: String) async throws {
    let params: [String: String] = [
        "url": url,
        "vendor": "owncloud",
        "user": username,
        "pass": password
    ]
    try await createRemote(name: remoteName, type: "webdav", parameters: params)
}
```

**Implementation Gap Identified:** The `TestConnectionStep.swift` does not have an explicit case for `.owncloud`, causing it to fall through to the `default` case which throws an error. This needs to be added.

### rclone Configuration Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `type` | Yes | Must be `webdav` |
| `url` | Yes | WebDAV endpoint URL |
| `vendor` | Yes | `owncloud` for ownCloud 10, `infinitescale` for oCIS |
| `user` | Yes* | Username (required for basic auth) |
| `pass` | Yes* | App password/password (required for basic auth) |
| `bearer_token` | No | Alternative for OIDC authentication (oCIS) |

### WebDAV Endpoints

| Platform | Endpoint Format | Notes |
|----------|----------------|-------|
| ownCloud 10 | `/remote.php/webdav/` | Standard WebDAV endpoint |
| ownCloud 10 | `/remote.php/dav/files/<USERNAME>` | Alternative DAV endpoint |
| oCIS | `/remote.php/webdav/` | Same path, but Go-based backend |

**Finding the URL:** In ownCloud web interface, click on the settings cog in the bottom right of the page to see the WebDAV URL.

### Vendor-Specific Features

When `vendor = owncloud` is set, rclone enables:
- **Modified times support** - Using the `X-OC-Mtime` header
- **Hash support** - SHA1 and MD5 checksums (when available on server)
- **Chunked uploads** - Large file support with ownCloud chunking protocol

---

## 2. Authentication Requirements

### ownCloud 10 (PHP-based)

#### Primary Method: App Passwords (Recommended)

App passwords are the standard authentication method when Two-Factor Authentication (2FA) is enabled.

**How Users Generate App Passwords:**
1. Log into ownCloud web interface
2. Click on username (top right)
3. Navigate to **Personal** settings
4. Go to **App passwords** or **Security** section
5. Enter an app name (e.g., "CloudSync Ultra")
6. Click **Create new app password**
7. Copy the generated password (shown only once)

**Critical:** With 2FA enabled, regular passwords will NOT work for WebDAV connections. Users MUST create an app password under **Personal > App passwords**.

#### Username/Password (No 2FA)

When 2FA is disabled, standard username/password authentication works directly.

### ownCloud Infinite Scale (oCIS)

#### Default: OpenID Connect (OIDC)

**Important:** Basic Authentication is **disabled by default** in oCIS for security reasons.

To use rclone with oCIS:
1. **OIDC Agent** - Requires external OIDC agent to maintain session
2. **Enable Basic Auth** - Administrator must set `PROXY_ENABLE_BASIC_AUTH=true`

**Recommendation:** For oCIS, prefer OIDC authentication or ensure admin has enabled basic auth.

---

## 3. ownCloud vs Nextcloud

Nextcloud forked from ownCloud in 2016. Understanding their differences is crucial for proper integration.

### Historical Context

| Aspect | ownCloud | Nextcloud |
|--------|----------|-----------|
| Founded | 2010 | 2016 (fork) |
| License | AGPLv3 (some enterprise-only) | AGPLv3 (all features) |
| Focus | Enterprise file sync | Collaboration platform |
| Architecture | PHP + Go (Infinite Scale) | PHP |

### API Compatibility

| Feature | ownCloud 10 | Nextcloud | oCIS |
|---------|-------------|-----------|------|
| WebDAV | Yes | Yes | Yes |
| WebDAV Path | `/remote.php/webdav/` | `/remote.php/dav/files/<user>` | `/remote.php/webdav/` |
| X-OC-Mtime | Yes | Yes | Yes |
| Checksums | SHA1/MD5 | SHA1/MD5 | SHA1/MD5 |
| Chunked Uploads | ownCloud protocol | ownCloud protocol | TUS protocol |
| OAuth2 | Optional app | Built-in | OIDC default |

### Configuration Differences

| Setting | ownCloud | Nextcloud |
|---------|----------|-----------|
| rclone vendor | `owncloud` or `infinitescale` | `nextcloud` |
| Default auth | Username/Password | App Password |
| 2FA handling | App passwords | App passwords |
| Enterprise features | Some paid | All free |

### Which Settings to Use

| User Has | Use Vendor | Notes |
|----------|------------|-------|
| ownCloud 10 | `owncloud` | Standard PHP installation |
| ownCloud Infinite Scale | `infinitescale` | For TUS upload support |
| Nextcloud | `nextcloud` | Always use nextcloud vendor |

**How to Identify Platform:**
- Check server login page branding
- ownCloud uses blue theme, Nextcloud uses blue/white
- URL `/status.php` returns version info

---

## 4. Known Limitations & Workarounds

### File Size Limits

**Default Maximum:** 512MB (configurable by server admin)

**Chunked Uploads:** The ownCloud sync client and rclone can upload files of any size using chunked uploads. The chunk size is typically 10MB (configurable).

**Server-Side Configuration:** PHP settings like `upload_max_filesize` and `post_max_size` affect upload limits.

### Special Characters in Filenames

**Known Issues:**
- Files with characters like `< > : " / \ | ?` may fail on Windows servers
- Encoding issues with non-ASCII characters (e.g., `Ä`, `ö`, `ü`)
- 404 errors reported for filenames with special characters via WebDAV
- Case sensitivity mismatches between platforms

**rclone Handling:** rclone escapes problematic characters automatically using the `--backend-encoding` flag.

**Recommendation:** Warn users about avoiding special characters in cross-platform scenarios.

### Chunked Upload Considerations

**ownCloud 10 Chunking:**
- Uses custom HTTP headers: `OC-Chunked: 1`, `OC-Total-Length`, `OC-Chunk-Size`
- File name format: `<path/filename>-chunking-<transferid>-<chunkcount>-<index>`
- Temporary space required equals final file size during merge

**oCIS TUS Protocol:**
- Uses TUS resumable upload protocol
- Better support for interrupted uploads
- Enabled automatically with `vendor = infinitescale`

**Potential Issues:**
- Public link uploads may fail for files >100MB (chunking API requires authentication)
- Merge phase can cause timeouts for very large files
- Reverse proxies may interfere with chunked transfer encoding

### Version Compatibility

| Version | Status | WebDAV Support | Notes |
|---------|--------|----------------|-------|
| oCIS 5.x | Current | Full | Go-based, TUS uploads |
| oCIS 4.x | Supported | Full | Go-based |
| oC 10.14+ | Current | Full | PHP-based |
| oC 10.0-10.13 | Legacy | Full | May lack features |
| oC <10.0 | EOL | Basic | Unsupported |

### Rate Limiting

Some hosted ownCloud instances may have rate limits. Conservative parallelism is already set in `TransferOptimizer.swift`:

```swift
case .sftp, .ftp, .webdav, .nextcloud, .owncloud:
    return 32 * 1024 * 1024  // 32MB chunk size
```

---

## 5. Step-by-Step Connection Flow

### User Experience Flow

```
+-------------------------------------------------------------+
|  Step 1: Select Provider                                     |
|  User selects "ownCloud" from provider list                  |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|  Step 2: Enter Server URL                                    |
|  +-----------------------------------------------------+    |
|  | Server URL: [https://cloud.example.com          ]   |    |
|  +-----------------------------------------------------+    |
|  Hint: "Enter your ownCloud server address"                 |
|  Example: "https://cloud.example.com"                       |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|  Step 3: Enter Credentials                                   |
|  +-----------------------------------------------------+    |
|  | Username:    [john.doe                          ]   |    |
|  +-----------------------------------------------------+    |
|  +-----------------------------------------------------+    |
|  | Password:    [************************          ]   |    |
|  +-----------------------------------------------------+    |
|                                                              |
|  Note: If you have 2FA enabled, use an App Password         |
|  How to get: Personal Settings > App Passwords              |
|                                                              |
|  [ ] This is ownCloud Infinite Scale (oCIS)                 |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|  Step 4: Test Connection                                     |
|  [Testing connection to cloud.example.com...]               |
|                                                              |
|  OK Connected successfully                                   |
|  OK WebDAV endpoint verified                                 |
|  OK Account: john.doe                                        |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|  Step 5: Complete Setup                                      |
|  Remote Name: [My ownCloud                              ]   |
|                                                              |
|  [Complete Setup]                                           |
+-------------------------------------------------------------+
```

### WebDAV URL Construction

```swift
func constructOwnCloudWebDAVURL(baseURL: String) -> String {
    var url = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)

    // Ensure HTTPS prefix
    if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
        url = "https://" + url
    }

    // Remove trailing slash
    url = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

    // Append WebDAV path
    return "\(url)/remote.php/webdav/"
}
```

### Required User Input

| Field | Format | Validation |
|-------|--------|------------|
| Server URL | URL | Valid URL, auto-add `https://` if missing |
| Username | String | Non-empty |
| Password/App Password | String | Non-empty |
| Is oCIS | Boolean | Optional checkbox for Infinite Scale |

---

## 6. Self-Hosted Considerations

### URL Variations

Self-hosted ownCloud instances can have various URL patterns:

| Type | Example URL |
|------|-------------|
| Root domain | `https://cloud.example.com` |
| Subdirectory | `https://example.com/owncloud` |
| Custom port | `https://example.com:8443` |
| Local network | `http://192.168.1.100` |
| Docker container | `https://localhost:9200` |

### SSL/TLS Requirements

**Minimum Requirements:**
- TLSv1.2 or higher recommended
- Valid SSL certificate (self-signed causes issues)

**Self-Signed Certificates:**
- rclone flag: `--no-check-certificate`
- Not recommended for production use

**Common SSL Issues:**
- Certificate chain incomplete
- Expired certificates
- Hostname mismatch

### Reverse Proxy Setups

Many self-hosted instances sit behind reverse proxies (nginx, Apache, Traefik, Caddy).

**Common Issues:**

1. **Header Stripping:**
   - Apache may strip `Authorization: Bearer` headers
   - Fix: Enable `CGIPassAuth on` in Apache config

2. **Chunked Transfer Encoding:**
   - Some proxies don't support chunked encoding properly
   - May cause large file upload failures

3. **Timeouts:**
   - Default proxy timeouts may be too short for large uploads
   - Increase `proxy_read_timeout` in nginx

4. **WebSocket/Long Polling:**
   - oCIS may use WebSocket connections
   - Ensure proxy supports WebSocket upgrade

**Recommended Nginx Config:**
```nginx
location / {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 300s;
    client_max_body_size 0;  # Disable size limit
}
```

### ownCloud Infinite Scale (Docker) Specific

When running oCIS in Docker:
1. Ensure `PROXY_ENABLE_BASIC_AUTH=true` if using basic auth
2. Map correct ports (typically 9200)
3. Configure proper TLS termination

---

## 7. Implementation Recommendation

### Difficulty Rating: **EASY**

### Rationale
1. **Already Implemented:** Core `setupOwnCloud()` function exists in `RcloneManager.swift`
2. **Standard Protocol:** Uses WebDAV which is well-supported by rclone
3. **Similar to Nextcloud:** Can reuse much of the Nextcloud implementation pattern
4. **No OAuth Required:** App password authentication is straightforward

### Remaining Work

| Task | Priority | Effort | Status |
|------|----------|--------|--------|
| Add `.owncloud` case to `TestConnectionStep.swift` | High | Low | Missing |
| Add URL normalization helper | High | Low | Missing |
| Add ownCloud instructions to `ConfigureSettingsStep` | High | Low | Missing |
| Add oCIS detection/checkbox | Medium | Low | Missing |
| Add "How to get App Password" help text | Medium | Low | Missing |
| Add connection test during setup | Medium | Medium | Exists (needs case) |

### Code Changes Required

#### 1. Add ownCloud Case to TestConnectionStep.swift

```swift
// In configureRemoteWithRclone() switch statement, add:
case .owncloud:
    // Construct proper WebDAV URL
    let webdavURL = constructOwnCloudURL(from: username)
    try await rclone.setupOwnCloud(
        remoteName: rcloneName,
        url: webdavURL,
        username: username,
        password: password
    )

case .nextcloud:
    // Also add nextcloud case if missing
    let webdavURL = constructNextcloudURL(from: username)
    try await rclone.setupNextcloud(
        remoteName: rcloneName,
        url: webdavURL,
        username: username,
        password: password
    )
```

**Note:** The current implementation passes `username` as the URL, which is incorrect. The wizard should collect a separate server URL field.

#### 2. Add Provider Instructions

Update `ConfigureSettingsStep.swift`:

```swift
private var providerInstructions: String? {
    switch provider {
    case .owncloud:
        return "Enter your ownCloud server URL, username, and password. If 2FA is enabled, create an App Password in Personal Settings > App Passwords."
    case .nextcloud:
        return "Enter your Nextcloud server URL, username, and App Password. Create an App Password in Settings > Security > Devices & Sessions."
    // ... other cases
    }
}

private var providerHelpURL: URL? {
    switch provider {
    case .owncloud:
        return URL(string: "https://doc.owncloud.com/server/next/user_manual/files/access_webdav.html")
    case .nextcloud:
        return URL(string: "https://docs.nextcloud.com/server/latest/user_manual/en/files/access_webdav.html")
    // ... other cases
    }
}
```

#### 3. Add Server URL Field

The wizard currently uses `username` for server URL in WebDAV-based providers, which is confusing. Consider adding a dedicated server URL state variable:

```swift
// In ProviderConnectionWizardState:
@Published var serverURL = ""

// In ConfigureSettingsStep, add conditional field:
if provider == .owncloud || provider == .nextcloud {
    HStack {
        Text("Server URL")
            .frame(width: 100, alignment: .trailing)
        TextField("https://cloud.example.com", text: $serverURL)
            .textFieldStyle(.roundedBorder)
    }
}
```

#### 4. No Changes to CloudProvider.swift Needed

ownCloud is already fully defined with:
- `rcloneType = "webdav"`
- `iconName = "cloud.circle.fill"`
- `brandColor = Color(hex: "0B427C")`
- `defaultRcloneName = "owncloud"`

---

## 8. Testing Recommendations

### Manual Testing Checklist

- [ ] Connect to ownCloud 10 instance (standard installation)
- [ ] Connect to ownCloud 10 with 2FA enabled (using app password)
- [ ] Connect to ownCloud Infinite Scale (with basic auth enabled)
- [ ] Connect to subdirectory installation (`/owncloud/`)
- [ ] Connect to custom port installation
- [ ] Connect via self-signed certificate (with warning)
- [ ] Upload large file (>1GB)
- [ ] Upload many small files
- [ ] Download/sync operations
- [ ] Test special characters in filenames
- [ ] Invalid credentials handling
- [ ] Invalid URL handling

### Recommended Test Environments

1. **ownCloud 10** - Standard PHP installation
2. **ownCloud Infinite Scale** - Docker-based (oCIS)
3. **Behind reverse proxy** (nginx/Apache)
4. **With 2FA enabled**

---

## 9. References

### Official Documentation

- [rclone WebDAV Documentation](https://rclone.org/webdav/)
- [ownCloud WebDAV Documentation](https://doc.owncloud.com/server/next/admin_manual/configuration/files/external_storage/webdav.html)
- [ownCloud rclone Integration Guide](https://owncloud.dev/clients/rclone/webdav-sync-basic-auth/)
- [ownCloud Infinite Scale rclone Setup](https://owncloud.dev/ocis/guides/migrate-data-rclone/)
- [ownCloud 2FA Documentation](https://doc.owncloud.com/server/next/admin_manual/configuration/user/user_auth_twofactor.html)

### Community Resources

- [rclone GitHub: Infinite Scale vendor PR](https://github.com/rclone/rclone/pull/8172)
- [ownCloud Central: WebDAV with 2FA](https://central.owncloud.org/t/webdav-authentication-with-2fa-enabled/34195)
- [ownCloud Core: Special Characters Issues](https://github.com/owncloud/core/issues/34600)

### Related CloudSync Ultra Files

- `/Users/antti/claude/CloudSyncApp/RcloneManager.swift` - setupOwnCloud function (line 1328)
- `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift` - Provider definitions
- `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift` - Needs `.owncloud` case
- `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift` - Needs instructions
- `/Users/antti/claude/CloudSyncApp/Models/TransferOptimizer.swift` - ownCloud chunk settings (line 54)

---

## Conclusion

ownCloud integration for CloudSync Ultra is well-positioned for completion with **minimal effort**. The core rclone integration is already implemented (`setupOwnCloud` function). The primary remaining work involves:

1. **Critical:** Add `.owncloud` (and `.nextcloud`) case to `TestConnectionStep.swift`
2. **Important:** Add provider-specific instructions and help links
3. **Enhancement:** Add dedicated server URL field for self-hosted providers

The key differentiation from Nextcloud is the `vendor = owncloud` setting and awareness of ownCloud Infinite Scale as a separate deployment option. Users migrating between ownCloud and Nextcloud should find the experience nearly identical.

**Final Assessment:** Ready for implementation with minimal code changes. Estimated effort: 2-4 hours.
