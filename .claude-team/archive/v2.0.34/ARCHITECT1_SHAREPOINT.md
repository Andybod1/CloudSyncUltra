# SharePoint Integration Study for CloudSync Ultra

**GitHub Issue:** #156
**Date:** 2026-01-17
**Author:** Architect-1
**Sprint:** v2.0.34

---

## Executive Summary

SharePoint integration for CloudSync Ultra is **already partially implemented** in the codebase. The `CloudProviderType.sharepoint` case exists with proper rclone type mapping. However, full enterprise support requires understanding Microsoft's authentication complexity and SharePoint-specific limitations.

**Recommendation: MEDIUM difficulty** - Core OAuth flow exists, but enterprise scenarios require additional configuration options and UI guidance.

---

## 1. Overview & Rclone Backend Details

### Backend Type

SharePoint uses the **`onedrive`** backend in rclone with `drive_type` set to `"sharepoint"`. As of rclone v1.67+, there is a dedicated `sharepoint` backend type, but the traditional approach via OneDrive backend remains widely used and well-documented.

**Current CloudSync Implementation:**
```swift
// CloudSyncApp/Models/CloudProvider.swift:283
case .sharepoint: return "sharepoint"

// CloudSyncApp/RcloneManager.swift:1144-1147
case .sharepoint:
    args.append("drive_type")
    args.append("sharepoint")
```

### Rclone Configuration Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `type` | `onedrive` or `sharepoint` | Yes |
| `drive_type` | `sharepoint` | Yes |
| `client_id` | Azure App Registration ID | Recommended |
| `client_secret` | Azure App Secret | Recommended |
| `token` | OAuth2 token (auto-generated) | Auto |
| `drive_id` | Specific document library ID | Optional |
| `site_id` | SharePoint site ID | Optional |
| `tenant` | Azure AD tenant ID | Enterprise |
| `auth_url` | Custom auth endpoint | Enterprise |
| `token_url` | Custom token endpoint | Enterprise |

### Path Format

```
remotename:path/to/folder
remotename:Documents/Project Files
remotename:Shared Documents/Archive
```

---

## 2. Authentication Requirements

### Authentication Methods

#### Method 1: Interactive OAuth (Consumer/Personal)
- Opens browser for Microsoft login
- User grants permissions interactively
- Token stored in rclone config
- **Best for:** Personal Microsoft 365 accounts

#### Method 2: App Registration OAuth (Enterprise)
- Requires Azure AD App Registration
- Admin must pre-consent permissions
- Custom `client_id` and `client_secret`
- **Best for:** Corporate/enterprise deployments

#### Method 3: Client Credentials (Server-to-Server)
- Application-only access without user
- Requires `client_credentials = true`
- Needs `Sites.ReadWrite.All` or `Sites.FullControl.All`
- **Best for:** Automated/headless sync scenarios

### Required Microsoft Graph Permissions

| Permission | Type | Use Case |
|------------|------|----------|
| `Files.ReadWrite.All` | Delegated | User-based file access |
| `Sites.ReadWrite.All` | Delegated | Site collection access |
| `Sites.Selected` | Application | Specific site access (recommended for enterprise) |
| `Sites.FullControl.All` | Application | Full control (admin consent required) |

### Azure AD App Registration Setup

1. Navigate to [Azure Portal](https://portal.azure.com) > Azure Active Directory > App registrations
2. Create new registration:
   - Name: "CloudSync Ultra" (or custom)
   - Supported account types: "Accounts in this organizational directory only" (single tenant) or "Accounts in any organizational directory" (multi-tenant)
   - Redirect URI: `http://localhost:53682/` (Web type, trailing slash required)
3. Add API permissions:
   - Microsoft Graph > Delegated > `Files.ReadWrite.All`
   - Microsoft Graph > Delegated > `Sites.ReadWrite.All`
4. Create client secret under Certificates & secrets
5. Note: Client ID, Tenant ID, and Client Secret

**Important:** Using rclone's default client ID may result in throttling. Custom App Registration is recommended.

---

## 3. Step-by-Step Connection Flow

### For Personal/Small Business Users

1. User selects "SharePoint" provider in CloudSync Ultra
2. App triggers `rclone config create` with `type=sharepoint`
3. Browser opens for Microsoft OAuth
4. User logs in with Microsoft 365 account
5. User grants requested permissions
6. Rclone receives OAuth token
7. User selects SharePoint site from list (or searches)
8. User selects document library (drive)
9. Configuration saved to rclone config
10. CloudSync verifies connection with `rclone lsd`

### For Enterprise Users (Custom App Registration)

1. IT Admin pre-registers app in Azure AD
2. Admin grants tenant-wide consent
3. Admin provides user with:
   - Client ID
   - Client Secret (if applicable)
   - Tenant ID
4. User enters credentials in CloudSync Ultra "Advanced" settings
5. App configures rclone with custom OAuth endpoints:
   ```
   auth_url = https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize
   token_url = https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token
   ```
6. User authenticates via browser
7. Site/library selection proceeds as normal

### Token Refresh

- OAuth tokens expire after 1 hour by default
- Rclone handles automatic token refresh using refresh_token
- For client credentials flow, tokens have no refresh (re-auth needed)

---

## 4. Known Limitations & Workarounds

### File Size Limits

| Limit Type | Value | Notes |
|------------|-------|-------|
| Single file upload (simple) | 250 MB | Via single API call |
| Single file upload (session) | 250 GB | Via upload session (chunked) |
| Path length | 400 characters | Including filename |
| Filename length | 255 characters | Individual file/folder name |

**Workaround:** CloudSync should use rclone's chunked upload for files > 250MB (automatic).

### API Rate Limits

| Limit | Value |
|-------|-------|
| REST API calls | 600/minute |
| Total API calls | 1,200/minute (429 threshold) |
| Resource units | Varies by API complexity |

**Workaround:** Configure CloudSync to use conservative parallelism:
```swift
// Already implemented in CloudProvider.swift:653-654
case .oneDrive, .oneDriveBusiness, .sharepoint:
    return (transfers: 4, checkers: 8)
```

Recommend adding `--tpslimit 10` for large sync operations.

### Special Characters

| Character | Behavior |
|-----------|----------|
| `~ $ # % * : < > ? / \ |` | Blocked or translated |
| `#` | Translated to full-width variant |
| `%` followed by hex | May cause issues |

**Workaround:** Document that users should avoid special characters. Consider adding filename validation in CloudSync UI.

### Office File Locking

SharePoint may return "item not found" errors when replacing Office files (.docx, .xlsx, etc.) due to Microsoft's co-authoring features.

**Workaround:** Use `--backup-dir` flag or implement retry logic with delay.

### Directory Listing Limits

- Stable at 50,000 files per folder
- Errors may occur at 100,000+ files

**Workaround:** Recommend users organize into subfolders.

### Encryption Path Length

When using rclone crypt with SharePoint:
- Maximum pre-encryption filename: **143 characters**
- Due to 400-char path limit + encryption overhead

---

## 5. Enterprise Considerations

### Admin Consent Requirements

- `Sites.ReadWrite.All` and higher require tenant admin consent
- Non-admin users cannot self-consent to these permissions
- Admin consent workflow can be configured in Azure AD

**Recommendation:** Add documentation/UI explaining admin consent for enterprise users.

### Conditional Access

SharePoint can be protected by Entra ID Conditional Access policies:
- MFA requirements
- Device compliance checks
- Location-based restrictions

**Impact:** OAuth flow may fail or require additional authentication steps. CloudSync should handle this gracefully with clear error messages.

### Sites.Selected Permission (Recommended)

For security-conscious enterprises:
1. Use `Sites.Selected` instead of `Sites.ReadWrite.All`
2. Admin explicitly grants access to specific sites
3. Limits blast radius if credentials compromised

**Recommendation:** Document this as best practice for enterprise.

### Compliance & Data Residency

- SharePoint respects Microsoft 365 data residency settings
- Audit logs available via Microsoft 365 Compliance Center
- DLP policies may block certain file types

**Recommendation:** Add note in UI that corporate policies may affect sync.

### Azure ACS Deprecation

- Azure Access Control Services (legacy) retiring April 2026
- All new integrations should use Entra ID (Azure AD) app model
- **CloudSync is already using the modern approach** (no action needed)

---

## 6. Current Implementation Status

### Already Implemented

| Component | Status | Location |
|-----------|--------|----------|
| Provider enum case | Done | `CloudProvider.swift:49` |
| Display name | Done | `CloudProvider.swift:107` |
| Icon | Done | `CloudProvider.swift:166` |
| Brand color | Done | `CloudProvider.swift:225` |
| Rclone type mapping | Done | `CloudProvider.swift:283` |
| OAuth flag | Done | `CloudProvider.swift:386` |
| Parallelism config | Done | `CloudProvider.swift:653` |
| Setup method | Done | `RcloneManager.swift:1538-1541` |
| Account type enum | Done | `RcloneManager.swift:526` |

### Needs Enhancement

| Component | Priority | Description |
|-----------|----------|-------------|
| Custom OAuth UI | Medium | Fields for client_id, client_secret, tenant |
| Site/Library picker | Medium | UI to select from available sites |
| Error handling | Medium | SharePoint-specific error messages |
| Rate limit handling | Low | Add `--tpslimit` option |
| Enterprise docs | Low | Admin setup guide |

---

## 7. Recommended Code Changes

### No Immediate Code Changes Required

The current implementation handles basic SharePoint setup via the existing OAuth flow. The `setupSharePoint()` method in `RcloneManager.swift` correctly delegates to `createRemoteInteractive()`.

### Future Enhancements (Optional)

1. **Add Enterprise Configuration UI**
   ```swift
   // Add to ProviderConnectionWizard for sharepoint
   struct SharePointEnterpriseSettings: View {
       @State var clientId: String = ""
       @State var clientSecret: String = ""
       @State var tenantId: String = ""
       @State var useEnterpriseAuth: Bool = false
   }
   ```

2. **Add Site/Library Picker**
   - Use `rclone config` interactive mode to list sites
   - Or implement Microsoft Graph API calls directly

3. **Add SharePoint-Specific Error Messages**
   ```swift
   case sharePointAdminConsentRequired
   case sharePointThrottled
   case sharePointSiteNotFound
   ```

---

## 8. Implementation Difficulty Assessment

| Aspect | Difficulty | Notes |
|--------|------------|-------|
| Basic OAuth flow | Easy | Already works |
| Personal accounts | Easy | Standard flow |
| Business accounts | Medium | May need drive_type guidance |
| Enterprise custom app | Medium | Needs additional UI fields |
| Client credentials | Hard | Headless auth complexity |
| Multi-tenant apps | Hard | Complex Azure config |

### Overall Rating: MEDIUM

**Rationale:**
- Core functionality already exists and works
- Standard Microsoft 365 users can connect today
- Enterprise scenarios need UI enhancements but not architectural changes
- Microsoft's auth complexity is the main challenge, not rclone integration

---

## 9. Testing Recommendations

1. **Personal Microsoft 365 Account**
   - Test basic OAuth flow
   - Verify site selection works

2. **Business Account (Microsoft 365 Business)**
   - Test with OneDrive for Business + SharePoint
   - Verify correct drive_type is used

3. **Enterprise with Custom App**
   - Test with pre-registered Azure app
   - Verify admin consent flow

4. **Rate Limit Testing**
   - Sync large folder (10,000+ files)
   - Monitor for 429 errors

5. **Special Character Testing**
   - Files with `#`, `%`, spaces
   - Verify translation behavior

---

## 10. References

### Official Documentation
- [rclone OneDrive Backend](https://rclone.org/onedrive/)
- [SharePoint Online Limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)
- [Avoid SharePoint Throttling](https://learn.microsoft.com/en-us/sharepoint/dev/general-development/how-to-avoid-getting-throttled-or-blocked-in-sharepoint-online)
- [SharePoint Admin APIs Auth](https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/sharepoint-admin-apis-authentication-and-authorization)
- [Granting Entra ID App-Only Access](https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/security-apponly-azuread)

### Community Resources
- [Rclone Forum - SharePoint Configuration](https://forum.rclone.org/t/sharepoint-configuration/23448)
- [Connecting rclone to SharePoint Online](https://blog.ssb-tech.net/posts/using-rclone-for-sharepoint-online/)
- [OneDrive/SharePoint Filename Restrictions](https://support.microsoft.com/en-us/office/restrictions-and-limitations-in-onedrive-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa)

---

## Appendix A: Sample Rclone Configuration

### Basic SharePoint (Interactive OAuth)
```ini
[sharepoint]
type = onedrive
drive_type = sharepoint
token = {"access_token":"...","token_type":"Bearer","refresh_token":"...","expiry":"..."}
drive_id = b!xxxxxxxxxxxxx
```

### Enterprise SharePoint (Custom App)
```ini
[sharepoint-enterprise]
type = onedrive
client_id = ca71b49a-xxxx-xxxx-xxxx-xxxxxxxxxxxx
client_secret = OjG8Qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
tenant = a0756xxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
auth_url = https://login.microsoftonline.com/a0756xxx.../oauth2/v2.0/authorize
token_url = https://login.microsoftonline.com/a0756xxx.../oauth2/v2.0/token
drive_type = sharepoint
token = {"access_token":"...","token_type":"Bearer","refresh_token":"...","expiry":"..."}
drive_id = b!xxxxxxxxxxxxx
```

### Client Credentials (Headless)
```ini
[sharepoint-headless]
type = onedrive
client_id = ca71b49a-xxxx-xxxx-xxxx-xxxxxxxxxxxx
client_secret = OjG8Qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
tenant = a0756xxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
client_credentials = true
drive_type = sharepoint
drive_id = b!xxxxxxxxxxxxx
```

---

*End of Integration Study*
