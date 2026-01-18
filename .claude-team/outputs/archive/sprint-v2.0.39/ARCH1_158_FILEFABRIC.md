# Integration Study #158: FileFabric (Enterprise File Fabric)

**Architect:** Architect-1
**Date:** 2026-01-18
**Status:** Complete

---

## Executive Summary

FileFabric (Storage Made Easy Enterprise File Fabric) is an enterprise file management platform that aggregates multiple cloud storage services into a unified interface. This study examines the current CloudSync Ultra implementation and identifies a **critical issue**: FileFabric requires a server URL and permanent authentication token, but the current implementation incorrectly treats it as a standard OAuth provider that opens a browser for authentication without collecting the necessary server URL.

---

## 1. Current Implementation Status in CloudSync Ultra

### Existing Code Locations

| File | Status | Notes |
|------|--------|-------|
| `CloudSyncApp/Models/CloudProvider.swift` | Implemented | Provider type, display name, icons, colors defined |
| `CloudSyncApp/RcloneManager.swift` | **BUG** | Uses `createRemoteInteractive()` without server URL |
| `CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift` | Implemented | Calls `setupFileFabric()` |
| `CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift` | **Incomplete** | Shows generic OAuth flow without server URL field |
| `CloudSyncApp/Styles/AppTheme+ProviderColors.swift` | Implemented | Brand color defined (#663399 - Purple) |
| `CloudSyncAppTests/OAuthExpansionProvidersTests.swift` | **Misleading** | Tests pass but authentication flow is incomplete |

### Provider Configuration

```swift
// From CloudProvider.swift
case filefabric = "filefabric"

displayName: "File Fabric"
iconName: "rectangle.grid.2x2.fill"
brandColor: Color(hex: "663399")  // FileFabric Purple
rcloneType: "filefabric"
defaultRcloneName: "filefabric"
requiresOAuth: true  // Partially correct - uses permanent token, not standard OAuth
```

---

## 2. Authentication Requirements

### rclone Backend Configuration

**Backend name:** `filefabric`

**Required parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | **Yes** | URL of the Enterprise File Fabric server |
| `permanent_token` | string | **No** | Permanent Authentication Token (recommended) |

**Optional/Advanced parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| `root_folder_id` | (empty) | ID of root folder to restrict access |
| `token` | (auto) | Session token - auto-managed by rclone |
| `token_expiry` | (auto) | Token expiration - auto-managed |
| `version` | (auto) | File Fabric version - auto-managed |
| `encoding` | Special | Character encoding (Slash, Del, Ctl, InvalidUtf8, Dot) |
| `description` | (empty) | Remote description |

### Authentication Methods

FileFabric supports two authentication paths:

1. **Permanent Authentication Token (Recommended)**
   - Generated via: Enterprise File Fabric Dashboard > Security > "My Authentication Tokens" > Manage
   - Tokens are typically valid for several years
   - Best for unattended/automated access
   - Documentation: https://docs.storagemadeeasy.com/organisationcloud/api-tokens

2. **Interactive Browser Authentication**
   - Opens browser for login
   - Creates session token valid for ~1 hour
   - Session token is auto-refreshed by rclone
   - Requires user presence for initial setup

**Important:** Unlike standard OAuth providers, FileFabric ALWAYS requires the server URL first, regardless of which authentication method is used.

---

## 3. Server URL Requirements

### URL Format

The FileFabric URL must point to the specific Enterprise File Fabric instance:

| Example | Description |
|---------|-------------|
| `https://storagemadeeasy.com` | Storage Made Easy US (public cloud) |
| `https://eu.storagemadeeasy.com` | Storage Made Easy EU (public cloud) |
| `https://yourfabric.smestorage.com` | Custom enterprise instance |
| `https://files.yourcompany.com` | Self-hosted enterprise deployment |

### Enterprise Deployment Types

1. **Public Cloud (SaaS)**
   - Hosted by Storage Made Easy
   - Standard URLs provided above
   - Multi-tenant environment

2. **Private Cloud**
   - Customer-hosted infrastructure
   - Custom domain/URL
   - Single-tenant, isolated

3. **On-Premises**
   - Fully self-hosted
   - Any custom URL
   - Complete data sovereignty

---

## 4. Enterprise Features

### Multi-Cloud Aggregation

FileFabric acts as a unified gateway to multiple storage providers:
- Amazon S3, Azure Blob, Google Cloud Storage
- Dropbox, Box, OneDrive, Google Drive
- On-premises file shares (SMB/CIFS, NFS)
- FTP/SFTP servers
- Custom storage backends

### Enterprise Capabilities

| Feature | Description |
|---------|-------------|
| **Single Sign-On (SSO)** | SAML 2.0, Active Directory, LDAP integration |
| **Access Control** | Role-based permissions, folder-level ACLs |
| **Audit Logging** | Comprehensive activity tracking for compliance |
| **Data Governance** | Retention policies, legal hold, DLP |
| **File Sharing** | Secure links, expiration, password protection |
| **Versioning** | File history and recovery |
| **Encryption** | At-rest and in-transit encryption |

### Supported Operations via rclone

| Feature | Supported | Notes |
|---------|-----------|-------|
| List | Yes | Directory listing |
| Read | Yes | File download |
| Write | Yes | File upload |
| Copy | Yes | Server-side when possible |
| Move | Yes | Server-side when possible |
| Delete | Yes | File and folder deletion |
| Modification time | Yes | 1-second accuracy |

### Known Limitations

| Limitation | Impact | Workaround |
|------------|--------|------------|
| **No hash/checksum** | Sync relies on size/time only | Accept minor performance impact |
| **Empty files unsupported** | Uploaded as single-space content | Be aware of empty file handling |
| **Invalid UTF-8 handling** | Replaced (can't use in JSON) | Ensure clean filenames |
| **Server URL required** | Cannot auto-detect | Must collect from user |

---

## 5. Recommended Wizard Flow

### Current (Incomplete) Flow

1. Select FileFabric provider
2. Enter email (optional - shown due to OAuth flag)
3. Browser opens for authentication (fails without URL)
4. Test connection

### Correct Flow (To Be Implemented)

```
Step 1: Choose Provider
  -> Select "File Fabric" from Enterprise category

Step 2: Configure Settings (NEW UI REQUIRED)
  -> Server URL field (required):
     - Label: "File Fabric Server URL"
     - Placeholder: "https://yourfabric.smestorage.com"
     - Help text: "Enter your organization's File Fabric URL"
     - Validation: Must be valid HTTPS URL

  -> Authentication Method picker:
     Option A: "Permanent Token" (Recommended)
       - Token field: SecureField for permanent_token
       - Help link: "How to generate a token"

     Option B: "Browser Sign-In"
       - No additional fields
       - Info: "You'll be redirected to sign in"

Step 3: Test Connection
  -> If Token method:
     - Create rclone config with url + permanent_token
     - Test with rclone lsd
  -> If Browser method:
     - Create interactive config with url
     - Open browser for authentication
     - Wait for callback

Step 4: Success
  -> Display connected server URL
  -> Show authentication method used
```

### Required Code Changes

1. **ProviderConnectionWizardState.swift** - Add new state fields:
```swift
// Add to ProviderConnectionWizardState class
@Published var serverURL = ""
@Published var permanentToken = ""
@Published var useTokenAuth = true  // Default to token auth
```

2. **ConfigureSettingsStep.swift** - Add FileFabric-specific UI:
```swift
private var isFileFabric: Bool {
    provider == .filefabric
}

// In body, add:
else if isFileFabric {
    fileFabricConfiguration
}

@ViewBuilder
private var fileFabricConfiguration: some View {
    VStack(spacing: 20) {
        // Server URL (required)
        GroupBox {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "server.rack")
                        .font(.title2)
                        .foregroundColor(provider.brandColor)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enterprise File Fabric Server")
                            .font(.headline)
                        Text("Enter your organization's File Fabric URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                HStack {
                    Text("Server URL")
                        .frame(width: 100, alignment: .trailing)
                    TextField("https://yourfabric.smestorage.com", text: $serverURL)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding()
        }

        // Authentication method
        GroupBox {
            VStack(spacing: 16) {
                Picker("Authentication", selection: $useTokenAuth) {
                    Text("Permanent Token (Recommended)").tag(true)
                    Text("Browser Sign-In").tag(false)
                }
                .pickerStyle(.radioGroup)

                if useTokenAuth {
                    HStack {
                        Text("Token")
                            .frame(width: 100, alignment: .trailing)
                        SecureField("Paste your permanent token", text: $permanentToken)
                            .textFieldStyle(.roundedBorder)
                    }

                    Link("Generate token in File Fabric dashboard",
                         destination: URL(string: "\(serverURL)/app/#security/tokens")!)
                        .font(.caption)
                }
            }
            .padding()
        }
    }
}
```

3. **RcloneManager.swift** - Implement proper setup:
```swift
func setupFileFabric(
    remoteName: String,
    serverURL: String,
    permanentToken: String? = nil
) async throws {
    if let token = permanentToken, !token.isEmpty {
        // Token-based authentication
        let params: [String: String] = [
            "url": serverURL,
            "permanent_token": token
        ]
        try await createRemote(name: remoteName, type: "filefabric", parameters: params)
    } else {
        // Interactive browser authentication
        // Still need to set URL first
        let params: [String: String] = ["url": serverURL]
        try await createRemote(name: remoteName, type: "filefabric", parameters: params)
        // Then trigger interactive auth
        try await createRemoteInteractive(name: remoteName, type: "filefabric")
    }
}
```

4. **TestConnectionStep.swift** - Update case handling:
```swift
case .filefabric:
    try await rclone.setupFileFabric(
        remoteName: rcloneName,
        serverURL: serverURL,  // From wizard state
        permanentToken: permanentToken.isEmpty ? nil : permanentToken
    )
```

5. **CloudProvider.swift** - Consider removing from OAuth list:
```swift
// FileFabric is a hybrid - it can use tokens OR interactive
// Consider creating a new category: requiresServerURL
var requiresServerURL: Bool {
    switch self {
    case .filefabric, .quatrix, .nextcloud, .owncloud, .seafile:
        return true
    default:
        return false
    }
}
```

---

## 6. Testing Recommendations

### Unit Tests

```swift
// FileFabricIntegrationTests.swift

func testFileFabricRequiresServerURL() {
    let provider = CloudProviderType.filefabric
    // Once implemented:
    // XCTAssertTrue(provider.requiresServerURL)
}

func testFileFabricProperties() {
    let provider = CloudProviderType.filefabric
    XCTAssertEqual(provider.displayName, "File Fabric")
    XCTAssertEqual(provider.rcloneType, "filefabric")
    XCTAssertEqual(provider.iconName, "rectangle.grid.2x2.fill")
}

func testFileFabricTokenConfiguration() async throws {
    // Mock test - verify correct rclone command is built
    let expectedParams = [
        "url": "https://test.smestorage.com",
        "permanent_token": "test-token"
    ]
    // Verify createRemote is called with these params
}
```

### Manual Testing Checklist

- [ ] Verify server URL field appears in wizard
- [ ] Test URL validation (must be HTTPS)
- [ ] Test with token authentication (Storage Made Easy demo account)
- [ ] Test with browser authentication flow
- [ ] Verify error handling for invalid URL
- [ ] Verify error handling for invalid token
- [ ] Test file listing after connection
- [ ] Test upload/download operations

---

## 7. Enterprise Considerations

### SSO Integration

When FileFabric is configured with enterprise SSO:
- Browser authentication redirects to corporate IdP
- SAML assertion returned to FileFabric
- Session token issued to rclone

**Implication:** Token-based auth may be preferred for CI/CD or automated scenarios where browser auth is not feasible.

### Multi-Tenant Deployments

Enterprise customers may have:
- Multiple FileFabric instances (prod/staging/dev)
- Different URLs for different business units
- Regional deployments for compliance

**Implication:** Users may need to connect multiple FileFabric remotes with different server URLs.

### Compliance Requirements

Organizations using FileFabric often have:
- Audit logging requirements
- Data residency constraints
- Access review processes

**Implication:** Token management becomes critical - expired/revoked tokens should fail gracefully.

---

## 8. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Current flow missing server URL | **High** | Connection fails without URL - users cannot connect |
| Token expiration not handled | Medium | Implement token refresh or clear error messaging |
| Self-signed certificates | Medium | Consider adding certificate verification bypass option |
| Enterprise firewall blocks rclone | Low | Document required outbound connections |

---

## 9. Implementation Priority

**Priority: HIGH**

The current implementation is fundamentally broken for FileFabric. Users cannot connect because the server URL is never collected, causing the rclone configuration to fail.

### Recommended Sprint Tasks

1. **Add server URL field to wizard** - Essential for any connection
2. **Add permanent token field** - Preferred auth method
3. **Update RcloneManager.setupFileFabric()** - Accept URL and token params
4. **Update TestConnectionStep** - Pass new params through
5. **Add URL validation** - Ensure HTTPS and valid format
6. **Add provider-specific help text** - Guide enterprise users
7. **Consider `requiresServerURL` property** - Generalize for similar providers

---

## References

- rclone FileFabric documentation: https://rclone.org/filefabric/
- Storage Made Easy (FileFabric): https://storagemadeeasy.com/
- FileFabric API Tokens documentation: https://docs.storagemadeeasy.com/organisationcloud/api-tokens
- Enterprise File Fabric Overview: https://www.intrepidinc.com/enterprise-file-fabric/

---

## Appendix A: rclone Configuration Examples

### Token-Based Configuration (Recommended)

```ini
[enterprise_files]
type = filefabric
url = https://files.company.com
permanent_token = YOUR_TOKEN_HERE
```

CLI command:
```bash
rclone config create enterprise_files filefabric \
    url=https://files.company.com \
    permanent_token=YOUR_TOKEN_HERE
```

### Interactive Browser Configuration

```bash
rclone config create enterprise_files filefabric \
    url=https://files.company.com
# Then run:
rclone config reconnect enterprise_files:
# Browser opens for authentication
```

### Test Connection

```bash
rclone lsd enterprise_files:
rclone ls enterprise_files:/Documents
```

---

## Appendix B: Similar Providers Requiring Server URL

| Provider | URL Required | Auth Methods |
|----------|--------------|--------------|
| **FileFabric** | Yes | Token, Browser SSO |
| Quatrix | Yes | API key, Browser OAuth |
| Nextcloud | Yes | App password, OAuth |
| ownCloud | Yes | App password, OAuth |
| Seafile | Yes | Username/password, Token |
| WebDAV | Yes | Username/password |

**Recommendation:** Create a unified "Server URL + Credentials" wizard flow that can be reused across all these enterprise/self-hosted providers.
