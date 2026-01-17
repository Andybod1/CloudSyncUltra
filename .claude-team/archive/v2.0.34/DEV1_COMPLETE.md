# Dev-1 Task Complete: GitHub Issue #159 - Google Photos OAuth Scope Fix

## Sprint: v2.0.34
## Date: 2026-01-17
## Status: COMPLETE

## Summary

Fixed Google Photos OAuth scope issue that caused `403 PERMISSION_DENIED - insufficient authentication scopes` error. The fix adds Google Photos as a supported provider with the correct `read_only=true` parameter to request the `photoslibrary.readonly` scope during OAuth.

## Root Cause

Google Photos API requires the `photoslibrary.readonly` scope to be explicitly requested during OAuth authentication. Without this scope, users could connect but would receive permission denied errors when trying to browse photos.

## Changes Made

### 1. CloudSyncApp/Models/CloudProvider.swift

Added `googlePhotos` case to `CloudProviderType` enum with:
- **Case definition**: `case googlePhotos = "gphotos"`
- **Display name**: "Google Photos"
- **Icon**: `photo.on.rectangle.angled`
- **Brand color**: Google Blue (#4285F4)
- **rcloneType**: `gphotos`
- **defaultRcloneName**: `gphotos`
- **requiresOAuth**: Added to OAuth providers list

### 2. CloudSyncApp/RcloneManager.swift

Added new `setupGooglePhotos` method in the "OAuth Services Expansion: Media & Consumer" section:

```swift
func setupGooglePhotos(remoteName: String) async throws {
    // Google Photos uses OAuth - opens browser for authentication
    // CRITICAL: Must pass read_only=true to request photoslibrary.readonly scope
    // Without this, Google returns 403 PERMISSION_DENIED - insufficient authentication scopes
    // See: https://rclone.org/googlephotos/#standard-options
    try await createRemoteInteractive(
        name: remoteName,
        type: "gphotos",
        additionalParams: ["read_only": "true"]
    )
}
```

### 3. CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift

Added case handler for `.googlePhotos` in the `configureRemoteWithRclone()` switch statement:

```swift
case .googlePhotos:
    try await rclone.setupGooglePhotos(remoteName: rcloneName)
```

## Technical Details

The key fix is passing `read_only=true` as an additional parameter when creating the Google Photos remote. This translates to the rclone command:

```bash
rclone config create <name> gphotos read_only true
```

This ensures the OAuth flow requests the `photoslibrary.readonly` scope, which grants permission to read photos without write access.

## Acceptance Criteria Status

- [x] Google Photos OAuth requests correct scope (read_only=true parameter added)
- [x] Users can browse photos without terminal workaround (provider now available in wizard)
- [x] Existing remotes continue to work (no changes to existing remote handling)

## Files Modified

1. `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`
2. `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`
3. `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift`

## Testing Notes

To verify the fix:
1. Open CloudSync Ultra
2. Add a new provider
3. Select "Google Photos" from the provider list
4. Complete OAuth flow in browser
5. Verify photos can be browsed without 403 errors

## References

- GitHub Issue: #159
- rclone Google Photos documentation: https://rclone.org/googlephotos/#standard-options
- Previous workaround documented in: `docs/providers/GOOGLE_PHOTOS_FIX.md`
