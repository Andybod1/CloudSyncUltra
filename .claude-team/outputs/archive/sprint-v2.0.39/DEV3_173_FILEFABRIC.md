# Bug #173: FileFabric Missing Server URL Field - FIXED

**Developer:** Dev-3
**Date:** 2026-01-18
**Status:** COMPLETE

## Bug Description
FileFabric requires a server URL before authentication, but the wizard did not collect it, causing setup to be broken.

## Root Cause
The FileFabric provider setup was calling `setupFileFabric()` without passing the required server URL parameter. This meant rclone could not authenticate because it did not know which FileFabric server to connect to.

## Changes Made

### 1. RcloneManager.swift
Updated `setupFileFabric()` to accept and pass the server URL parameter:

**File:** `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`

```swift
// Before:
func setupFileFabric(remoteName: String) async throws {
    try await createRemoteInteractive(name: remoteName, type: "filefabric")
}

// After:
func setupFileFabric(remoteName: String, serverURL: String) async throws {
    // File Fabric requires a server URL before OAuth authentication
    // The URL is the base URL of your File Fabric server (e.g., https://yourfabric.smestorage.com)
    var params: [String: String] = [:]
    if !serverURL.isEmpty {
        params["url"] = serverURL
    }
    try await createRemoteInteractive(name: remoteName, type: "filefabric", additionalParams: params)
}
```

### 2. ConfigureSettingsStep.swift
Added FileFabric-specific UI with server URL field:

**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift`

Changes:
- Added `isFileFabric` computed property for provider detection
- Updated `authenticationDescription` to show FileFabric-specific message
- Added server URL input field in `oauthConfiguration` view with:
  - Server Configuration GroupBox with server.rack icon
  - Informational notice explaining the requirement
  - Text field for server URL with placeholder "https://yourfabric.smestorage.com"

### 3. ProviderConnectionWizardView.swift
Confirmed `serverURL` is already passed to both ConfigureSettingsStep and TestConnectionStep.

**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/ProviderConnectionWizardView.swift`

### 4. TestConnectionStep.swift
Confirmed FileFabric case already passes serverURL to setupFileFabric():

**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift`

```swift
case .filefabric:
    try await rclone.setupFileFabric(remoteName: rcloneName, serverURL: serverURL)
```

## FileFabric Config Format
The resulting rclone config will look like:
```
[filefabric]
type = filefabric
url = https://yourfabric.smestorage.com
token = <permanent-token>
```

## Testing
- Build verified: `** BUILD SUCCEEDED **`
- All changes compile without errors

## User Experience
1. User selects FileFabric as provider
2. User is shown a new "Server Configuration" section with an info notice
3. User enters their organization's File Fabric server URL
4. User proceeds to OAuth authentication in browser
5. Connection is established successfully

## Files Modified
1. `/Users/antti/claude/CloudSyncApp/RcloneManager.swift` - Updated setupFileFabric() signature
2. `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift` - Added FileFabric UI
3. `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/ProviderConnectionWizardView.swift` - Passes serverURL (already configured)
4. `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift` - Passes serverURL (already configured)
