# TASK: Dropbox Support (#37)

## Ticket
**GitHub:** #37
**Type:** Feature - Provider Support
**Size:** M (1-2 hours)
**Priority:** High (popular request)

---

## Objective

Add Dropbox as a supported cloud provider with full OAuth flow and optimized transfer settings.

---

## Background

Dropbox is one of the most requested providers. Rclone supports Dropbox natively, so this is primarily configuration and OAuth setup.

---

## Implementation

### 1. Update CloudProvider.swift

Add Dropbox to the provider enum:

```swift
case dropbox
```

Add provider metadata:
- Display name: "Dropbox"
- Icon: Use existing or add dropbox icon
- OAuth required: Yes
- Rclone type: "dropbox"

### 2. OAuth Configuration

Dropbox OAuth requires:
- Client ID (can use rclone's built-in or custom)
- Redirect URI handling
- Token storage in Keychain

Reference existing OAuth providers (Google Drive, OneDrive) for pattern.

### 3. Chunk Size Configuration

Update `ChunkSizeConfig.swift` for Dropbox:
- Dropbox optimal chunk size: 150MB (from rclone docs)
- Add to provider-specific configuration

### 4. RcloneManager Integration

Ensure RcloneManager handles:
- `rclone config create <name> dropbox`
- OAuth token flow
- Proper flags for Dropbox operations

---

## Files to Modify

| File | Changes |
|------|---------|
| `CloudSyncApp/Models/CloudProvider.swift` | Add .dropbox case, metadata |
| `CloudSyncApp/RcloneManager.swift` | OAuth flow support |
| `CloudSyncApp/TransferEngine/ChunkSizeConfig.swift` | Add Dropbox chunk size |
| `CloudSyncApp/Assets.xcassets/` | Add Dropbox icon (if needed) |

---

## Testing

### Manual Testing Required
- [ ] Create new Dropbox remote
- [ ] Complete OAuth flow
- [ ] List files from Dropbox
- [ ] Upload test file
- [ ] Download test file
- [ ] Verify chunk size applied

### Unit Tests
- [ ] CloudProviderTests - Dropbox enum case
- [ ] ChunkSizeTests - Dropbox configuration

---

## Acceptance Criteria

- [ ] Dropbox appears in provider list
- [ ] OAuth flow completes successfully
- [ ] Can browse Dropbox files
- [ ] Upload/download works
- [ ] Chunk size properly configured (150MB)
- [ ] Tests pass
- [ ] Icon displays correctly

---

## Reference

- Rclone Dropbox docs: https://rclone.org/dropbox/
- Existing OAuth: `RcloneManager.swift` Google Drive implementation
- ChunkSizeConfig pattern: `TransferEngine/ChunkSizeConfig.swift`

---

## Notes

- Use /think for OAuth flow design
- Test with real Dropbox account
- Consider rate limits (Dropbox has them)

---

*Task created: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready"*
