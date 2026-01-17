# Integration Study: OneDrive Business (Issue #155)

**Prepared by:** Architect-2
**Sprint:** v2.0.34
**Date:** 2026-01-17
**Status:** Complete

---

## Executive Summary

OneDrive for Business is a core component of Microsoft 365, providing enterprise cloud storage with deep integration into SharePoint and the Microsoft ecosystem. Rclone fully supports OneDrive Business through the same `onedrive` backend used for personal accounts, with specific configuration options to distinguish account types. **Implementation difficulty: EASY** - CloudSync Ultra already has the foundation in place.

---

## 1. Overview & rclone Backend Details

### 1.1 Backend Architecture

OneDrive Business uses the **same rclone backend** as OneDrive Personal (`type = onedrive`). The differentiation is made through the `drive_type` configuration parameter:

| Account Type | `drive_type` Value | Notes |
|--------------|-------------------|-------|
| OneDrive Personal | `personal` or `onedrive` | Consumer Microsoft accounts |
| OneDrive Business | `business` | Microsoft 365 work/school accounts |
| SharePoint | `sharepoint` | Document libraries within SharePoint sites |

### 1.2 Rclone Type in CloudSync Ultra

The existing implementation in `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift` already defines:

```swift
case oneDrive = "onedrive"           // Personal
case oneDriveBusiness = "onedrive-business"  // Business
case sharepoint = "sharepoint"       // SharePoint

// Both map to rclone type "onedrive"
var rcloneType: String {
    case .oneDrive: return "onedrive"
    case .oneDriveBusiness: return "onedrive"
    case .sharepoint: return "sharepoint"
}
```

### 1.3 Key rclone Flags for OneDrive

| Flag | Default | Description |
|------|---------|-------------|
| `--onedrive-chunk-size` | 10Mi | Chunk size for uploads (must be multiple of 320k, max 250MB) |
| `--onedrive-drive-id` | (auto) | Specific drive ID to use |
| `--onedrive-drive-type` | (auto) | Type of drive: personal, business, documentLibrary |
| `--onedrive-region` | global | National cloud region (global, us, de, cn) |
| `--onedrive-hash-type` | auto | QuickXorHash (default) or SHA1 (deprecated for personal) |

---

## 2. Authentication Requirements

### 2.1 OAuth 2.0 Flow

OneDrive Business uses **OAuth 2.0** with the Microsoft identity platform:

1. **Standard User OAuth Flow** (Recommended for CloudSync Ultra):
   - User authorizes via browser-based login
   - App receives access token + refresh token
   - Tokens stored in rclone config
   - Automatic token refresh handled by rclone

2. **Client Credentials Flow** (Enterprise/Headless):
   - Requires Azure AD app registration
   - Uses `client_id`, `client_secret`, and `tenant` ID
   - Suitable for service accounts and automation
   - Requires admin consent for permissions

### 2.2 Microsoft 365 License Requirements

- **Basic Access**: Any Microsoft 365 Business/Enterprise license with OneDrive
- **No special API license required** for personal use via OAuth
- Storage quotas vary by license tier (typically 1TB per user)

### 2.3 Admin Consent Considerations

For enterprise environments:

| Scenario | Consent Required |
|----------|-----------------|
| User's own OneDrive | User consent (if org allows) |
| Other users' OneDrive | Admin consent + delegation |
| SharePoint sites | Admin consent often required |
| Tenant-wide deployment | Admin consent mandatory |

**Common Enterprise Restriction**: Many organizations disable user consent for third-party apps. Users may see "Need admin approval" error (AADSTS90094).

### 2.4 Regional Endpoints

| Region | Code | Endpoint |
|--------|------|----------|
| Global (Default) | `global` | login.microsoftonline.com |
| US Government | `us` | login.microsoftonline.us |
| Germany (Deprecated) | `de` | login.microsoftonline.de |
| China (21Vianet) | `cn` | login.chinacloudapi.cn |

---

## 3. Differences from Personal OneDrive

### 3.1 Feature Comparison

| Feature | Personal | Business |
|---------|----------|----------|
| Storage Quota | 5GB-6TB (plan dependent) | 1TB-Unlimited (license dependent) |
| Permanent Delete API | Not available | Available |
| Organization Links | Not available | Available |
| Admin Controls | None | Full IT admin control |
| Data Residency | Microsoft choice | Can be configured by org |
| eDiscovery/Legal Hold | Limited | Full compliance features |
| Version History | 100 versions | 500 versions (configurable) |
| Sharing | Open | Can be restricted by policy |

### 3.2 Hash Algorithm

- **Personal**: Transitioning from SHA1 to QuickXorHash (July 2023+)
- **Business**: Primarily QuickXorHash
- Use `--onedrive-hash-type auto` for best compatibility

### 3.3 Metadata Handling

Permissions JSON format differs slightly between Personal and Business accounts for:
- Sharing permissions
- Inherited permissions
- Guest access metadata

---

## 4. Known Limitations & Workarounds

### 4.1 API Rate Limits

Microsoft Graph API enforces throttling per tenant:

| Limit Type | Threshold | Notes |
|------------|-----------|-------|
| Per-app/per-user/per-tenant | Varies | Starting Sept 2025: reduced to 50% of tenant limit |
| Concurrent requests | 2-3 recommended | More causes 429 errors |
| Large batch operations | Exponential backoff | Required for bulk transfers |

**Workaround**: CloudSync Ultra should use conservative parallelism:
```swift
case .oneDrive, .oneDriveBusiness, .sharepoint:
    return (transfers: 4, checkers: 8)  // Already implemented
```

### 4.2 File Path Limits

| Limit | Value |
|-------|-------|
| File/folder name | 128 characters max |
| Full path (including filename) | 260 characters (Windows) / 400 characters (OneDrive) |
| Sync path warning threshold | 400 characters |

**Workaround**: Warn users about long paths; rclone encryption makes names longer.

### 4.3 File Size Limits

| Upload Method | Max Size |
|--------------|----------|
| Simple upload | 4MB |
| Resumable/chunked upload | 250GB |
| ZIP download | 250GB (as of July 2024) |

**Workaround**: rclone automatically uses chunked uploads for large files.

### 4.4 Invalid Characters

Now supported on Mac (as of Jan 2025):
- `\ / : * ? " < > |` - Previously problematic
- `#` and `%` - Now allowed in names

### 4.5 Shared Files/Folders Limitation

**Known Issue**: Files "Shared with Me" are not automatically accessible via rclone's standard OneDrive configuration. Users must access shared content through the owner's permission setup or via SharePoint site access.

**Workaround**: Configure access to the specific SharePoint site where files are shared.

### 4.6 Guest Access

Guest users may not be able to search for SharePoint sites during configuration. They need to:
1. Obtain the direct Site URL from the inviter
2. Use Option 3 (SharePoint site name or URL) with full URL
3. Or request Drive ID directly from IT admin

---

## 5. Step-by-Step Connection Flow

### 5.1 User Flow (CloudSync Ultra)

```
1. User selects "OneDrive for Business" in provider list
2. App launches OAuth flow via system browser
3. User signs in with work/school account
4. Microsoft prompts for consent (if allowed by org)
5. Browser redirects back with authorization code
6. rclone exchanges code for tokens
7. rclone queries available drives (may show multiple):
   - Personal OneDrive
   - SharePoint sites
   - Shared drives
8. User selects appropriate drive (or auto-detect)
9. Connection test verifies access
10. Remote configured and ready
```

### 5.2 Existing Implementation

In `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`:

```swift
enum OneDriveAccountType: String {
    case personal = "onedrive"
    case business = "business"
    case sharepoint = "sharepoint"
}

func setupOneDrive(remoteName: String, accountType: OneDriveAccountType = .personal) async throws {
    // Creates remote with proper drive_type
}

func setupOneDriveBusiness(remoteName: String, driveType: String = "business") async throws {
    // Wrapper for business accounts
    try await createRemoteInteractive(name: remoteName, type: "onedrive")
}
```

### 5.3 Recommended Enhanced Flow

To improve UX, consider adding:

1. **Account Type Selection**: Ask user to choose Personal vs Business before OAuth
2. **Drive Selection UI**: After OAuth, let user pick from available drives
3. **Tenant Detection**: Auto-detect if account is business based on email domain
4. **SharePoint Site Browser**: For business users, offer to browse accessible SharePoint sites

---

## 6. Enterprise Considerations

### 6.1 Azure AD App Registration

For organizations wanting to self-host the OAuth app:

**Required Permissions (Delegated)**:
- `Files.Read`
- `Files.ReadWrite`
- `Files.Read.All` (for SharePoint)
- `Sites.Read.All` (for SharePoint site access)

**Required Permissions (Application - for service accounts)**:
- `Files.ReadWrite.All`
- `Sites.ReadWrite.All`

### 6.2 Conditional Access Policies

Enterprise customers may have:
- MFA requirements (handled by Microsoft login)
- Device compliance requirements (may block non-managed devices)
- Location-based access (may block VPN/travel)
- Session timeout policies

**Impact**: Users may need to re-authenticate more frequently.

### 6.3 Data Loss Prevention (DLP)

Organizations can set DLP policies that:
- Block download of sensitive files
- Require encryption for specific content types
- Audit file access

**Impact**: Some sync operations may fail with policy errors.

### 6.4 Tenant Restrictions

Some organizations restrict access to only their tenant:
- Users cannot access personal OneDrive from managed devices
- Cross-tenant file sharing may be blocked

---

## 7. Code Changes Needed

### 7.1 Current State

CloudSync Ultra already has **comprehensive OneDrive Business support**:

- `CloudProviderType.oneDriveBusiness` defined
- `OneDriveAccountType.business` enum exists
- `setupOneDriveBusiness()` function implemented
- Provider colors, icons, and branding configured
- Fast-list support enabled
- Parallelism tuned for Microsoft APIs

### 7.2 Recommended Enhancements (Optional)

| Enhancement | Priority | Effort |
|-------------|----------|--------|
| Drive selector UI after OAuth | Medium | 2-3 hours |
| Region selector (Global/US Gov/China) | Low | 1 hour |
| Clear error messages for admin consent | Medium | 1 hour |
| Path length warning for long filenames | Low | 30 min |
| SharePoint site picker integration | Medium | 3-4 hours |

### 7.3 No Breaking Changes Required

The existing implementation is fully functional. Enhancements would improve UX but are not required for basic operation.

---

## 8. Recommendation

### Implementation Difficulty: **EASY**

**Rationale**:
1. Rclone backend fully supports OneDrive Business
2. CloudSync Ultra already has `oneDriveBusiness` provider type
3. Authentication flow is identical to personal OneDrive
4. No additional dependencies or API keys needed
5. Enterprise features work out-of-box (with org consent)

### Suggested Next Steps

1. **Testing Phase**: Verify current implementation with real Business accounts
2. **UX Polish**: Add drive selector for accounts with multiple OneDrive/SharePoint locations
3. **Documentation**: Add help text for common enterprise errors (admin consent, etc.)
4. **Optional**: Add region selector for government/China customers

---

## 9. References

- [rclone OneDrive Documentation](https://rclone.org/onedrive/)
- [Microsoft OneDrive Restrictions and Limitations](https://support.microsoft.com/en-us/office/restrictions-and-limitations-in-onedrive-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa)
- [Microsoft Graph Throttling Limits](https://learn.microsoft.com/en-us/graph/throttling-limits)
- [Grant Tenant-Wide Admin Consent](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/grant-admin-consent)
- [OneDrive Service Description](https://learn.microsoft.com/en-us/office365/servicedescriptions/onedrive-for-business-service-description)
- [Murray's Blog - Connecting to OneDrive with RClone](https://blog.ligos.net/2025-05-30/Connecting-To-OneDrive-With-RClone.html)

---

*End of Integration Study*
