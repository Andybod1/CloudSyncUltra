# Integration Study #141: Seafile

**Architect:** ARCH-1
**Date:** 2026-01-18
**Status:** Complete

## Executive Summary

Seafile is a self-hosted file sync and share solution that is already partially integrated into CloudSync Ultra. The rclone backend (`seafile`) provides robust support for authentication, library management, and encrypted libraries. This study identifies gaps in the current implementation and recommends enhancements for a complete wizard flow.

---

## 1. Current Implementation Status

### CloudProviderType.swift
- **Provider defined:** Yes (`case seafile = "seafile"`)
- **Display name:** "Seafile"
- **Icon:** `server.rack`
- **Brand color:** `#009E6B` (Seafile Green)
- **rclone type:** `seafile`
- **OAuth required:** No (credential-based)

### RcloneManager.swift
- **Setup function exists:** Yes
```swift
func setupSeafile(remoteName: String, url: String, username: String, password: String, library: String? = nil, authToken: String? = nil) async throws
```
- **Parameters supported:**
  - `url` - Server URL (required)
  - `user` - Username/email (required)
  - `pass` - Password (required)
  - `library` - Specific library name (optional)
  - `auth_token` - Pre-generated auth token (optional)

### TestConnectionStep.swift
- **Seafile case:** NOT IMPLEMENTED (falls through to default error)
- **Gap:** Seafile is missing from the `configureRemoteWithRclone()` switch statement

### ConfigureSettingsStep.swift
- **Seafile-specific UI:** None
- **Gap:** No instructions or specialized fields for Seafile

---

## 2. Seafile rclone Backend Analysis

### Authentication Methods

| Method | Support | Notes |
|--------|---------|-------|
| Username/Password | Full | Standard email + password |
| 2FA (TOTP) | Full | Set `2fa = true`, provide code during setup |
| Auth Token | Full | Via `--seafile-auth-token` parameter |
| Library API Token | NOT Supported | rclone explicitly does not support this |

### Configuration Parameters

| Parameter | rclone Flag | Required | Purpose |
|-----------|-------------|----------|---------|
| Server URL | `--seafile-url` | Yes | Full URL to Seafile server |
| Username | `--seafile-user` | Yes | Email or username |
| Password | `--seafile-pass` | Yes | Account password (obscured) |
| 2FA Enabled | `--seafile-2fa` | No | Boolean, enables 2FA prompt |
| Library | `--seafile-library` | No | Specific library to access |
| Library Key | `--seafile-library-key` | No | Password for encrypted library |
| Create Library | `--seafile-create-library` | No | Auto-create missing libraries |

### Configuration Modes

1. **Root Mode** (Recommended for general use)
   - No library specified in config
   - Access path: `remote:LibraryName/path/to/file`
   - Pros: Access all non-encrypted libraries from one remote
   - Cons: Cannot access encrypted libraries

2. **Library Mode** (Recommended for encrypted libraries)
   - Specific library in config
   - Access path: `remote:path/to/file`
   - Pros: Faster, works with encrypted libraries
   - Cons: One remote per library

### Server URL Format

Valid formats:
- `https://cloud.seafile.com` (Standard)
- `https://myserver.example.org:8082` (Custom port)
- `http://192.168.1.100` (Local, not recommended)

---

## 3. Features Analysis

### Library-Based Organization
- Seafile organizes files into "Libraries" (similar to shares/folders)
- Each library can have independent permissions and encryption
- Users may have multiple libraries (personal, shared, team)

### Encrypted Libraries
- Seafile supports client-side encrypted libraries
- Encryption password never sent to server
- rclone requires library password (`library_key`) to access
- **Must use Library Mode** for encrypted libraries

### Version History
- Seafile maintains file version history
- Version management via web interface
- rclone does not expose version management

### File Locking (Seafile 7+)
- Seafile supports exclusive file locking
- Not exposed through rclone backend
- Potential future enhancement area

### Version Compatibility
- Seafile 6.x, 7.x, 8.x, 9.x all supported
- Seafile 7+ enables `--fast-list` for efficiency

---

## 4. Recommended Wizard Flow

### Step 1: Choose Provider
- Standard provider selection (already working)

### Step 2: Configure Settings (Needs Enhancement)

**Required Fields:**
1. **Server URL** - With validation
   - Placeholder: `https://cloud.seafile.com`
   - Validation: Must be valid HTTPS URL (warn on HTTP)

2. **Username/Email**
   - Placeholder: `user@example.com`

3. **Password**
   - SecureField

**Optional Fields:**
4. **2FA Enabled** - Toggle
   - When enabled, show 2FA code field
   - Instructions: "Enter the code from your authenticator app"

5. **Library Selection** - Picker/TextField
   - Option A: "Access all libraries" (Root Mode)
   - Option B: "Select specific library" (Library Mode)
   - If Library Mode selected, fetch available libraries via API

6. **Library Password** - SecureField (conditional)
   - Only shown if specific library is selected
   - Label: "Library password (for encrypted libraries)"

### Step 3: Test Connection
- Configure rclone remote
- Test with `rclone lsd remote:` (Root Mode) or `rclone lsd remote:/` (Library Mode)
- Display available libraries on success

### Step 4: Success
- Standard success step

---

## 5. Implementation Recommendations

### 5.1 Update TestConnectionStep.swift

Add Seafile case to `configureRemoteWithRclone()`:

```swift
case .seafile:
    try await rclone.setupSeafile(
        remoteName: rcloneName,
        url: serverURL,      // New field needed
        username: username,
        password: password,
        library: selectedLibrary,  // New field needed
        authToken: nil
    )
```

### 5.2 Update ConfigureSettingsStep.swift

Add Seafile-specific configuration section:
- Server URL field with validation
- 2FA toggle and code field
- Library selection (Root/Library mode)
- Library password field for encrypted libraries

### 5.3 Update ProviderConnectionWizardState

Add new state properties:
```swift
// Seafile-specific
@Published var serverURL = ""
@Published var use2FA = false
@Published var selectedLibrary: String?
@Published var libraryPassword = ""
```

### 5.4 Library Discovery API (Future Enhancement)

For improved UX, implement library discovery:
```bash
rclone lsd seafile: --seafile-url="https://server" --seafile-user="user" --seafile-pass="pass"
```

This returns available libraries that can populate a picker.

---

## 6. Self-Hosted Configuration Requirements

### Minimum Server Requirements
- Seafile Server 6.x or higher
- HTTPS enabled (strongly recommended)
- Network accessible from client

### User Requirements
- Valid Seafile account
- Account password (not app-specific password)
- 2FA app configured (if 2FA enabled)
- Library password (if accessing encrypted libraries)

### Firewall/Network
- Port 443 (HTTPS) or custom port
- WebSocket support for real-time sync (optional)

---

## 7. Encrypted Library Handling

### Detection
- Cannot detect if library is encrypted without attempting access
- Failed access with "Wrong password" indicates encrypted library

### Configuration Approach
1. Initially configure without library password
2. If access fails with password error, prompt for library password
3. Store library password in Keychain (separate from account password)

### Security Considerations
- Library password is zero-knowledge (server never sees it)
- Store encrypted in macOS Keychain
- Consider password memory option (don't persist)

---

## 8. Error Handling

### Common Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| "bad status code: 400" | Invalid credentials | Re-enter username/password |
| "bad status code: 403" | Library access denied | Check library permissions |
| "library not found" | Wrong library name | Verify library exists |
| "wrong password" | Encrypted library | Enter library password |
| "2FA required" | 2FA enabled | Provide 2FA code |
| Connection timeout | Server unreachable | Check URL and network |

---

## 9. Testing Checklist

- [ ] Connect to Seafile Cloud (cloud.seafile.com)
- [ ] Connect to self-hosted Seafile server
- [ ] Access non-encrypted library (Root Mode)
- [ ] Access non-encrypted library (Library Mode)
- [ ] Access encrypted library with password
- [ ] 2FA authentication flow
- [ ] List files in library
- [ ] Upload file to library
- [ ] Download file from library
- [ ] Handle connection errors gracefully

---

## 10. Priority Actions

### P0 - Critical (Blocks Usage)
1. Add Seafile case to TestConnectionStep.swift
2. Add server URL field to wizard

### P1 - Important (Improved UX)
3. Add 2FA toggle and code field
4. Add library selection option
5. Add library password field for encrypted libraries

### P2 - Enhancement (Polish)
6. Library discovery/picker
7. Server URL validation with helpful errors
8. Encrypted library auto-detection

---

## References

- rclone Seafile Documentation: https://rclone.org/seafile/
- Seafile Official Documentation: https://manual.seafile.com/
- Seafile API Documentation: https://download.seafile.com/published/web-api/home.md

---

## Appendix: Sample rclone Configuration

### Root Mode (All Libraries)
```ini
[myseafile]
type = seafile
url = https://cloud.seafile.com
user = user@example.com
pass = *** ENCRYPTED ***
```

### Library Mode (Single Library)
```ini
[myseafile-docs]
type = seafile
url = https://cloud.seafile.com
user = user@example.com
pass = *** ENCRYPTED ***
library = My Documents
```

### Library Mode with Encryption
```ini
[myseafile-private]
type = seafile
url = https://cloud.seafile.com
user = user@example.com
pass = *** ENCRYPTED ***
library = Private Encrypted
library_key = *** ENCRYPTED ***
```

### With 2FA Enabled
```ini
[myseafile-2fa]
type = seafile
url = https://cloud.seafile.com
user = user@example.com
pass = *** ENCRYPTED ***
2fa = true
```
