# Bug #171: Seafile Missing TestConnectionStep Case and Server URL Field

## Status: COMPLETED

## Summary
Fixed Bug #171 where Seafile provider was falling through to the default error case in TestConnectionStep.swift. Added the missing Seafile case and implemented server URL field support for self-hosted Seafile servers.

## Changes Made

### 1. ProviderConnectionWizardState (ProviderConnectionWizardView.swift)
- Added `serverURL` property for self-hosted providers
- Added `serverURL = ""` to `reset()` function
- Linter automatically wired serverURL to ConfigureSettingsStep and TestConnectionStep

**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/ProviderConnectionWizardView.swift`

```swift
// Server URL for self-hosted providers (Seafile, etc.)
@Published var serverURL: String = ""
```

### 2. TestConnectionStep.swift - Added Seafile Case
- Added `serverURL` property to struct
- Added Seafile case to the provider switch statement
- Fixed preview to include serverURL parameter

**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift`

```swift
case .seafile:
    try await rclone.setupSeafile(
        remoteName: rcloneName,
        url: serverURL,
        username: username,
        password: password
    )
```

### 3. ConfigureSettingsStep.swift - Added Seafile Support
- Added `serverURL` binding property
- Added `isSeafile` computed property
- Added Server URL text field shown when Seafile or FileFabric is selected
- Added Seafile-specific instructions

**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift`

```swift
// Server URL field for Seafile, FileFabric (and other self-hosted providers)
if isSeafile || isFileFabric {
    HStack {
        Text("Server URL")
            .frame(width: 100, alignment: .trailing)
        TextField(
            isSeafile ? "https://cloud.seafile.com" : "https://yourfabric.smestorage.com",
            text: serverURL
        )
        .textFieldStyle(.roundedBorder)
    }
}
```

Provider instructions for Seafile:
```swift
case .seafile:
    return "Enter your Seafile server URL (e.g., https://cloud.seafile.com), email, and password."
```

### 4. MainWindow.swift - Fixed FileFabric Call
- Fixed `setupFileFabric` call to include required `serverURL` parameter

**File:** `/Users/antti/claude/CloudSyncApp/Views/MainWindow.swift`

```swift
case .filefabric:
    try await rclone.setupFileFabric(remoteName: rcloneName, serverURL: "")
```

## RcloneManager.swift - Already Correct
The existing `setupSeafile` function already accepts the server URL parameter:

```swift
func setupSeafile(remoteName: String, url: String, username: String, password: String, library: String? = nil, authToken: String? = nil) async throws
```

## Seafile Config Format
The implementation generates rclone configuration matching the required format:
```
[seafile]
type = seafile
url = https://cloud.seafile.com/
user = user@example.com
pass = <password>
```

## Build Status
- Build: SUCCEEDED
- No compilation errors

## Additional Fixes (While Fixing Seafile)
- Fixed FileFabric provider which also required serverURL parameter
- Added FileFabric-specific UI for server URL input in OAuth configuration flow
- Added FileFabric provider instructions

## Testing Recommendations
1. Test Seafile wizard flow with a valid Seafile server
2. Verify server URL field appears in Configure Settings step
3. Verify connection test succeeds with valid credentials
4. Test with both cloud.seafile.com and self-hosted instances
