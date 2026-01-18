# Integration Study: FTP (File Transfer Protocol)

**GitHub Issue:** #144
**Sprint:** v2.0.35
**Author:** Architect-4
**Date:** 2026-01-17
**Status:** Research Complete

---

## Executive Summary

FTP (File Transfer Protocol) is one of the oldest network protocols for file transfer, dating back to 1971. While largely superseded by more secure alternatives like SFTP, FTP remains relevant for legacy systems, shared hosting environments, embedded devices, and internal file servers. Rclone provides a mature FTP backend with support for plain FTP, FTPS (FTP over TLS), and various server quirks.

**Important Security Note:** Plain FTP transmits credentials and data in cleartext. It should only be used on trusted networks or when FTPS (FTP over TLS) is enabled.

**Implementation Difficulty:** EASY - FTP is already fully implemented in CloudSync Ultra.

---

## 1. rclone Backend Details

### Backend Type

FTP uses a **native rclone backend** (`type = ftp`). This is a straightforward implementation for FTP server connectivity.

### Configuration Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `host` | string | **Yes** | - | FTP host to connect to |
| `user` | string | No | $USER | FTP username |
| `port` | int | No | 21 | FTP port number |
| `pass` | string | No | - | FTP password (obscured) |
| `tls` | bool | No | false | Use Implicit FTPS (port 990) |
| `explicit_tls` | bool | No | false | Use Explicit FTPS (STARTTLS) |
| `concurrency` | int | No | 0 | Max simultaneous connections |
| `no_check_certificate` | bool | No | false | Skip TLS certificate verification |
| `disable_epsv` | bool | No | false | Disable Extended Passive mode |
| `disable_mlsd` | bool | No | false | Disable MLSD command |
| `disable_utf8` | bool | No | false | Disable UTF-8 encoding |
| `writing_mdtm` | bool | No | false | Use MDTM to set modification time |
| `force_list_hidden` | bool | No | false | Use LIST -a for hidden files |
| `idle_timeout` | Duration | No | 1m | Idle connection timeout |
| `close_timeout` | Duration | No | 1m | Max time to wait for close response |
| `tls_cache_size` | int | No | 32 | TLS session cache size |
| `disable_tls13` | bool | No | false | Disable TLS 1.3 |
| `shut_timeout` | Duration | No | 1m | Data connection close timeout |
| `ask_password` | bool | No | false | Prompt for password at runtime |
| `socks_proxy` | string | No | - | SOCKS5 proxy host |
| `http_proxy` | string | No | - | HTTP CONNECT proxy URL |
| `encoding` | Encoding | No | Slash,Del,Ctl,RightSpace,Dot | Character encoding settings |

### Example Configuration

```ini
[my-ftp]
type = ftp
host = ftp.example.com
user = ftpuser
pass = *** ENCRYPTED ***
port = 21
```

### With Explicit FTPS (Recommended)

```ini
[my-ftps]
type = ftp
host = ftp.example.com
user = ftpuser
pass = *** ENCRYPTED ***
port = 21
explicit_tls = true
```

### Current CloudSync Ultra Implementation

FTP is **already fully defined** in the codebase:

**File: `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`**
- `CloudProviderType.ftp` exists (line 23)
- `rcloneType` returns `"ftp"` (line 261)
- Display name: "FTP" (line 82)
- Icon: `network` (line 142)
- Brand color: `Color.orange` (line 202)
- Default rclone name: `"ftp"` (line 320)

**File: `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`**
- `setupFTP()` function exists (lines 1304-1314)
- Supports: host, password, user, port
- Missing: FTPS options (tls, explicit_tls)

**File: `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift`**
- FTP connection test implemented (lines 307-308)

**File: `/Users/antti/claude/CloudSyncApp/Models/TransferOptimizer.swift`**
- Chunk size: 32MB (line 54-55) - grouped with SFTP/WebDAV

---

## 2. Authentication Requirements

### 2.1 Username/Password Authentication

Standard FTP authentication using username and password.

**Configuration:**
```ini
[my-ftp]
type = ftp
host = ftp.example.com
user = myusername
pass = mypassword
```

**Security Warning:** Plain FTP transmits credentials in cleartext. Anyone on the network can intercept the password.

**Current Status:** Supported in CloudSync Ultra

### 2.2 Anonymous FTP

Some FTP servers allow anonymous access for public file downloads.

**Configuration:**
```ini
[anon-ftp]
type = ftp
host = ftp.example.com
user = anonymous
pass = user@example.com
```

**Convention:** Anonymous FTP typically uses:
- Username: `anonymous` or `ftp`
- Password: User's email address (convention, not enforced)

**Current Status:** Works with existing implementation (user can enter "anonymous")

### 2.3 FTP over TLS (FTPS)

FTPS adds TLS encryption to FTP, protecting both credentials and data.

#### Explicit FTPS (STARTTLS) - Port 21

The client connects on standard port 21 and upgrades to TLS using the `AUTH TLS` command.

**Configuration:**
```ini
[explicit-ftps]
type = ftp
host = ftp.example.com
user = ftpuser
pass = *** ENCRYPTED ***
port = 21
explicit_tls = true
```

**Advantages:**
- Works on standard FTP port (21)
- Compatible with firewalls expecting FTP traffic
- Client chooses whether to use encryption

**Current Status:** NOT supported in CloudSync Ultra setup wizard

#### Implicit FTPS - Port 990

The client connects directly using TLS on port 990.

**Configuration:**
```ini
[implicit-ftps]
type = ftp
host = ftp.example.com
user = ftpuser
pass = *** ENCRYPTED ***
port = 990
tls = true
```

**Advantages:**
- Encryption from first byte
- Simpler handshake process

**Disadvantages:**
- Requires dedicated port (990)
- Less common than explicit FTPS

**Current Status:** NOT supported in CloudSync Ultra setup wizard

---

## 3. Protocol Variants

### 3.1 Plain FTP (Insecure)

**Ports:** 21 (control), 20 (data in active mode), ephemeral (data in passive mode)

**Characteristics:**
- No encryption
- Credentials sent in cleartext
- Data sent in cleartext
- Original protocol from 1971

**When Acceptable:**
- Local network only (no internet exposure)
- Non-sensitive data transfer
- Legacy systems that don't support FTPS
- Testing/development environments

**When NOT Acceptable:**
- Over the internet
- Transferring sensitive data
- Production environments with compliance requirements

### 3.2 Explicit FTPS (AUTH TLS)

**Port:** 21 (control), negotiated ephemeral (data)

**How It Works:**
1. Client connects to port 21 (unencrypted)
2. Client sends `AUTH TLS` command
3. Server responds with 234 code
4. TLS handshake occurs
5. All subsequent communication encrypted

**Characteristics:**
- Most widely supported FTPS variant
- Firewall-friendly (uses standard port)
- Client can detect if server doesn't support TLS
- Recommended for most use cases

### 3.3 Implicit FTPS

**Port:** 990 (control), 989 (data)

**How It Works:**
1. Client initiates TLS connection to port 990
2. TLS handshake occurs immediately
3. FTP protocol runs over established TLS connection

**Characteristics:**
- Encryption from first byte
- Uses dedicated ports
- Less common than explicit FTPS
- Some older servers only support this mode

### 3.4 Active vs Passive Mode

#### Active Mode

```
Client                           Server
  |---- CONNECT to port 21 ------>|
  |<--- 220 Welcome --------------|
  |---- USER ftpuser ------------>|
  |<--- 331 Password required ----|
  |---- PASS ********** --------->|
  |<--- 230 Logged in ------------|
  |---- PORT 192,168,1,100,39,40->|  (Client opens port for data)
  |<--- 200 OK -------------------|
  |---- RETR file.txt ----------->|
  |<--- 150 Opening data ---------|
  |<--- DATA connection on port --|  (Server connects to client)
  |<--- File data ----------------|
  |<--- 226 Transfer complete ----|
```

**Characteristics:**
- Client opens a port for server to connect back
- **Often blocked by firewalls/NAT**
- Requires client firewall configuration
- rclone supports via EPSV command

#### Passive Mode (Recommended)

```
Client                           Server
  |---- CONNECT to port 21 ------>|
  |<--- 220 Welcome --------------|
  |---- USER ftpuser ------------>|
  |<--- 331 Password required ----|
  |---- PASS ********** --------->|
  |<--- 230 Logged in ------------|
  |---- PASV -------------------->|  (Request passive mode)
  |<--- 227 (192,168,1,1,39,40) --|  (Server provides port)
  |---- CONNECT to data port ---->|  (Client connects to server)
  |---- RETR file.txt ----------->|
  |<--- 150 Opening data ---------|
  |<--- File data ----------------|
  |<--- 226 Transfer complete ----|
```

**Characteristics:**
- Server opens port, client connects
- Works through most firewalls/NAT
- **Recommended for most deployments**
- Extended Passive (EPSV) preferred for IPv6

**rclone Configuration:**
```ini
# Disable EPSV if server has issues
disable_epsv = true
```

---

## 4. Common Use Cases

### 4.1 Legacy Systems

**Scenario:** Old systems that predate SFTP adoption.

**Examples:**
- Mainframe file transfers (MVS, AS/400)
- Older industrial control systems
- Legacy business applications
- Vintage computing enthusiasts

**Configuration:**
```ini
[legacy-mainframe]
type = ftp
host = mainframe.company.local
user = USERID
pass = *** ENCRYPTED ***
encoding = Ctl,LeftPeriod,Slash  # May need special encoding
```

**Considerations:**
- May have non-standard directory listing formats
- Character encoding issues possible
- Use `disable_mlsd = true` if MLSD not supported

### 4.2 Shared Web Hosting

**Scenario:** Most web hosting providers still offer FTP for file upload.

**Common Providers:**
- Bluehost, HostGator, GoDaddy
- SiteGround, DreamHost
- A2 Hosting, InMotion
- cPanel/Plesk-based hosts

**Configuration:**
```ini
[webhost]
type = ftp
host = ftp.mywebsite.com
user = myusername@mywebsite.com
pass = *** ENCRYPTED ***
explicit_tls = true  # Most hosts support this now
```

**Considerations:**
- Most modern hosts support FTPS (explicit TLS)
- Port is typically 21
- May have connection limits
- Some hosts allow SFTP on port 22 as alternative

### 4.3 Embedded Devices

**Scenario:** Network devices, IoT, and embedded systems with FTP servers.

**Examples:**
- IP cameras (firmware updates, log retrieval)
- Network-attached storage (basic models)
- Printers and multifunction devices
- Industrial equipment (PLCs, HMIs)
- Security DVRs/NVRs

**Configuration:**
```ini
[ip-camera]
type = ftp
host = 192.168.1.50
user = admin
pass = *** ENCRYPTED ***
port = 21
disable_mlsd = true  # Many embedded systems don't support MLSD
```

**Considerations:**
- Often limited FTP implementations
- May not support MLSD (use `disable_mlsd = true`)
- May not support UTF-8 (use `disable_utf8 = true`)
- Often no FTPS support
- Use on isolated/trusted networks only

### 4.4 Internal File Servers

**Scenario:** Corporate file servers using FTP for internal transfers.

**Examples:**
- Departmental file drops
- Batch processing systems
- EDI (Electronic Data Interchange) endpoints
- Internal software distribution

**Configuration:**
```ini
[internal-fileserver]
type = ftp
host = fileserver.company.local
user = svc_ftpuser
pass = *** ENCRYPTED ***
explicit_tls = true
```

**Considerations:**
- Should use FTPS even on internal networks
- May integrate with Active Directory
- Consider connection pooling limits
- Often behind corporate firewalls

---

## 5. Known Limitations & Workarounds

### 5.1 No Encryption by Default (Security Risk)

**Issue:** Plain FTP transmits everything in cleartext.

**Risks:**
| Risk | Impact |
|------|--------|
| Credential theft | Passwords visible on network |
| Data interception | Files readable in transit |
| Session hijacking | Connection can be taken over |
| Man-in-the-middle | Data can be modified |

**Workarounds:**
1. **Use FTPS (explicit_tls = true)** - Recommended
2. **Use VPN** - Encrypt network layer
3. **Use SFTP instead** - Different protocol, SSH-based
4. **Restrict to local network** - If FTP is unavoidable

**CloudSync Ultra Recommendation:** Display security warning for plain FTP connections.

### 5.2 No Native Hash Support

**Issue:** FTP protocol has no checksum/hash commands.

**Impact:**
- Cannot verify file integrity via protocol
- Sync relies on size and timestamp only
- `--checksum` flag not effective

**Workarounds:**
| Approach | Description |
|----------|-------------|
| Trust size+time | Default rclone behavior |
| Post-transfer verify | Run hash check after copy |
| Use rclone crypt | Adds integrity via encryption |
| Accept limitation | For non-critical data |

**Comparison with SFTP:** SFTP can execute remote hash commands if shell access is available. FTP has no such capability.

### 5.3 Directory Listing Variations

**Issue:** Different FTP servers use different directory listing formats.

**Common Formats:**
| Format | Example |
|--------|---------|
| Unix-style | `-rw-r--r-- 1 user group 1234 Jan 17 12:00 file.txt` |
| Windows-style | `01-17-26  12:00PM     1234 file.txt` |
| MLSD (modern) | `size=1234;modify=20260117120000; file.txt` |

**rclone Handling:**
- MLSD preferred (modern, standardized)
- Falls back to parsing LIST output
- Some servers have quirks

**Configuration Options:**
```ini
# Disable MLSD if server returns incorrect data
disable_mlsd = true

# Force hidden file listing
force_list_hidden = true
```

### 5.4 Firewall/NAT Issues with Active Mode

**Issue:** Active mode requires server to connect back to client.

**Problem:**
- NAT translates client's internal IP
- Firewall may block incoming data connection
- FTP-aware firewalls (ALG) can help but are complex

**Workaround:** Use Passive Mode (PASV/EPSV) - this is rclone's default.

**If Server Only Supports Active Mode:**
- Configure firewall to allow FTP data connections
- May need FTP ALG on router
- Consider switching servers

### 5.5 Server-Specific Quirks

**Common Issues and Solutions:**

| Server | Issue | Solution |
|--------|-------|----------|
| ProFTPd | `*` in filenames | Use encoding: `Asterisk,Ctl,Dot,Slash` |
| PureFTPd | `[]` in filenames | Use encoding: `BackSlash,Ctl,Del,Dot,RightSpace,Slash,SquareBracket` |
| VsFTPd | Leading dots | Use encoding: `Ctl,LeftPeriod,Slash` |
| VsFTPd | MDTM after write | Use `writing_mdtm = true` |
| IIS FTP | Various | May need NTLM auth |

### 5.6 Connection Limits

**Issue:** Some servers limit concurrent connections.

**Configuration:**
```ini
# Limit concurrent connections
concurrency = 4
```

**Warning from rclone docs:** Setting concurrency can cause deadlocks. Use carefully.

**Recommendation:** For servers with known limits:
```bash
rclone sync source: ftp: --transfers 2 --checkers 2
```

---

## 6. Security Considerations

### 6.1 When Plain FTP is Acceptable

| Scenario | Acceptable? | Reason |
|----------|-------------|--------|
| Public downloads (anonymous) | Yes | Data already public |
| Isolated lab network | Yes | No exposure to attacks |
| Legacy system, no FTPS option | Acceptable | Use VPN as mitigation |
| Air-gapped network | Yes | No network access |
| Testing/development | Yes | Non-production |

### 6.2 When to Require FTPS

| Scenario | FTPS Required? | Reason |
|----------|----------------|--------|
| Any internet-facing transfer | **Yes** | Credentials exposed |
| Sensitive business data | **Yes** | Data confidentiality |
| Compliance requirements (PCI, HIPAA) | **Yes** | Regulatory mandate |
| Corporate network | Recommended | Defense in depth |
| Personal files | Recommended | Privacy |

### 6.3 Credential Handling in CloudSync Ultra

**Current Implementation:**
- Password passed to rclone's obscured storage
- rclone config stores obscured (not encrypted) passwords

**Security Recommendations:**
1. **Warn users about plain FTP risks**
2. **Default to FTPS when available**
3. **Store credentials in macOS Keychain** (future enhancement)
4. **Never log passwords**

### 6.4 TLS Certificate Handling

| Option | Security | Use Case |
|--------|----------|----------|
| Verify certificate | High | Production, trusted CAs |
| Skip verification | Low | Self-signed certs, testing |

**Configuration for Self-Signed Certificates:**
```ini
no_check_certificate = true
```

**Warning:** Only use `no_check_certificate` when you control the server and understand the risks.

---

## 7. Difference from SFTP

FTP and SFTP are often confused but are completely different protocols:

| Aspect | FTP | SFTP |
|--------|-----|------|
| Full Name | File Transfer Protocol | SSH File Transfer Protocol |
| Base Protocol | FTP (RFC 959) | SSH (RFC 4251) |
| Default Port | 21 (control), 20/ephemeral (data) | 22 |
| Encryption | None (FTPS adds TLS) | Always encrypted (SSH) |
| Authentication | Username/password | Password, SSH keys, agent |
| Connection Ports | Multiple (control + data) | Single port (22) |
| Firewall Friendly | Problematic (multi-port) | Yes (single port) |
| Hash Support | No | Possible via shell commands |
| Implementation | Dedicated FTP servers | SSH server + SFTP subsystem |
| Year Introduced | 1971 | 1997 (SSH), 2001 (SFTP v3) |

### When to Use FTP vs SFTP

| Use FTP When: | Use SFTP When: |
|---------------|----------------|
| Server only supports FTP | SSH access available |
| Legacy system requirement | Security is priority |
| Simple embedded device | Modern server/NAS |
| Anonymous public downloads | Need SSH key auth |
| Web hosting (if SFTP unavailable) | Have Unix/Linux server |

---

## 8. Implementation Recommendation

### Difficulty Rating: **EASY**

**Rationale:**
1. FTP is already defined in `CloudProviderType` enum
2. `setupFTP()` function exists and works
3. Connection test is implemented
4. Only missing FTPS options in wizard

### Current Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| Basic FTP (host, user, pass, port) | Implemented | Works today |
| FTPS (Explicit TLS) | Backend ready | Not exposed in UI |
| FTPS (Implicit TLS) | Backend ready | Not exposed in UI |
| Connection testing | Implemented | Works |
| Transfer optimization | Implemented | 32MB chunks |

### Code Changes Needed

#### Phase 1: Add FTPS Support to Setup (Easy)

Update `RcloneManager.swift`:

```swift
func setupFTP(
    remoteName: String,
    host: String,
    password: String,
    user: String = "",
    port: String = "21",
    useTLS: Bool = false,          // Explicit TLS (STARTTLS)
    useImplicitTLS: Bool = false,  // Implicit TLS (port 990)
    skipCertVerify: Bool = false
) async throws {
    var params: [String: String] = [
        "host": host,
        "pass": password,
        "port": port
    ]
    if !user.isEmpty {
        params["user"] = user
    }
    if useTLS {
        params["explicit_tls"] = "true"
    }
    if useImplicitTLS {
        params["tls"] = "true"
    }
    if skipCertVerify {
        params["no_check_certificate"] = "true"
    }
    try await createRemote(name: remoteName, type: "ftp", parameters: params)
}
```

#### Phase 2: Add Security Warning in UI (Easy)

Display warning when plain FTP is selected:

```swift
// In FTP configuration view
if !useFTPS {
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("Security Warning")
                .font(.headline)
                .foregroundColor(.orange)
        }
        Text("Plain FTP transmits your password and files without encryption. Anyone on the network can intercept them.")
            .font(.caption)
            .foregroundColor(.secondary)
        Text("Enable FTPS or use SFTP for secure transfers.")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
    .background(Color.orange.opacity(0.1))
    .cornerRadius(8)
}
```

#### Phase 3: Enhanced Configuration UI (Optional)

Add FTPS options to the FTP wizard:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| Host | TextField | - | FTP server hostname |
| Port | TextField | 21 | FTP port |
| Username | TextField | - | FTP username |
| Password | SecureField | - | FTP password |
| Use FTPS | Toggle | true | Enable TLS encryption |
| TLS Mode | Picker | Explicit | Explicit (STARTTLS) or Implicit |
| Skip Cert Verify | Toggle | false | For self-signed certs |

### Testing Checklist

#### Basic Functionality
- [ ] Connect to plain FTP server
- [ ] Connect with username/password
- [ ] Connect with anonymous user
- [ ] List files and folders
- [ ] Upload file
- [ ] Download file
- [ ] Delete file
- [ ] Create folder

#### FTPS Testing
- [ ] Connect with explicit TLS
- [ ] Connect with implicit TLS (port 990)
- [ ] Test with self-signed certificate (skip verify)
- [ ] Test with valid certificate

#### Edge Cases
- [ ] Handle connection refused
- [ ] Handle wrong credentials
- [ ] Handle server timeout
- [ ] Handle passive mode
- [ ] Handle servers without MLSD

---

## 9. UI/UX Recommendations

### Connection Wizard Flow

```
1. Select "FTP" from provider list
2. Security notice displayed:
   "FTP can be insecure. We recommend enabling FTPS."
3. Enter server details:
   - Host
   - Port (default 21)
   - Username
   - Password
4. Security options:
   - [ ] Enable FTPS (checked by default if available)
   - If FTPS enabled: Explicit (port 21) / Implicit (port 990)
5. Test connection
6. Success: Add to remotes
```

### Security Warnings to Display

| Scenario | Warning Level | Message |
|----------|---------------|---------|
| Plain FTP | Warning (Orange) | "Password and files sent without encryption" |
| FTPS with cert error | Info (Blue) | "Could not verify server certificate" |
| Skip cert verify enabled | Caution (Yellow) | "Certificate verification disabled" |
| Anonymous FTP | Info (Blue) | "Using anonymous access (no login required)" |

---

## 10. References

### Official Documentation
- [rclone FTP Documentation](https://rclone.org/ftp/)
- [RFC 959 - FTP](https://tools.ietf.org/html/rfc959)
- [RFC 4217 - FTP over TLS](https://tools.ietf.org/html/rfc4217)

### rclone Source Code
- [FTP Backend Source (GitHub)](https://github.com/rclone/rclone/blob/master/backend/ftp/ftp.go)

### Related CloudSync Ultra Files
- `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift` - Provider definitions
- `/Users/antti/claude/CloudSyncApp/RcloneManager.swift` - FTP setup function (lines 1304-1314)
- `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift` - Connection test
- `/Users/antti/claude/CloudSyncApp/Models/TransferOptimizer.swift` - Chunk size settings

### Related Integration Studies
- `ARCHITECT5_SFTP.md` - SFTP (different protocol, often confused with FTP)
- `ARCHITECT4_WEBDAV.md` - WebDAV (HTTP-based alternative)

---

## Appendix A: rclone Backend Capabilities

| Feature | Supported | Notes |
|---------|-----------|-------|
| Copy | Yes | - |
| Move | Yes | Via rename |
| DirMove | Yes | - |
| Purge | Yes | - |
| About | No | No quota info via FTP |
| SetModTime | Partial | Server-dependent, use `writing_mdtm` for VsFTPd |
| Hashes | No | FTP protocol has no hash support |
| PublicLink | No | - |
| ServerSideMove | Yes | - |
| ServerSideCopy | No | - |
| ReadMimeType | No | - |
| WriteMimeType | No | - |

---

## Appendix B: Common FTP Server Software

| Server | Platform | FTPS Support | Notes |
|--------|----------|--------------|-------|
| vsftpd | Linux | Yes | Very secure, common on Linux |
| ProFTPD | Linux/Unix | Yes | Highly configurable |
| PureFTPd | Linux/Unix | Yes | Simple, secure |
| FileZilla Server | Windows | Yes | Popular, GUI-based |
| IIS FTP | Windows | Yes | Built into Windows Server |
| WS_FTP Server | Windows | Yes | Enterprise features |
| Serv-U | Windows/Linux | Yes | Enterprise MFT |

---

## Appendix C: Troubleshooting Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `connection refused` | Server not running/wrong port | Verify server is running, check port |
| `530 Login incorrect` | Wrong credentials | Verify username/password |
| `530 Not logged in` | Auth failed | Check if TLS required |
| `425 Can't open data connection` | Passive mode issue | Check firewall, try `disable_epsv` |
| `500 Illegal PORT command` | Active mode blocked | Use passive mode (default) |
| `550 Permission denied` | No access to path | Check user permissions |
| `421 Timeout` | Connection idle too long | Increase `idle_timeout` |
| `TLS handshake failed` | Certificate issue | Use `no_check_certificate` for self-signed |

---

## Conclusion

FTP integration in CloudSync Ultra is **already functional** at a basic level. The `setupFTP()` method in `RcloneManager.swift` creates working FTP remotes with rclone. The main improvements needed are:

1. **FTPS Support (Easy):** Add `explicit_tls` and `tls` parameters to setup function
2. **Security Warning (Easy):** Display warning when using plain FTP
3. **UI Enhancement (Easy):** Add FTPS toggle and mode selector to wizard
4. **Certificate Options (Easy):** Add self-signed cert handling

Despite FTP being an aging protocol with security concerns, it remains relevant for specific use cases. CloudSync Ultra should support it with appropriate security warnings and recommend FTPS whenever possible.

**Final Assessment:** Implementation is 80% complete. FTPS support is the only significant gap.

---

*Document generated by Architect-4 for Sprint v2.0.35*
