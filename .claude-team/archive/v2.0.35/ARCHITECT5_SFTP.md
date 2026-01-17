# Integration Study: SFTP (Secure File Transfer Protocol)

**GitHub Issue:** #143
**Sprint:** v2.0.35
**Author:** Architect-5
**Date:** 2026-01-17
**Status:** Research Complete

---

## Executive Summary

SFTP (Secure/SSH File Transfer Protocol) is a network protocol that provides file access, transfer, and management over SSH. It is one of the most widely used protocols for secure file transfer, particularly for self-hosted servers, NAS devices, and enterprise environments. Rclone has a mature, native SFTP backend with comprehensive authentication support including password, SSH keys, and SSH agent integration.

**Implementation Difficulty:** MEDIUM (due to SSH key UI complexity)

---

## 1. rclone Backend Details

### Backend Type
SFTP has a **native rclone backend** (`type = sftp`). This is a fully-featured implementation using the Go SSH library.

### Configuration Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `host` | string | Yes | - | SSH host to connect to |
| `user` | string | Yes* | $USER | SSH username |
| `port` | int | No | 22 | SSH port number |
| `pass` | string | No* | - | SSH password (obscured) |
| `key_pem` | string | No* | - | Raw PEM-encoded private key |
| `key_file` | string | No* | - | Path to PEM private key file |
| `key_file_pass` | string | No | - | Passphrase for encrypted key |
| `pubkey_file` | string | No | - | Path to public key file |
| `key_use_agent` | bool | No | false | Use SSH agent for authentication |
| `known_hosts_file` | string | No | - | Path to known_hosts file |
| `disable_hashcheck` | bool | No | false | Disable hash/checksum commands |
| `set_modtime` | bool | No | true | Set modification time on upload |
| `shell_type` | string | No | auto | unix, powershell, cmd, or none |
| `md5sum_command` | string | No | md5sum | Command to calculate MD5 |
| `sha1sum_command` | string | No | sha1sum | Command to calculate SHA1 |
| `chunk_size` | SizeSuffix | No | 32Ki | SFTP packet chunk size |
| `concurrency` | int | No | 64 | Max concurrent requests per file |
| `idle_timeout` | Duration | No | 60s | Idle connection timeout |
| `set_env` | SpaceSepList | No | - | Environment variables for remote |

*One of `pass`, `key_file`, `key_pem`, or `key_use_agent` must be provided for authentication.

### Example Configuration

```ini
[my-sftp]
type = sftp
host = server.example.com
user = username
port = 22
pass = *** ENCRYPTED ***
known_hosts_file = ~/.ssh/known_hosts
```

### Current CloudSync Ultra Support

SFTP is **already defined** in the codebase:

**File: `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`**
- `CloudProviderType.sftp` exists (line 22)
- `rcloneType` returns `"sftp"` (line 260)
- Display name: "SFTP" (line 81)
- Icon: `terminal.fill` (line 141)
- Brand color: `.green` (line 201)
- Multi-thread capability: `.unsupported` (treated as local-like)
- Default parallelism: 8 transfers, 16 checkers (line 655)

**File: `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`**
- `setupSFTP()` function exists (lines 1286-1296)
- Current implementation only supports password authentication
- Missing: SSH key support, SSH agent support, known_hosts verification

---

## 2. Authentication Requirements

### 2.1 Password Authentication

The simplest method - username and password over SSH.

**Pros:**
- Easy to configure
- No key management required

**Cons:**
- Less secure than key-based auth
- Subject to brute-force attacks
- Password may be stored (albeit obscured)

**Current Status:** Supported in CloudSync Ultra

### 2.2 SSH Key Authentication

Supports multiple key types:

| Key Type | Algorithm | Recommended |
|----------|-----------|-------------|
| RSA | RSA 2048/4096 bit | Legacy, still widely supported |
| Ed25519 | Edwards-curve | Modern, preferred for new setups |
| ECDSA | NIST P-256/P-384/P-521 | Good alternative |
| DSA | DSA 1024 bit | Deprecated, avoid |

**Key File Locations:**
- `~/.ssh/id_rsa` - Traditional RSA key
- `~/.ssh/id_ed25519` - Modern Ed25519 key
- `~/.ssh/id_ecdsa` - ECDSA key
- Custom paths supported

**Key File Formats:**
- OpenSSH format (modern)
- PEM format (traditional)
- Encrypted keys with passphrase supported

**Current Status:** NOT supported in CloudSync Ultra

### 2.3 SSH Agent Support

Rclone can use the system SSH agent for authentication:

```ini
[my-sftp]
type = sftp
host = example.com
key_use_agent = true
pubkey_file = ~/.ssh/id_ed25519.pub
```

**Benefits:**
- No private key path needed in config
- Works with hardware keys (YubiKey, etc.)
- Passphrase managed by agent

**Known Issue:** Rclone may require `ssh-add` to be run manually before connection when using OpenSSH format keys. This is documented in [GitHub Issue #7011](https://github.com/rclone/rclone/issues/7011).

**Current Status:** NOT supported in CloudSync Ultra

### 2.4 Known Hosts Verification

By default, rclone does **NOT** verify host keys, which is a security risk.

To enable verification:
```ini
known_hosts_file = ~/.ssh/known_hosts
```

**Security Considerations:**
- Without host key verification, MITM attacks are possible
- First-time connections require manual host key acceptance
- Use `ssh-keyscan` to pre-populate known_hosts

**Creating a Known Hosts Entry:**
```bash
ssh-keyscan -t ed25519,rsa,ecdsa server.example.com >> ~/.ssh/known_hosts
```

**Current Status:** NOT supported in CloudSync Ultra

### 2.5 Keyboard-Interactive Authentication

Some SFTP servers (especially enterprise) use keyboard-interactive auth for:
- Multi-factor authentication
- Challenge-response systems
- PAM integration

**Rclone Support:** Limited. The `ask_password` option can prompt for password but doesn't handle complex challenges.

**Current Status:** NOT supported in CloudSync Ultra

---

## 3. Common Use Cases

### 3.1 Self-Hosted NAS (Synology, QNAP)

**Configuration:**
- Host: NAS local IP or hostname
- Port: 22 (default) or custom
- User: NAS admin or dedicated user
- Auth: Password or SSH key

**Synology DSM Specifics:**
- Enable SSH in Control Panel > Terminal & SNMP
- User homes enabled for home directory access
- Root access typically restricted

**QNAP QTS Specifics:**
- Enable SSH in Control Panel > Network & File Services
- Default port 22
- Admin user or dedicated SFTP user

**Recommended Settings:**
```ini
[synology-nas]
type = sftp
host = 192.168.1.100
user = backup_user
key_file = ~/.ssh/nas_key
set_modtime = true
shell_type = unix
```

### 3.2 VPS/Cloud Servers

**Common Providers:**
- DigitalOcean Droplets
- Linode
- Vultr
- AWS EC2
- Google Compute Engine

**Typical Setup:**
- Port 22 or custom for security
- SSH key authentication (often required)
- Root or sudo user
- Full shell access enables hashing

**Recommended Settings:**
```ini
[my-vps]
type = sftp
host = vps.example.com
user = ubuntu
key_file = ~/.ssh/id_ed25519
known_hosts_file = ~/.ssh/known_hosts
md5sum_command = md5sum
sha1sum_command = sha1sum
```

### 3.3 Shared Web Hosting

**Common Providers:**
- Bluehost, SiteGround, DreamHost
- cPanel/Plesk-based hosts

**Limitations:**
- Often password-only authentication
- May have connection limits
- Shell access may be restricted
- Hash commands may be disabled

**Recommended Settings:**
```ini
[shared-host]
type = sftp
host = ftp.myhost.com
user = cpanel_user
pass = *** ENCRYPTED ***
disable_hashcheck = true
set_modtime = true
```

### 3.4 Enterprise File Servers

**Characteristics:**
- Strict authentication policies
- Firewall rules and allowlisting
- Audit logging
- May require jump hosts/bastion

**Common Solutions:**
- OpenSSH on Linux
- SFTP Gateway products (Cleo, GoAnywhere)
- Managed file transfer (MFT) systems

**Considerations:**
- May require VPN access
- Certificate-based auth possible
- Connection pooling limits
- Compliance requirements (HIPAA, PCI-DSS)

---

## 4. Known Limitations & Workarounds

### 4.1 No Native Hash Support

**Issue:** SFTP protocol does not include checksum/hash commands.

**Rclone Workaround:** If shell access is available, rclone can execute remote commands:
- `md5sum`, `sha1sum`, `sha256sum` (Linux)
- `CRC32`, `BLAKE3`, `XXH3`, `XXH128` (if available)

**Configuration:**
```ini
md5sum_command = md5sum
sha1sum_command = sha1sum
```

**When Shell Access Unavailable:**
```ini
disable_hashcheck = true
```

**Impact:** Without hashes, rclone relies on size and modification time for sync decisions.

### 4.2 Symlink Handling

**Issue:** Symlinks are not fully supported across all operations.

**Current Status:**
- `--sftp-links` flag added for symlink preservation
- Sub-symlink resolution is limited
- Duplicate file issues possible (GitHub #8245)

**Workarounds:**
| Issue | Solution |
|-------|----------|
| Skip symlinks | Use `--skip-links` flag |
| Copy as files | Default behavior (follows symlinks) |
| Preserve symlinks | Use `--sftp-links` flag |

### 4.3 Permission Preservation

**Issue:** File permissions are NOT preserved by rclone during copy/sync operations.

**Reason:** Rclone abstracts filesystems and doesn't track Unix permissions.

**Workaround:** Use `rclone serve sftp` with `--dir-perms` and `--file-perms` for serving, but no solution for client-side copies.

**Alternative:** Post-copy `chmod` script or use `rsync` for permission-sensitive transfers.

### 4.4 Connection Pooling

**Issue:** Some SFTP servers limit concurrent connections.

**Example:** Hetzner Storage Box limits to 10 connections.

**Configuration:**
```bash
rclone sync source: sftp: --transfers 4 --checkers 4
```

**Rule:** `--transfers + --checkers <= server limit`

**CloudSync Ultra Default:** 8 transfers + 16 checkers = 24 (may exceed limits)

**Recommendation:** Add per-remote connection limit settings.

### 4.5 Chunk Size Optimization

**Issue:** Default 32KB chunk size is conservative.

**Optimization for High-Latency Links:**
```ini
chunk_size = 255k
```

**Caution:** Only increase after testing with specific server. Maximum safe value is typically 255K (256K total packet).

### 4.6 No SSH Config Support

**Issue:** Rclone does not read `~/.ssh/config` file.

**Impact:** Users must duplicate settings from SSH config into rclone config.

**Feature Request:** [Forum discussion](https://forum.rclone.org/t/sftp-support-ssh-configuration-file/34395)

---

## 5. Step-by-Step Connection Flow

### 5.1 Password Authentication Flow

```
1. User selects "SFTP" from provider list
2. App prompts for:
   - Host (required): server hostname or IP
   - Port (optional): default 22
   - Username (required): SSH username
   - Password (required): SSH password
3. App obscures password
4. App creates rclone config:
   rclone config create mysftp sftp host=server.com user=user pass=<obscured>
5. App tests connection:
   rclone lsd mysftp:
6. On success, remote is added to sidebar
```

### 5.2 SSH Key Authentication Flow (Proposed)

```
1. User selects "SFTP" from provider list
2. App prompts for:
   - Host (required): server hostname or IP
   - Port (optional): default 22
   - Username (required): SSH username
   - Auth Method (required): Password / SSH Key / SSH Agent
3. If SSH Key selected:
   a. File picker for private key file
   b. Optional passphrase for encrypted keys
   c. App validates key format
4. If SSH Agent selected:
   a. App checks for running SSH agent
   b. Optional public key file for faster lookup
5. App creates rclone config with appropriate auth
6. App tests connection
7. On success, remote is added to sidebar
```

### 5.3 Wizard Configuration Fields

| Field | Type | Validation | Default | Notes |
|-------|------|------------|---------|-------|
| Host | TextField | Non-empty, valid hostname | - | Required |
| Port | TextField | 1-65535 | 22 | Numeric only |
| Username | TextField | Non-empty | $USER | Required |
| Auth Method | Picker | - | Password | Password/Key/Agent |
| Password | SecureField | - | - | If Password auth |
| Key File | FilePicker | .pem, no ext | - | If Key auth |
| Key Passphrase | SecureField | - | - | If key encrypted |
| Use SSH Agent | Toggle | - | false | Alternative to key file |
| Known Hosts | FilePicker | - | - | Advanced option |
| Verify Host Key | Toggle | - | false | Security option |

---

## 6. Security Considerations

### 6.1 Host Key Verification

**Risk Without Verification:** Man-in-the-middle attacks can intercept credentials.

**Recommendation:** Enable by default with user option to bypass for first-time connections.

**Implementation Approach:**
1. Check if host exists in known_hosts
2. If not, display host key fingerprint
3. Ask user to verify and add to known_hosts
4. Store in app-managed known_hosts file

### 6.2 Key Storage Best Practices

| Storage Location | Security Level | Recommendation |
|-----------------|----------------|----------------|
| Filesystem (unencrypted) | Low | Avoid |
| Filesystem (encrypted key) | Medium | Acceptable |
| macOS Keychain | High | Preferred |
| SSH Agent | High | Preferred |

**CloudSync Ultra Approach:**
- Store key file path in config (not key content)
- Store key passphrase in Keychain (if needed)
- Prefer SSH agent integration when available

### 6.3 Firewall/Port Requirements

| Direction | Port | Protocol | Purpose |
|-----------|------|----------|---------|
| Outbound | 22 (default) | TCP | SSH/SFTP connection |
| Outbound | Custom | TCP | Non-standard SSH port |

**Enterprise Considerations:**
- May require firewall rules
- VPN may be needed for internal servers
- Jump host/bastion access patterns

### 6.4 Credential Exposure Risks

| Risk | Mitigation |
|------|------------|
| Password in config | rclone obscures passwords |
| Key passphrase logged | Never log passphrases |
| MITM attack | Enable known_hosts verification |
| Brute force | Use key-based auth |

---

## 7. Implementation Recommendation

### Difficulty: MEDIUM

**Rationale:**
1. SFTP is already defined in `CloudProviderType` enum (Easy)
2. Basic password auth already works (Easy)
3. SSH key authentication requires file picker UI (Medium)
4. SSH agent detection adds complexity (Medium)
5. Host key verification UI/UX is complex (Medium)
6. Security considerations require careful implementation (Medium)

### Code Changes Required

#### Phase 1: Basic Improvements (Easy)

1. **RcloneManager.swift** - Enhance `setupSFTP()`:
```swift
func setupSFTP(
    remoteName: String,
    host: String,
    user: String,
    port: String = "22",
    password: String? = nil,
    keyFile: String? = nil,
    keyPassphrase: String? = nil,
    useAgent: Bool = false,
    knownHostsFile: String? = nil
) async throws {
    var params: [String: String] = [
        "host": host,
        "user": user,
        "port": port
    ]

    if let password = password, !password.isEmpty {
        params["pass"] = password
    }

    if let keyFile = keyFile, !keyFile.isEmpty {
        params["key_file"] = keyFile
        if let passphrase = keyPassphrase, !passphrase.isEmpty {
            params["key_file_pass"] = passphrase
        }
    }

    if useAgent {
        params["key_use_agent"] = "true"
    }

    if let knownHosts = knownHostsFile {
        params["known_hosts_file"] = knownHosts
    }

    try await createRemote(name: remoteName, type: "sftp", parameters: params)
}
```

2. **ConfigureSettingsStep.swift** - Add SFTP-specific UI:
   - Host/port fields
   - Username field
   - Auth method picker (Password/Key/Agent)
   - Conditional fields based on auth method

#### Phase 2: SSH Key Support (Medium)

1. **New View: SFTPKeyPickerView.swift**
   - File picker for key selection
   - Support for common locations (`~/.ssh/`)
   - Key format validation
   - Passphrase prompt for encrypted keys

2. **Key Validation Helper:**
```swift
func validateSSHKey(at path: String) -> (valid: Bool, encrypted: Bool, type: String?) {
    // Check file exists
    // Parse key header
    // Detect encryption
    // Return key type (RSA, Ed25519, etc.)
}
```

#### Phase 3: SSH Agent Integration (Medium)

1. **SSH Agent Detection:**
```swift
func isSSHAgentAvailable() -> Bool {
    ProcessInfo.processInfo.environment["SSH_AUTH_SOCK"] != nil
}
```

2. **List Agent Keys (Optional):**
```swift
func listAgentKeys() async throws -> [String] {
    // Run: ssh-add -L
    // Parse output for key fingerprints
}
```

#### Phase 4: Host Key Verification (Medium-Hard)

1. **Known Hosts Manager:**
   - App-managed known_hosts file
   - Import from system known_hosts
   - Display host key fingerprints
   - First-connection trust prompt

2. **UI for Host Key Verification:**
   - Alert when connecting to unknown host
   - Display fingerprint for manual verification
   - Option to add to known hosts

### Testing Checklist

#### Basic Functionality
- [ ] Create SFTP remote with password auth
- [ ] List files/folders
- [ ] Upload file
- [ ] Download file
- [ ] Delete file
- [ ] Create folder
- [ ] Rename item

#### SSH Key Authentication
- [ ] Connect with RSA key (unencrypted)
- [ ] Connect with RSA key (encrypted, with passphrase)
- [ ] Connect with Ed25519 key
- [ ] Connect with ECDSA key
- [ ] Handle invalid key file gracefully

#### SSH Agent
- [ ] Detect SSH agent availability
- [ ] Connect using agent-stored key
- [ ] Handle missing agent gracefully

#### Security
- [ ] Test known_hosts verification
- [ ] Test connection to unknown host (should warn)
- [ ] Test connection to known host (should succeed)
- [ ] Verify credentials not logged

#### Use Case Testing
- [ ] Synology NAS connection
- [ ] QNAP NAS connection
- [ ] Linux VPS connection
- [ ] Shared hosting connection (password only)

### UI/UX Considerations

1. **Auth Method Selection:**
   - Segmented control: Password | SSH Key | SSH Agent
   - Clear visual indication of selected method

2. **SSH Key Picker:**
   - Default to `~/.ssh/` directory
   - Filter for common key file patterns
   - Show key type and encryption status

3. **Host Key Warning:**
   - Non-dismissible modal for first connection
   - Show full fingerprint
   - "Trust and Connect" / "Cancel" buttons

4. **Error Messages:**
   - "Permission denied" - Wrong password/key
   - "Host key verification failed" - Key changed
   - "Connection refused" - Server not running/firewall
   - "Network unreachable" - No connectivity

---

## 8. References

- [rclone SFTP Documentation](https://rclone.org/sftp/)
- [rclone serve sftp](https://rclone.org/commands/rclone_serve_sftp/)
- [SFTP Backend Source (GitHub)](https://github.com/rclone/rclone/blob/master/backend/sftp/sftp.go)
- [SSH Agent Integration Issue #7011](https://github.com/rclone/rclone/issues/7011)
- [Symlink Support PR #8040](https://github.com/rclone/rclone/pull/8040)
- [SSH Config Support Request](https://forum.rclone.org/t/sftp-support-ssh-configuration-file/34395)
- [SFTP Host Keys Explained](https://www.files.com/blog/2025/02/07/sftp-ssh-host-keys-explained)

---

## Appendix A: rclone Backend Capabilities

Based on rclone source code and documentation:

| Feature | Supported | Notes |
|---------|-----------|-------|
| Copy | Yes | - |
| Move | Yes | Via rename |
| DirMove | Yes | - |
| Purge | Yes | - |
| About | No | No quota info via SFTP |
| SetModTime | Yes | Disable for some servers |
| Hashes | Conditional | Requires shell access |
| PublicLink | No | - |
| ServerSideMove | Yes | - |
| ServerSideCopy | No | - |
| ReadMimeType | No | - |
| WriteMimeType | No | - |

---

## Appendix B: Supported Ciphers and Key Exchange

rclone SFTP supports configuration of:

**Ciphers (--sftp-ciphers):**
- aes128-ctr, aes192-ctr, aes256-ctr
- aes128-gcm@openssh.com, aes256-gcm@openssh.com
- chacha20-poly1305@openssh.com
- arcfour256, arcfour128 (legacy)

**Key Exchange (--sftp-key-exchange):**
- curve25519-sha256, curve25519-sha256@libssh.org
- ecdh-sha2-nistp256, ecdh-sha2-nistp384, ecdh-sha2-nistp521
- diffie-hellman-group14-sha256, diffie-hellman-group14-sha1

**MACs (--sftp-macs):**
- hmac-sha2-256-etm@openssh.com, hmac-sha2-512-etm@openssh.com
- hmac-sha2-256, hmac-sha2-512
- hmac-sha1, hmac-sha1-96

---

## Appendix C: Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `ssh: handshake failed: ssh: unable to authenticate` | Wrong credentials | Verify username/password/key |
| `dial tcp: connection refused` | Server not running | Check SSH service status |
| `ssh: host key mismatch` | Host key changed | Verify server, update known_hosts |
| `ssh: no key found` | Key file not found | Check key_file path |
| `ssh: cannot decode encrypted private keys` | Passphrase needed | Provide key_file_pass |
| `too many authentication failures` | Too many keys tried | Use pubkey_file to specify key |

---

*Document generated by Architect-5 for Sprint v2.0.35*
