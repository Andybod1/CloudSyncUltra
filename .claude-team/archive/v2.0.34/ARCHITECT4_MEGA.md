# MEGA Integration Study for CloudSync Ultra

**Sprint:** v2.0.34
**Issue:** #146
**Date:** 2026-01-17
**Author:** Architect-4

---

## Executive Summary

MEGA is a cloud storage provider known for its strong client-side encryption. Rclone has native support for MEGA via the `mega` backend type, and CloudSync Ultra already has basic MEGA integration in place. This study evaluates MEGA's compatibility, identifies limitations, and recommends enhancements for production readiness.

**Recommendation: MEDIUM difficulty to fully implement**

---

## 1. Rclone Backend Support

### Native Support
MEGA has first-class native support in rclone via the `mega` backend type.

```
rclone type: mega
```

### Current CloudSync Ultra Status
MEGA is already defined in CloudProvider.swift:
- `CloudProviderType.mega` with `rcloneType: "mega"`
- Brand color: `#D9272E` (MEGA Red)
- Icon: `m.square.fill`
- Default parallelism: 4 transfers, 8 checkers

### Setup Method
Basic setup exists in `RcloneManager.swift`:
```swift
func setupMega(remoteName: String, username: String, password: String) async throws {
    try await createRemote(
        name: remoteName,
        type: "mega",
        parameters: [
            "user": username,
            "pass": password
        ]
    )
}
```

**Sources:**
- [rclone MEGA documentation](https://rclone.org/mega/)
- [rclone GitHub - mega.md](https://github.com/rclone/rclone/blob/master/docs/content/mega.md)

---

## 2. Authentication Requirements

### Primary Authentication Method
- **Username/Password**: MEGA uses email/password authentication (NOT OAuth)
- Password must be obscured using `rclone obscure` when stored in config

### 2FA/MFA Support

**CRITICAL UPDATE (rclone 1.72+):**
As of rclone 1.72 (late 2025), MEGA 2FA support was added. However, there are important caveats:

1. **One-time TOTP Entry**: The 2FA code is only required once during initial configuration
2. **30-Second Window**: TOTP codes are valid for 30 seconds (standard TOTP parameters)
3. **Session Persistence**: After initial auth, rclone maintains the session

**Historical Issues (pre-1.72):**
- rclone would fail with "Multi-factor authentication required" error
- Workaround was to disable 2FA on MEGA account (not recommended)

### App-Specific Passwords
MEGA supports app-specific passwords, which are recommended for third-party tools like rclone. Users should be guided to create one instead of using their main account password.

### Configuration Options
| Parameter | Description | Required |
|-----------|-------------|----------|
| `user` | MEGA email address | Yes |
| `pass` | Password (obscured) | Yes |
| `mfa` | 2FA TOTP code | Only for 2FA accounts |

**Sources:**
- [rclone MEGA 2FA PR #8722](https://github.com/rclone/rclone/pull/8722)
- [rclone forum - MEGA 2FA feature](https://forum.rclone.org/t/mega-2fa-feature/43830)
- [GitHub Issue #3165 - add 2fa support for mega](https://github.com/rclone/rclone/issues/3165)

---

## 3. End-to-End Encryption Considerations

### MEGA's Native Encryption
MEGA encrypts all files **client-side before upload**. Key characteristics:

1. **Zero-Knowledge Architecture**: MEGA employees cannot access file contents
2. **Automatic Encryption**: All uploads are encrypted with user's master key
3. **Key Derivation**: Encryption keys are derived from user's password
4. **AES-128**: Files are encrypted with AES-128

### Rclone + MEGA Encryption
Rclone's MEGA backend uses the **same client-side encryption** as the official MEGA client. This means:
- Files uploaded via rclone are encrypted before leaving your device
- Files are compatible with MEGA's official apps
- Encryption is transparent to the user

### Important Caveat
**MEGA's official position on third-party tools:**
> "Please note that these tools are insecure and do not fully implement our cryptographic protocols. We do not recommend any third-party tools."

### HTTP vs HTTPS
- MEGA uses **plain HTTP by default** (since data is already encrypted)
- Some ISPs throttle HTTP connections
- Can enable HTTPS with `--mega-use-https` flag (increases CPU usage)

### Double Encryption Option
Users can layer rclone's crypt backend on top of MEGA for additional privacy:
```
mega-remote: -> mega-crypt: (rclone crypt) -> MEGA servers
```
This provides defense-in-depth but may be overkill given MEGA's native encryption.

**Sources:**
- [rclone MEGA documentation](https://rclone.org/mega/)
- [MEGA Storage Feedback - rclone forum](https://forum.rclone.org/t/mega-storage-feedback/44566)

---

## 4. Step-by-Step Connection Flow

### For CloudSync Ultra Users

#### Flow 1: Standard Account (No 2FA)
1. User selects MEGA from provider list
2. User enters MEGA email and password
3. CloudSync Ultra obscures password and stores in rclone config
4. Connection test verifies access
5. Remote is ready for use

#### Flow 2: 2FA-Enabled Account (rclone 1.72+)
1. User selects MEGA from provider list
2. User enters MEGA email and password
3. User enters current 2FA code from authenticator app
4. CloudSync Ultra passes credentials with TOTP to rclone
5. Connection test verifies access
6. Session token is cached for future use

### Technical Implementation
```swift
// Enhanced setupMega function (proposed)
func setupMega(
    remoteName: String,
    username: String,
    password: String,
    mfaCode: String? = nil
) async throws {
    var params: [String: String] = [
        "user": username,
        "pass": password
    ]

    if let mfa = mfaCode, !mfa.isEmpty {
        params["mfa"] = mfa
    }

    try await createRemote(
        name: remoteName,
        type: "mega",
        parameters: params
    )
}
```

---

## 5. Known Limitations & Workarounds

### Transfer Quota (CRITICAL)

**Free Account Limits:**
| Metric | Limit |
|--------|-------|
| Storage | 20 GB |
| Transfer Quota | ~5 GB per 6 hours |
| Quota Reset | Rolling 6-hour window |
| Tracking Method | By IP address |

**Quota Exceeded Behavior:**
- Downloads pause until quota resets
- Error: "transfer quota exceeded"
- User must wait or upgrade to paid plan

**Paid Plan Quotas:**
| Plan | Storage | Transfer | Price |
|------|---------|----------|-------|
| Pro I | 2 TB | 2 TB | ~$11.68/mo |
| Pro II | 8 TB | 8 TB | ~$19.99/mo |
| Pro III | 16 TB | 16 TB | ~$29.99/mo |

**Workaround Recommendations:**
1. Display quota status in UI (if API available)
2. Warn users about 6-hour rolling window
3. Consider bandwidth limiting to stay under quota
4. Recommend paid plans for heavy sync usage

### Technical Limitations

| Limitation | Impact | Workaround |
|------------|--------|------------|
| No modification times | Sync efficiency reduced | Use checksums for comparison |
| No native hashes | Content verification slower | Accept or use crypt layer |
| Duplicate filenames allowed | Unusual behavior possible | Monitor and deduplicate |
| High memory usage | Large directory listings | Limit concurrent operations |
| HTTP throttling by ISPs | Slow transfers | Enable `--mega-use-https` |

### Encryption Key Prerequisite
**IMPORTANT:** The encryption keys must be generated via a regular browser login first. New accounts that have never logged in via browser will fail with rclone.

### Memory Usage
Large file listings can consume significant memory. Recommended settings:
- Limit `--checkers` to 8 for MEGA
- Use `--mega-chunk-size` appropriately (16M default)

**Sources:**
- [How to Bypass MEGA Download Limit](https://www.cloudwards.net/bypass-mega-download-limit/)
- [MEGA Cloud Storage Review](https://www.cloudwards.net/review/mega/)
- [MEGA Transfer Quota Guide](https://www.smartmobsolution.com/what-is-mega-transfer-quota-and-when-does-it-reset/)

---

## 6. MEGA S4 (S3-Compatible) Alternative

MEGA offers S4 Object Storage, an S3-compatible service:

### Advantages
- S3-compatible API (uses rclone's `s3` backend)
- Better for new projects/automations
- Multiple geographic regions

### Regions Available
- `eu-central-1.s4.mega.io` (Amsterdam)
- `eu-central-2.s4.mega.io` (Bettembourg)
- `ca-central-1.s4.mega.io` (Montreal)
- `ca-west-1.s4.mega.io` (Vancouver)

### Limitations
- Does not support `X-Amz-Meta-Mtime` header (no modification times)
- Files uploaded via MEGA apps need `--ignore-checksum` flag

### Pricing
- Starting at approximately $2.50/TB/month
- 5x egress included

**Recommendation:** Consider offering MEGA S4 as a separate provider type for enterprise users.

**Sources:**
- [MEGA S3-compatible object storage](https://lowendtalk.com/discussion/202143/mega-s3-compatible-object-storage-2-50-tb-mo-and-5x-egress)
- [MEGA Help Centre - S4 Rclone Setup](https://help.mega.io/megas4/setup-guides/rclone-setup-guide-for-mega-s4)

---

## 7. Configuration Options Reference

### Standard Options
| Option | Default | Description |
|--------|---------|-------------|
| `--mega-user` | - | MEGA email address |
| `--mega-pass` | - | Password (obscured) |
| `--mega-mfa` | - | 2FA TOTP code |
| `--mega-use-https` | false | Force HTTPS connections |
| `--mega-hard-delete` | false | Bypass trash (permanent delete) |
| `--mega-chunk-size` | 16M | Size of upload chunks |
| `--mega-encoding` | Slash,InvalidUtf8,Dot | Filename encoding |

### Recommended Settings for CloudSync Ultra
```
--mega-chunk-size=16M
--transfers=4
--checkers=8
--mega-use-https  # Optional, for ISP throttling
```

---

## 8. Implementation Recommendation

### Difficulty: MEDIUM

### Rationale
- **Basic support already exists** in CloudProvider.swift and RcloneManager.swift
- **2FA support needed** for full compatibility (rclone 1.72+)
- **UI guidance needed** for transfer quota awareness
- **No OAuth** simplifies authentication flow

### Code Changes Needed

#### 1. Update ConfigureSettingsStep.swift
Add 2FA code field for MEGA (similar to ProtonDrive):
```swift
private var needsTwoFactor: Bool {
    provider == .protonDrive || provider == .mega
}
```

#### 2. Update RcloneManager.setupMega()
Add optional MFA parameter:
```swift
func setupMega(
    remoteName: String,
    username: String,
    password: String,
    mfaCode: String? = nil
) async throws
```

#### 3. Update TestConnectionStep.swift
Pass 2FA code to setupMega:
```swift
case .mega:
    try await rclone.setupMega(
        remoteName: rcloneName,
        username: username,
        password: password,
        mfaCode: twoFactorCode.isEmpty ? nil : twoFactorCode
    )
```

#### 4. Add Quota Warning UI (Optional Enhancement)
- Display transfer quota information in provider details
- Warn users about 6-hour rolling window
- Recommend paid plans for sync-heavy use cases

### Estimated Effort
| Task | Effort |
|------|--------|
| Add 2FA support | 2 hours |
| Update UI for 2FA field | 1 hour |
| Add quota warning UI | 3 hours |
| Testing & QA | 2 hours |
| **Total** | **8 hours** |

---

## 9. Summary & Recommendations

### Strengths
1. Native rclone backend with good support
2. Built-in client-side encryption (zero-knowledge)
3. Simple username/password authentication
4. 2FA support added in rclone 1.72
5. 20GB free storage

### Weaknesses
1. Transfer quota limitations on free accounts
2. No modification time support
3. MEGA discourages third-party tools
4. Memory usage can be high for large directories

### Implementation Priority: HIGH

MEGA is already partially implemented in CloudSync Ultra. The main enhancement needed is **2FA support** to fully support all MEGA accounts.

### Action Items
1. [ ] Add 2FA input field for MEGA in ConfigureSettingsStep
2. [ ] Update setupMega() to accept optional MFA code
3. [ ] Test with 2FA-enabled MEGA account
4. [ ] Consider adding quota warning in UI
5. [ ] Document transfer quota limitations for users

---

## Appendix: Test Checklist

- [ ] Create new MEGA remote without 2FA
- [ ] Create new MEGA remote with 2FA enabled
- [ ] Upload files to MEGA
- [ ] Download files from MEGA
- [ ] Delete files (verify trash vs hard delete)
- [ ] Test with transfer quota exceeded
- [ ] Test HTTPS mode (`--mega-use-https`)
- [ ] Verify encryption compatibility with MEGA app
