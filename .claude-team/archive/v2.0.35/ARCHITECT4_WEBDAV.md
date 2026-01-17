# Integration Study: WebDAV for CloudSync Ultra

**Sprint:** v2.0.35
**GitHub Issue:** #142
**Author:** Architect-4
**Date:** 2026-01-17
**Status:** Research Complete

---

## Executive Summary

WebDAV (Web-based Distributed Authoring and Versioning) is a protocol that extends HTTP to allow collaborative file management on remote web servers. Rclone's WebDAV backend provides a unified interface to connect to various WebDAV-compatible servers with vendor-specific optimizations. CloudSync Ultra already has **partial WebDAV support** implemented, including dedicated setup methods for generic WebDAV, Nextcloud, and ownCloud.

**Recommendation: EASY difficulty** - The core implementation exists. Enhancements focus on improving user experience with better URL handling, vendor selection UI, and authentication options.

---

## 1. Overview & rclone Backend Details

### Backend Type

WebDAV uses the **`webdav`** backend in rclone. This is a flexible backend that supports multiple vendors through the `vendor` configuration parameter.

### Current Implementation Status

**Generic WebDAV Setup (`RcloneManager.swift:1275-1283`):**
```swift
func setupWebDAV(remoteName: String, url: String, password: String, username: String = "") async throws {
    var params: [String: String] = [
        "url": url,
        "pass": password
    ]
    if !username.isEmpty {
        params["user"] = username
    }
    try await createRemote(name: remoteName, type: "webdav", parameters: params)
}
```

**Provider Definition (`CloudProvider.swift:21`):**
```swift
case webdav = "webdav"
// ...
case .webdav: return "webdav"  // rcloneType
```

**Usage in MainWindow (`MainWindow.swift:870-871`):**
```swift
case .webdav:
    try await rclone.setupWebDAV(remoteName: rcloneName, url: username, password: password)
```

### Supported Vendor Types

Rclone's WebDAV backend supports these vendor configurations:

| Vendor | Value | Features |
|--------|-------|----------|
| Nextcloud | `nextcloud` | Modified times, SHA1/MD5 hashes, chunked uploads |
| ownCloud | `owncloud` | Modified times, SHA1/MD5 hashes, chunked uploads |
| SharePoint Online | `sharepoint` | MS account auth, special document handling |
| SharePoint NTLM | `sharepoint-ntlm` | Self-hosted/on-premises, NTLM authentication |
| Fastmail Files | `fastmail` | Modified times, SHA1/MD5 hashes |
| rclone serve | `rclone` | For rclone-to-rclone WebDAV |
| Other/Generic | `other` | Basic WebDAV, no vendor optimizations |

### rclone Configuration Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `type` | Yes | Must be `webdav` |
| `url` | Yes | Full WebDAV endpoint URL |
| `vendor` | No | Vendor type for optimizations (default: `other`) |
| `user` | Conditional | Username (required unless using bearer_token) |
| `pass` | Conditional | Password (required unless using bearer_token) |
| `bearer_token` | No | Alternative to user/pass (e.g., Macaroon) |
| `bearer_token_command` | No | Command to fetch bearer token dynamically |
| `headers` | No | Custom HTTP headers |
| `encoding` | No | Character encoding settings |

### Vendor-Specific Features

**When `vendor = nextcloud` or `owncloud`:**
- Modified times supported via `X-OC-Mtime` header
- SHA1 and MD5 hash checksums (version dependent)
- Chunked uploads with resume capability (default 10MB chunks)
- OCS (Open Collaboration Services) API support

**When `vendor = sharepoint`:**
- Microsoft Account OAuth authentication
- Special document handling considerations
- Cannot reliably use size or hash for change detection
- Requires `Depth: 0` for some operations (handled automatically)

**When `vendor = other`:**
- Basic WebDAV operations only
- No modified time support
- No hash support
- May work with any RFC 4918 compliant server

---

## 2. Authentication Requirements

### 2.1 Basic Authentication

The most common authentication method for WebDAV servers.

**Configuration:**
```ini
[mywebdav]
type = webdav
url = https://webdav.example.com/files
user = myusername
pass = mypassword
vendor = other
```

**Security Note:** Basic auth sends credentials in Base64 encoding. Always use HTTPS.

### 2.2 Digest Authentication

More secure than Basic auth - sends hashed credentials.

**Configuration:** Same as Basic auth. Rclone handles digest challenge automatically.

**Note:** Some servers (like oCIS/Infinite Scale) disable Basic auth by default and require OAuth2 or explicitly enabling it via `PROXY_ENABLE_BASIC_AUTH=true`.

### 2.3 Bearer Tokens

Alternative to username/password, useful for OAuth2 flows.

**Configuration:**
```ini
[mywebdav]
type = webdav
url = https://webdav.example.com/files
bearer_token = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
vendor = other
```

**Dynamic Token Fetching:**
```ini
[mywebdav]
type = webdav
url = https://webdav.example.com/files
bearer_token_command = /path/to/token-script.sh
vendor = other
```

**Known Issues:**
- Some Apache-based WebDAV servers have issues with bearer tokens
- SharePoint Online may require specific token format
- Token refresh must be handled externally

### 2.4 Client Certificates (mTLS)

For enhanced security with mutual TLS authentication.

**Configuration:**
Requires placing certificate and key files in rclone config directory:
- `client-cert.pem` - Client certificate
- `client-key.pem` - Client private key (unencrypted)

Then use global rclone flags:
```bash
rclone --client-cert /path/to/cert.pem --client-key /path/to/key.pem ...
```

**Note:** This is a global rclone setting, not WebDAV-specific.

### 2.5 NTLM Authentication (SharePoint On-Premises)

For Windows/SharePoint environments with NTLM.

**Configuration:**
```ini
[sharepoint-onprem]
type = webdav
url = https://sharepoint.company.local/sites/mysite
vendor = sharepoint-ntlm
user = DOMAIN\username
pass = password
```

---

## 3. Common WebDAV Servers

### 3.1 Nextcloud / ownCloud

**Already implemented in CloudSync Ultra** - See separate study (ARCHITECT3_NEXTCLOUD.md).

**WebDAV Endpoint:**
```
https://{server}/remote.php/dav/files/{username}
```

**Key Characteristics:**
- Full WebDAV Class 2 support
- Chunked upload support (10MB default, configurable to 1GB)
- SHA1/MD5 checksums (version dependent)
- App password required when 2FA enabled
- Built on SabreDAV

### 3.2 Apache mod_dav

Standard Apache module providing WebDAV Class 1 and 2 functionality.

**Typical URL Format:**
```
https://server.example.com/webdav/
https://server.example.com/dav/files/
```

**Configuration Notes:**
- Use `vendor = other`
- Requires `mod_dav` and `mod_dav_fs` enabled
- Recommend `mod_auth_digest` for authentication
- Basic auth available but not recommended

**Limitations:**
- No native hash support
- Modified time support depends on configuration
- May need `DAVDepthInfinity on` for deep listings

**rclone Config Example:**
```ini
[apache-dav]
type = webdav
url = https://server.example.com/webdav/
vendor = other
user = davuser
pass = davpassword
```

### 3.3 nginx with WebDAV

nginx has limited WebDAV support via `ngx_http_dav_module`.

**Typical URL Format:**
```
https://server.example.com/webdav/
```

**Configuration Notes:**
- Use `vendor = other`
- Basic module supports: PUT, DELETE, MKCOL, COPY, MOVE
- For full WebDAV support, use `nginx-dav-ext-module`
- nginx 1.3.9+ recommended (fixes chunked transfer encoding issues)

**Known Issues:**
- Older nginx versions have issues with chunked transfer encoding
- OS X Finder and Transmit may create 0-byte files on older versions
- No native locking support without extensions

**rclone Config Example:**
```ini
[nginx-dav]
type = webdav
url = https://server.example.com/webdav/
vendor = other
user = webuser
pass = webpassword
```

### 3.4 Windows IIS WebDAV

Microsoft Internet Information Services with WebDAV Publishing.

**Typical URL Format:**
```
https://server.example.com/webdav/
```

**Configuration Notes:**
- Use `vendor = other` or `sharepoint-ntlm` for Windows auth
- Requires IIS 7.0+ with WebDAV Publishing role installed
- May require `HTTP_AUTHORIZATION` header configuration
- NTLM authentication common in Windows environments

**rclone Config Example:**
```ini
[iis-dav]
type = webdav
url = https://server.example.com/webdav/
vendor = other
user = domain\username
pass = password
```

### 3.5 Box (WebDAV - Deprecated)

**Important:** Box WebDAV support is no longer officially supported.

**Historical URL Format:**
```
https://dav.box.com/dav
```

**Recommendation:** Use rclone's native Box backend (`type = box`) instead of WebDAV for Box integration.

### 3.6 4shared

Ukrainian cloud service with WebDAV support.

**WebDAV URL Format:**
```
https://webdav.4shared.com
```

**Configuration Notes:**
- Use `vendor = other`
- Basic authentication with 4shared credentials
- May have rate limiting

**rclone Config Example:**
```ini
[4shared]
type = webdav
url = https://webdav.4shared.com
vendor = other
user = your@email.com
pass = yourpassword
```

### 3.7 Other WebDAV-Compatible Services

| Service | WebDAV URL | Notes |
|---------|------------|-------|
| Fastmail Files | `https://webdav.fastmail.com/` | Use `vendor = fastmail` |
| pCloud | `https://webdav.pcloud.com/` | Use native pCloud backend |
| Yandex.Disk | `https://webdav.yandex.com/` | Use native Yandex backend |
| HiDrive (Strato) | `https://webdav.hidrive.strato.com/` | Use `vendor = other` |
| DriveHQ | `https://webdav.drivehq.com/` | Use `vendor = other` |
| CloudMe | `https://webdav.cloudme.com/` | Use `vendor = other` |

---

## 4. Known Limitations & Workarounds

### 4.1 No Native Hash Support

**Issue:** Standard WebDAV protocol doesn't define hash/checksum properties.

**Impact:**
- `--checksum` flag unreliable
- Sync uses size + timestamp instead of content hash
- May miss corrupted files during verification

**Vendor Support:**
| Vendor | Hash Support |
|--------|--------------|
| Nextcloud | SHA1, MD5 (version dependent) |
| ownCloud | SHA1, MD5 (version dependent) |
| Fastmail | SHA1, MD5 |
| SharePoint | No (document manipulation) |
| Generic | No |

**Workaround:**
- Rely on size + modified time for sync
- Use rclone crypt layer for integrity verification
- Consider local hash verification post-sync

### 4.2 Modified Time Handling

**Issue:** Standard WebDAV doesn't mandate modified time support.

**Impact:**
- Some servers ignore upload timestamps
- Sync may not detect changes correctly
- `--update` flag may not work as expected

**Vendor Support:**
| Vendor | ModTime Support |
|--------|-----------------|
| Nextcloud | Yes (X-OC-Mtime header) |
| ownCloud | Yes (X-OC-Mtime header) |
| Fastmail | Yes |
| SharePoint | Partial (may modify) |
| Generic | Usually No |

**Workaround:**
- Use `--size-only` for servers without modtime
- Accept potential re-uploads of unchanged files
- Document limitation for users

### 4.3 Special Character Encoding

**Issue:** Different servers handle special characters differently.

**Problematic Characters:**
| Character | Issue |
|-----------|-------|
| `#` | Fragment separator in URLs |
| `%` | URL encoding prefix |
| `:` | Protocol separator |
| `?` | Query string separator |
| `*`, `<`, `>`, `\|` | Windows restrictions |
| Spaces | URL encoding required |

**rclone Encoding (sharepoint-ntlm):**
```
Slash,LtGt,DoubleQuote,Colon,Question,Asterisk,Pipe,Hash,Percent,BackSlash,Del,Ctl,LeftSpace,LeftTilde,RightSpace,RightPeriod,InvalidUtf8
```

**Workaround:**
- Use `--webdav-encoding` to customize
- Avoid problematic characters in filenames
- Add filename validation in UI

### 4.4 Large File Chunked Uploads

**Issue:** Standard WebDAV sends entire files in single request.

**Impact:**
- Large files (>2GB) may fail
- No resume capability for interrupted uploads
- Memory constraints on client/server

**Vendor Support:**
| Vendor | Chunked Upload |
|--------|----------------|
| Nextcloud | Yes (10MB default, up to 1GB) |
| ownCloud | Yes (TUS protocol in oCIS) |
| SharePoint | Via MS Graph API, not WebDAV |
| Generic | Usually No |

**Workarounds:**
- Use rclone's chunker overlay for generic servers
- Configure server for larger request bodies
- Increase chunk size on Nextcloud (up to 1GB recommended)

### 4.5 Directory Listing Depth

**Issue:** Some servers don't support `Depth: 1` header properly.

**Impact:**
- Directory listings may fail or be incomplete
- Performance degradation with `Depth: infinity`

**Workaround:** Rclone automatically retries with `Depth: 0` for SharePoint. For other servers, configure appropriate depth limits.

### 4.6 Connection Timeouts

**Issue:** Long-running operations may timeout.

**Common Causes:**
- Reverse proxy timeouts
- Server-side processing limits
- Large file chunk merging

**Workaround:**
- Use `--timeout 5m` or longer
- Configure proxy/server timeouts appropriately
- Add retry logic for transient failures

---

## 5. Step-by-Step Connection Flow

### Generic WebDAV Connection Flow

```
+-----------------------------------------------------------+
|  Step 1: Select Provider                                   |
|  User selects "WebDAV" from provider list                  |
+-----------------------------------------------------------+
                              |
                              v
+-----------------------------------------------------------+
|  Step 2: Choose Vendor (NEW - Not Currently Implemented)   |
|  +-----------------------------------------------------+  |
|  |  Vendor Type:                                       |  |
|  |  (*) Generic WebDAV                                 |  |
|  |  ( ) Nextcloud  [Link to dedicated wizard]          |  |
|  |  ( ) ownCloud   [Link to dedicated wizard]          |  |
|  |  ( ) SharePoint [Link to dedicated wizard]          |  |
|  |  ( ) Fastmail Files                                 |  |
|  |  ( ) Other                                          |  |
|  +-----------------------------------------------------+  |
+-----------------------------------------------------------+
                              |
                              v
+-----------------------------------------------------------+
|  Step 3: Enter Server URL                                  |
|  +-----------------------------------------------------+  |
|  | WebDAV URL: [https://server.example.com/webdav/  ]  |  |
|  +-----------------------------------------------------+  |
|                                                            |
|  Hint: "Enter the full WebDAV endpoint URL"               |
|  Example: "https://server.example.com/webdav/"            |
+-----------------------------------------------------------+
                              |
                              v
+-----------------------------------------------------------+
|  Step 4: Authentication                                    |
|  +-----------------------------------------------------+  |
|  | Authentication Method:                              |  |
|  | (*) Username & Password                             |  |
|  | ( ) Bearer Token                                    |  |
|  +-----------------------------------------------------+  |
|                                                            |
|  [If Username & Password selected:]                        |
|  +-----------------------------------------------------+  |
|  | Username: [webdavuser                           ]   |  |
|  +-----------------------------------------------------+  |
|  +-----------------------------------------------------+  |
|  | Password: [************************             ]   |  |
|  +-----------------------------------------------------+  |
|                                                            |
|  [If Bearer Token selected:]                               |
|  +-----------------------------------------------------+  |
|  | Bearer Token: [eyJhbGciOi...                    ]   |  |
|  +-----------------------------------------------------+  |
+-----------------------------------------------------------+
                              |
                              v
+-----------------------------------------------------------+
|  Step 5: Test Connection                                   |
|  [Testing connection to server.example.com...]             |
|                                                            |
|  [x] Connected successfully                                |
|  [x] WebDAV endpoint verified                              |
|  [ ] Hash support: Not available                           |
|  [ ] Modified time: Not available                          |
+-----------------------------------------------------------+
                              |
                              v
+-----------------------------------------------------------+
|  Step 6: Name Your Connection                              |
|  +-----------------------------------------------------+  |
|  | Remote Name: [My WebDAV Server                  ]   |  |
|  +-----------------------------------------------------+  |
|                                                            |
|  [Complete Setup]                                          |
+-----------------------------------------------------------+
```

### URL Format Requirements

| Server Type | URL Format |
|-------------|------------|
| Generic WebDAV | `https://server.example.com/webdav/` |
| Nextcloud | `https://cloud.example.com/remote.php/dav/files/{username}` |
| ownCloud | `https://owncloud.example.com/remote.php/dav/files/{username}` |
| SharePoint | Use dedicated SharePoint wizard |
| Apache mod_dav | `https://server.example.com/dav/` |
| nginx WebDAV | `https://server.example.com/webdav/` |

### Credential Handling

**Security Best Practices:**
1. Always use HTTPS for WebDAV connections
2. Store passwords using rclone's encrypted config
3. Recommend app passwords for Nextcloud/ownCloud with 2FA
4. Bearer tokens should be refreshed before expiry

### SSL/TLS Considerations

| Requirement | Recommendation |
|-------------|----------------|
| Minimum TLS | TLSv1.2 |
| Certificate | Valid CA-signed certificate |
| Self-signed | Requires explicit trust (security risk) |
| mTLS | Supported via global rclone flags |

**Self-Signed Certificate Handling:**
```bash
# Not recommended - disables certificate verification
rclone --no-check-certificate ...
```

---

## 6. Implementation Recommendation

### Difficulty Rating: **EASY**

### Rationale

1. **Already Implemented:** Basic WebDAV support exists in `RcloneManager.setupWebDAV()`
2. **Standard Protocol:** Well-supported by rclone
3. **No OAuth Required:** Username/password authentication is straightforward
4. **Vendor Support:** Rclone handles vendor-specific optimizations automatically

### Current Implementation Gaps

| Gap | Priority | Effort |
|-----|----------|--------|
| No vendor selection in UI | Medium | Low |
| No bearer token option | Low | Low |
| URL passed as "username" field | Medium | Low |
| No connection capabilities display | Low | Medium |

### Recommended Code Changes

#### 1. Add Vendor Parameter to setupWebDAV

Update `RcloneManager.swift`:
```swift
func setupWebDAV(
    remoteName: String,
    url: String,
    username: String = "",
    password: String = "",
    vendor: String = "other",
    bearerToken: String? = nil
) async throws {
    var params: [String: String] = [
        "url": url,
        "vendor": vendor
    ]

    if let token = bearerToken, !token.isEmpty {
        params["bearer_token"] = token
    } else {
        if !username.isEmpty {
            params["user"] = username
        }
        if !password.isEmpty {
            params["pass"] = password
        }
    }

    try await createRemote(name: remoteName, type: "webdav", parameters: params)
}
```

#### 2. Fix MainWindow WebDAV Setup Call

Current problematic code (`MainWindow.swift:870-871`):
```swift
case .webdav:
    try await rclone.setupWebDAV(remoteName: rcloneName, url: username, password: password)
```

The URL is incorrectly passed via the `username` field. This should be updated when adding a proper WebDAV wizard.

#### 3. Add WebDAV Vendor Enum (Optional)

```swift
enum WebDAVVendor: String, CaseIterable {
    case other = "other"
    case nextcloud = "nextcloud"
    case owncloud = "owncloud"
    case sharepoint = "sharepoint"
    case sharepointNTLM = "sharepoint-ntlm"
    case fastmail = "fastmail"
    case rclone = "rclone"

    var displayName: String {
        switch self {
        case .other: return "Generic WebDAV"
        case .nextcloud: return "Nextcloud"
        case .owncloud: return "ownCloud"
        case .sharepoint: return "SharePoint Online"
        case .sharepointNTLM: return "SharePoint (NTLM)"
        case .fastmail: return "Fastmail Files"
        case .rclone: return "Rclone Server"
        }
    }

    var supportsHashes: Bool {
        switch self {
        case .nextcloud, .owncloud, .fastmail: return true
        default: return false
        }
    }

    var supportsModTime: Bool {
        switch self {
        case .nextcloud, .owncloud, .fastmail: return true
        default: return false
        }
    }
}
```

#### 4. No Changes Required to CloudProvider.swift

WebDAV is already defined with:
- `rcloneType = "webdav"`
- `iconName = "globe"`
- `brandColor = Color.gray`

### Generic vs Vendor-Specific Approach

**Recommendation:** Keep generic WebDAV as a catch-all option while maintaining dedicated providers for major vendors.

| Provider | Approach | Reason |
|----------|----------|--------|
| Nextcloud | Dedicated provider | URL construction, app password guidance |
| ownCloud | Dedicated provider | URL construction, app password guidance |
| SharePoint | Dedicated provider | OAuth complexity, enterprise features |
| Generic WebDAV | Use WebDAV provider | Flexibility for arbitrary servers |

This allows:
- Optimized UX for popular vendors
- Flexibility for power users
- Proper vendor parameter setting

---

## 7. Testing Recommendations

### Manual Testing Checklist

- [ ] Connect to generic WebDAV server (Apache mod_dav)
- [ ] Connect to Nextcloud via generic WebDAV
- [ ] Connect to ownCloud via generic WebDAV
- [ ] Test with username/password authentication
- [ ] Test with bearer token authentication (if implemented)
- [ ] Upload large file (>100MB)
- [ ] Upload many small files
- [ ] Sync bidirectional
- [ ] Test with special characters in filenames
- [ ] Test connection over HTTP (should warn/block)
- [ ] Test invalid credentials handling
- [ ] Test invalid URL handling
- [ ] Test self-signed certificate handling

### Recommended Test Environments

1. **Apache mod_dav** - Standard WebDAV server
2. **nginx with ngx_http_dav_module** - Minimal WebDAV
3. **Nextcloud** (via generic WebDAV) - Full-featured
4. **Windows IIS WebDAV** - Enterprise environment
5. **rclone serve webdav** - Known-good reference implementation

---

## 8. References

### Official Documentation
- [rclone WebDAV Backend](https://rclone.org/webdav/)
- [rclone serve webdav](https://rclone.org/commands/rclone_serve_webdav/)
- [Apache mod_dav](https://httpd.apache.org/docs/current/mod/mod_dav.html)
- [WebDAV RFC 4918](https://tools.ietf.org/html/rfc4918)

### Community Resources
- [rclone Forum - WebDAV Discussions](https://forum.rclone.org/t/overcoming-webdavs-limitations/44959)
- [rclone GitHub - WebDAV Backend Source](https://github.com/rclone/rclone/blob/master/backend/webdav/webdav.go)
- [Awesome WebDAV - Curated List](https://github.com/fstanis/awesome-webdav)
- [sabre/dav - WebDAV Webservers](https://sabre.io/dav/webservers/)

### Related CloudSync Ultra Files
- `/Users/antti/claude/CloudSyncApp/RcloneManager.swift` - WebDAV setup functions
- `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift` - Provider definitions
- `/Users/antti/claude/CloudSyncApp/Views/MainWindow.swift` - Current WebDAV invocation

### Related Integration Studies
- `ARCHITECT3_NEXTCLOUD.md` - Nextcloud (uses WebDAV backend)
- `ARCHITECT1_SHAREPOINT.md` - SharePoint (uses OneDrive backend, not WebDAV)

---

## Conclusion

WebDAV integration for CloudSync Ultra is fundamentally complete. The `setupWebDAV()` method in `RcloneManager.swift` correctly creates WebDAV remotes with rclone. The main improvements needed are:

1. **UI Enhancement:** Add vendor selection dropdown (Easy)
2. **URL Handling:** Fix the current workaround where URL is passed as username (Easy)
3. **Bearer Token Support:** Add optional bearer token authentication (Easy)
4. **Documentation:** Help text for common WebDAV servers (Easy)

The WebDAV backend serves as a fallback for any server implementing the WebDAV protocol, making CloudSync Ultra compatible with a wide range of self-hosted and commercial file servers beyond the explicitly supported providers.

**Final Assessment:** Ready for enhancement with minimal code changes. Core functionality works today.

---

*End of Integration Study*
