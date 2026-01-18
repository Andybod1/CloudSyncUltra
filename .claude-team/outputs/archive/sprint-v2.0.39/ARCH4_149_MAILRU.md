# Integration Study #149: Mail.ru Cloud

**Architect:** Architect-4
**Date:** 2026-01-18
**Status:** Complete

---

## Executive Summary

Mail.ru Cloud (also known as Cloud Mail.ru) is a Russia-based cloud storage service that is fully implemented in CloudSync Ultra. The integration uses the `mailru` rclone backend with app password authentication.

---

## Implementation Status in CloudSync Ultra

### Current State: FULLY IMPLEMENTED

| Component | Status | Location |
|-----------|--------|----------|
| CloudProviderType enum | Implemented | `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift` |
| rclone backend mapping | Implemented | `rcloneType = "mailru"` |
| Setup function | Implemented | `RcloneManager.setupMailRuCloud()` |
| Brand color | Implemented | `#0D85F8` (Mail.ru Blue) |
| Icon | Implemented | `envelope.circle.fill` |
| Transfer optimization | Implemented | 8MB chunk size default |
| Unit tests | Implemented | `Phase1Week1ProvidersTests.swift` |

### Code References

**CloudProviderType Definition:**
```swift
case mailRuCloud = "mailru"

var displayName: String {
    case .mailRuCloud: return "Mail.ru Cloud"
}

var rcloneType: String {
    case .mailRuCloud: return "mailru"
}
```

**RcloneManager Setup:**
```swift
func setupMailRuCloud(remoteName: String, username: String, password: String) async throws {
    try await createRemote(
        name: remoteName,
        type: "mailru",
        parameters: [
            "user": username,
            "pass": password
        ]
    )
}
```

---

## Authentication Requirements

### App Password (REQUIRED)

**CRITICAL:** Mail.ru Cloud DOES NOT work with standard username/password authentication. Users MUST create an app-specific password.

**Error without app password:**
```
oauth2: server response missing access_token
```

### How to Create an App Password

1. Log into Mail.ru account
2. Go to **Security settings** (click user icon)
3. Navigate to **"Пароли для внешних приложений"** (Passwords for external applications)
4. Create new app password
5. Select permissions: **"Full access to Mail, Cloud and Calendar (all protocols)"**
6. Copy the generated password for use in CloudSync

### Configuration Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `user` | Yes | Mail.ru email address |
| `pass` | Yes | App-specific password (will be obscured) |
| `client_id` | No | Optional custom OAuth client ID |
| `client_secret` | No | Optional custom OAuth client secret |

### 2FA Considerations

- Mail.ru supports 2FA on accounts
- App passwords bypass 2FA requirement
- Users with 2FA enabled MUST use app passwords (they cannot use regular password)

---

## Storage and Feature Limits

### Storage Tiers

| Tier | Storage | File Size Limit |
|------|---------|-----------------|
| Free | Varies (historically 8-25GB) | 2GB per file |
| Paid | Varies by plan | Unlimited file size |

### Technical Limitations

| Feature | Supported | Notes |
|---------|-----------|-------|
| Partial uploads | No | File size must be known before upload |
| Streaming uploads | No | Complete file required |
| Modification times | Yes | 1-second precision for files |
| Directory mod times | No | Not supported |
| Case sensitivity | No | Cannot have "Hello.doc" and "hello.doc" |
| Hash verification | Yes | Modified SHA1 algorithm |
| Deduplication | Yes | Hash-based speedup available |
| Trash | Yes | Deleted items go to trash |
| Quota tracking | Yes | `rclone about` shows usage |

### Filename Restrictions

Certain characters are automatically replaced with full-width Unicode equivalents:
- `"` (quotes)
- `*` (asterisk)
- `:` (colon)
- `/` (forward slash)
- `\` (backslash)
- `<` `>` (angle brackets)
- `|` (pipe)
- `?` (question mark)

---

## Supported Operations

| Operation | Supported |
|-----------|-----------|
| List files | Yes |
| Upload | Yes |
| Download | Yes |
| Delete | Yes (to trash) |
| Move/Rename | Yes |
| Copy | Yes |
| About (quota) | Yes |
| Cleanup | Yes |
| Empty trash | Yes |

### Not Supported

- Server-side copy between different Mail.ru accounts
- Streaming/chunked uploads without known size

---

## Recommended Wizard Flow

### Current Implementation

Mail.ru is NOT marked as requiring OAuth (`requiresOAuth` returns false), which is CORRECT because it uses app password authentication, not browser-based OAuth.

### Recommended Wizard Steps

1. **Choose Provider Step**
   - Select Mail.ru Cloud from International providers section

2. **Configure Settings Step** (credentials form)
   - Username field: Email address
   - Password field: App password (NOT regular password)
   - **Add warning banner:** "Mail.ru requires an app password, not your regular password"
   - **Add help link:** Link to Mail.ru security settings

3. **Test Connection Step**
   - Standard connection test
   - Specific error handling for "oauth2: server response missing access_token" error
   - Display helpful message if app password not used

4. **Success Step**
   - Show connected email
   - Display storage quota if available

### Recommended UI Enhancements

```swift
// In ConfigureSettingsStep.swift providerInstructions
case .mailRuCloud:
    return "Mail.ru Cloud requires an app password. Go to Mail.ru Settings > Security > External App Passwords to create one."
```

```swift
// In ConfigureSettingsStep.swift providerHelpURL
case .mailRuCloud:
    return URL(string: "https://id.mail.ru/security")
```

---

## Regional Considerations

### Russia-Focused Service

Mail.ru Cloud is a **Russian cloud storage service** with the following considerations:

1. **Primary Market:** Russia and CIS countries
2. **Interface Language:** Primarily Russian (English available)
3. **Data Location:** Servers located in Russia
4. **Regulatory:** Subject to Russian data laws

### International Access

- Service is accessible worldwide
- Some features may be region-restricted
- Performance may vary based on geographic location
- Consider latency for users outside Russia/Europe

### Localization Notes

- App password setup instructions are in Russian: "Пароли для внешних приложений"
- Users may need assistance navigating Russian-language settings
- CloudSync should consider providing translated setup guides

---

## Performance Optimization

### Current Settings in CloudSync

```swift
// TransferOptimizer.swift
case .mailRuCloud:
    return 8 * 1024 * 1024  // 8MB default chunk size
```

### Recommended rclone Flags

```bash
# Standard configuration
--mailru-speedup-enable true  # Enable hash-based deduplication
--checkers 8
--transfers 4
```

### Performance Characteristics

- **Hash speedup:** Can skip uploads if file hash already exists on server
- **No fast-list support:** Directory listings are sequential
- **API rate limits:** Unknown specific limits, use conservative parallelism

---

## Known Limitations and Issues

### Technical Issues

1. **App password requirement** - Most common user confusion point
2. **No partial uploads** - Large files may fail on unstable connections
3. **Case insensitivity** - May cause issues with case-sensitive workflows
4. **Filename encoding** - Special characters converted to Unicode

### Security Considerations

1. App passwords grant full access to Mail, Cloud, and Calendar
2. No granular permission scoping available
3. Users should create dedicated app password for CloudSync
4. Recommend users revoke unused app passwords

### Regional/Political Considerations

1. Russian data residency laws apply
2. Service availability may be affected by sanctions or regulations
3. Enterprise users should verify compliance requirements

---

## Comparison with Similar Providers

| Feature | Mail.ru Cloud | Yandex Disk | pCloud |
|---------|--------------|-------------|--------|
| Authentication | App Password | OAuth | OAuth |
| Free Storage | ~8-25GB | 10GB | 10GB |
| Max File Size (Free) | 2GB | 10GB | Unlimited |
| Hash Dedup | Yes | No | No |
| Region | Russia | Russia | Switzerland |
| rclone Backend | mailru | yandex | pcloud |

---

## Recommendations

### Immediate Actions

1. **Add provider-specific instructions** in ConfigureSettingsStep for Mail.ru
2. **Add help URL** to Mail.ru security settings
3. **Improve error handling** for common "missing access_token" error

### Future Enhancements

1. **Localized setup guide** with screenshots for creating app passwords
2. **Quota display** in provider card after connection
3. **Hash speedup indicator** showing when uploads are skipped

### Testing Requirements

1. Test with free account (2GB file limit)
2. Test with paid account (unlimited files)
3. Test special character filename handling
4. Test connection from non-Russian IP addresses

---

## References

- [rclone Mail.ru documentation](https://rclone.org/mailru/)
- [Mail.ru Cloud website](https://cloud.mail.ru/)
- [Mail.ru Security Settings](https://id.mail.ru/security)

---

## Appendix: rclone Configuration Example

```ini
[mailru]
type = mailru
user = user@mail.ru
pass = app-password-here-obscured
```

### Command Line Test

```bash
# Test connection
rclone lsd mailru:

# Check quota
rclone about mailru:

# List files
rclone ls mailru:
```
