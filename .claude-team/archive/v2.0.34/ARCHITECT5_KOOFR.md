# Integration Study: Koofr Cloud Storage

**GitHub Issue:** #147
**Sprint:** v2.0.34
**Author:** Architect-5
**Date:** 2026-01-17
**Status:** Research Complete

---

## Executive Summary

Koofr is a European cloud storage provider with native rclone backend support. It offers a unique feature set including the ability to connect and manage external cloud services (Dropbox, Google Drive, OneDrive) through a unified interface. Integration into CloudSync Ultra is straightforward due to existing infrastructure support.

**Implementation Difficulty:** Easy

---

## 1. rclone Backend Details

### Backend Type
Koofr has a **native rclone backend** (`type = koofr`). This is NOT a WebDAV-based implementation - it uses Koofr's proprietary API directly.

### Supported Providers
The Koofr backend supports three provider configurations:
1. **koofr** - Main Koofr service (https://app.koofr.net/)
2. **digistorage** - Digi Storage, Romanian provider (https://storage.rcs-rds.ro/)
3. **other** - Any Koofr API-compatible service (custom endpoint)

### Configuration Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `provider` | string | Yes | koofr, digistorage, or other |
| `user` | string | Yes | Koofr username/email |
| `password` | string | Yes | App password (obscured) |
| `endpoint` | string | Only for "other" | Custom API endpoint URL |
| `mountid` | string | No | Mount ID for external cloud access |
| `setmtime` | bool | No | Support modification time (default: true) |
| `encoding` | string | No | Default: Slash,BackSlash,Del,Ctl,InvalidUtf8,Dot |

### Example Configuration
```ini
[koofr]
type = koofr
provider = koofr
user = user@example.com
password = *** ENCRYPTED ***
```

### Current CloudSync Ultra Support
Koofr is **already defined** in the codebase:
- `CloudProviderType.koofr` exists in `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`
- `rcloneType` returns `"koofr"` (correct)
- Multi-thread capability is set to `.limited` (4 threads max) - appropriate for consumer cloud storage
- Brand color defined: `#3399DB` (Koofr Blue)
- Icon: `arrow.triangle.2.circlepath.circle`

---

## 2. Authentication Requirements

### Primary Method: App Passwords
Koofr uses **application-specific passwords** instead of main account passwords. This is mandatory as of January 1, 2021.

**How to Generate App Password:**
1. Log into Koofr web app (https://app.koofr.net/)
2. Click Profile icon (top-right) -> Preferences
3. Select "Password" from left menu
4. Scroll to "App passwords" section
5. Enter a name (e.g., "CloudSync Ultra")
6. Click "Generate"
7. Copy the generated password

### Security Benefits
- App passwords cannot modify account settings
- Cannot change email or main password
- Cannot log into Koofr web/mobile apps
- Limited scope reduces credential leak risk

### Alternative Methods (SDK/API)
Koofr's API supports:
- **HTTP Basic Auth** - With app password
- **OAuth2** - Requires client ID/secret registration
- **Token-based** - Koofr's proprietary token scheme

For CloudSync Ultra, **app passwords are recommended** for simplicity.

### Two-Factor Authentication
Koofr supports 2FA via:
- TOTP apps (Google Authenticator, Authy, etc.)
- FIDO2 Passkeys (YubiKey, biometrics)

2FA does not affect app password functionality - app passwords work independently.

---

## 3. Unique Features: External Cloud Connections

### What It Is
Koofr allows users to connect their Dropbox, Google Drive, and OneDrive accounts directly to Koofr. Files from these services appear as virtual folders within Koofr.

### How It Works via rclone
Each connected external cloud gets a unique **Mount ID** in Koofr. To access external clouds through rclone:

```ini
[koofr-gdrive]
type = koofr
provider = koofr
user = user@example.com
password = *** ENCRYPTED ***
mountid = <mount-id-for-google-drive>
setmtime = false
```

**Important:** Set `setmtime = false` for external cloud mounts (Dropbox, Amazon Drive) as they don't support modification time setting through Koofr's API.

### Connection Limits by Plan

| Plan | External Accounts | Per Provider Max |
|------|-------------------|------------------|
| Starter (Free) | 2 | 1 |
| Briefcase (S/M) | 9 | 3 |
| Suitcase (L/XL/XXL) | 18 | 6 |
| Crate (XXXL/5XXL/10XXL/20XXL) | 30 | 10 |

### Use Cases
- **Cloud consolidation** - Single interface for multiple providers
- **Cross-cloud transfers** - Move files between providers without local download
- **Unified backup** - Backup multiple clouds to Koofr or vice versa
- **Cost optimization** - Use Koofr as primary storage, keep old clouds connected

### Limitations for External Clouds
- Cannot sync to external clouds via Koofr desktop app
- No automated transfers between connected clouds
- Modification time (`setmtime`) must be disabled
- Basic operations only (copy, move, delete)

---

## 4. Step-by-Step Connection Flow

### Basic Koofr Setup (CloudSync Ultra)

```
1. User selects "Koofr" from provider list
2. App prompts for credentials:
   - Username (email)
   - App password (with link to generate one)
3. App creates rclone config:
   rclone config create koofr koofr provider=koofr user=<email> password=<obscured>
4. App tests connection:
   rclone lsd koofr:
5. On success, remote is added to sidebar
```

### Advanced: External Cloud Access

```
1. User goes to Settings -> Koofr -> "Connect External Cloud"
2. App lists available mount IDs (requires API call)
3. User selects which external cloud to access
4. App creates separate remote with mountid:
   rclone config create koofr-gdrive koofr provider=koofr user=<email> password=<obscured> mountid=<id> setmtime=false
5. External cloud appears as separate remote in CloudSync Ultra
```

### Wizard Configuration Fields

| Field | Type | Validation | Notes |
|-------|------|------------|-------|
| Email | Text | Email format | Required |
| App Password | SecureField | Non-empty | Link to generate |
| Provider | Dropdown | koofr/digistorage/other | Default: koofr |
| Custom Endpoint | Text | URL format | Only if "other" selected |

---

## 5. Known Limitations & Workarounds

### Filesystem Limitations
- **Case insensitive** - Cannot have "Hello.doc" and "hello.doc" in same folder
- **Encoding** - Uses `Slash,BackSlash,Del,Ctl,InvalidUtf8,Dot` by default

### Transfer Limitations
- **No symlink support** - Avoid `--copy-links` flag (may cause infinite loops)
- **Multi-thread streams** - Limited support (4 streams recommended max)
- **Fast-list** - Not explicitly supported

### External Cloud Limitations
- `setmtime = false` required for Dropbox/Amazon Drive mounts
- Cannot use Koofr desktop app for sync to external clouds
- Basic operations only (no automated sync)

### Workarounds
| Issue | Workaround |
|-------|------------|
| Case sensitivity | Use lowercase naming convention |
| setmtime failures | Detect mount type, auto-disable setmtime |
| Symlink loops | Exclude `--copy-links` in transfer args |

---

## 6. Storage & Pricing

### Plans Overview

| Tier | Storage | Price | External Clouds |
|------|---------|-------|-----------------|
| Starter | 10 GB | Free | 2 |
| Briefcase S | 25 GB | ~2/mo | 9 |
| Briefcase M | 100 GB | ~5/mo | 9 |
| Suitcase L | 250 GB | ~10/mo | 18 |
| Suitcase XL | 1 TB | ~20/mo | 18 |
| Crate XXXL | 2.5 TB | ~30/mo | 30 |
| Crate 10XXL | 10 TB | ~100/mo | 30 |

**Lifetime Deal:** ~$130 for 1TB (occasionally available)

### EU Data Residency
- **Company HQ:** Slovenia (EU)
- **Data Centers:** Germany (ISO 27001 certified)
- **GDPR Compliant:** Yes, by default
- **Zero Tracking:** No tracking cookies or activity monitoring
- **File Scanning:** No content scanning

---

## 7. Implementation Recommendation

### Difficulty: EASY

**Rationale:**
1. Koofr is already defined in `CloudProviderType` enum
2. Native rclone backend exists (no WebDAV complexity)
3. Simple app password authentication (no OAuth flow needed)
4. Multi-thread capability already configured as `.limited`
5. Brand colors and icons already defined

### Code Changes Required

**None for basic support** - Koofr already works with current CloudSync Ultra infrastructure.

**Optional enhancements for external cloud feature:**

1. **Settings/Preferences** - Add UI to show connected external clouds
2. **Mount ID detection** - API call to list available mounts
3. **Auto-setmtime detection** - Disable setmtime for external cloud mounts

### Testing Checklist
- [ ] Create Koofr remote via wizard
- [ ] List files/folders
- [ ] Upload file
- [ ] Download file
- [ ] Delete file
- [ ] Create folder
- [ ] Rename item
- [ ] Test with Koofr Vault (encrypted folder)

### External Cloud Testing (Optional)
- [ ] Connect Google Drive to Koofr account
- [ ] Access Google Drive files via Koofr mount
- [ ] Transfer file from GDrive mount to Koofr primary
- [ ] Verify setmtime=false works correctly

---

## 8. References

- [rclone Koofr Documentation](https://rclone.org/koofr/)
- [Koofr Features Overview](https://koofr.eu/features/)
- [Koofr Pricing](https://koofr.eu/pricing/)
- [Koofr App Password Guide](https://koofr.eu/help/linking-koofr-with-desktops/how-to-generate-an-application-specific-password-in-koofr/)
- [External Cloud Connections Guide](https://koofr.eu/blog/posts/connecting-multiple-cloud-storage-accounts-to-koofr-a-step-by-step-guide)
- [rclone with Koofr Vault](https://koofr.eu/blog/posts/using-rclone-with-koofr-vault)
- [rclone Koofr Backend Source](https://github.com/rclone/rclone/blob/master/backend/koofr/koofr.go)

---

## Appendix: rclone Backend Capabilities

Based on rclone source code analysis:

| Feature | Supported |
|---------|-----------|
| Copy | Yes |
| Move | Yes |
| DirMove | Yes |
| Purge | Yes |
| About | Yes |
| SetModTime | Yes (disable for external mounts) |
| Hashes | No |
| PublicLink | Unknown |
| ServerSideMove | Yes |
| ServerSideCopy | Yes |

---

*Document generated by Architect-5 for Sprint v2.0.34*
