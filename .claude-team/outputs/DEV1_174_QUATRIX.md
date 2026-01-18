# Bug #174: Quatrix Authentication Fix

## Summary
Fixed Quatrix provider to use API key authentication instead of OAuth. Quatrix was incorrectly marked as an OAuth provider when it actually uses host + API key authentication.

## Changes Made

### 1. CloudProvider.swift
**File:** `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`

Removed `.quatrix` from the `requiresOAuth` computed property:
```swift
// Before
case .googleDrive, .dropbox, .oneDrive, .box, .yandexDisk,
     .googleCloudStorage, .oneDriveBusiness, .sharepoint,
     .googlePhotos, .sugarsync,
     .putio, .premiumizeme, .quatrix, .filefabric, .pcloud:
    return true

// After
case .googleDrive, .dropbox, .oneDrive, .box, .yandexDisk,
     .googleCloudStorage, .oneDriveBusiness, .sharepoint,
     .googlePhotos, .sugarsync,
     .putio, .premiumizeme, .filefabric, .pcloud:
    return true
```

### 2. RcloneManager.swift
**File:** `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`

Updated `setupQuatrix()` to accept host and API key parameters:
```swift
// Before
func setupQuatrix(remoteName: String) async throws {
    // Quatrix uses OAuth - opens browser for authentication
    try await createRemoteInteractive(name: remoteName, type: "quatrix")
}

// After
func setupQuatrix(remoteName: String, host: String, apiKey: String) async throws {
    // Quatrix uses API key authentication (not OAuth)
    // Host format: yourcompany.quatrix.it (without https://)
    // API key: Generate at https://<account>.quatrix.it/profile/api-keys
    let params: [String: String] = [
        "host": host,
        "api_key": apiKey
    ]

    try await createRemote(
        name: remoteName,
        type: "quatrix",
        parameters: params
    )
}
```

### 3. TestConnectionStep.swift
**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift`

Updated the Quatrix case to pass host and apiKey:
```swift
case .quatrix:
    // Quatrix uses API key authentication (host + api_key)
    // serverURL contains the host (e.g., yourcompany.quatrix.it)
    // password contains the API key
    try await rclone.setupQuatrix(remoteName: rcloneName, host: serverURL, apiKey: password)
```

### 4. ConfigureSettingsStep.swift
**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift`

Multiple updates to support Quatrix credential-based authentication:

1. Added `isQuatrix` helper property:
```swift
private var isQuatrix: Bool {
    provider == .quatrix
}
```

2. Added Host field for Quatrix (using serverURL binding):
```swift
// Server URL/Host field for Seafile, FileFabric, Quatrix
if isSeafile || isFileFabric || isQuatrix {
    HStack {
        Text(isQuatrix ? "Host" : "Server URL")
        TextField(
            isSeafile ? "https://cloud.seafile.com" :
            isQuatrix ? "yourcompany.quatrix.it" :
            "https://yourfabric.smestorage.com",
            text: serverURL
        )
    }
}
```

3. Hidden username field for Quatrix:
```swift
// Username field (hide for Jottacloud and Quatrix)
if provider != .jottacloud && !isQuatrix {
    // Username field...
}
```

4. Updated password field label for Quatrix:
```swift
Text(provider == .jottacloud ? "Token" : isQuatrix ? "API Key" : "Password")
SecureField(
    provider == .jottacloud ? "Personal Login Token" :
    isQuatrix ? "Quatrix API Key" : "Password",
    text: $password
)
```

5. Added provider instructions for Quatrix:
```swift
case .quatrix:
    return "Enter your Quatrix host (e.g., yourcompany.quatrix.it) without https://. Generate an API key at your Quatrix profile under API Keys."
```

6. Added help URL for Quatrix:
```swift
case .quatrix:
    return URL(string: "https://docs.maytech.net/quatrix/quatrix-administration-guide/my-account/api-keys")
```

## Testing Notes
- The wizard now shows credential input fields (Host + API Key) instead of OAuth instructions
- Host format should be: `yourcompany.quatrix.it` (without https://)
- API keys can be generated at: `https://<account>.quatrix.it/profile/api-keys`

## Status
COMPLETE - All changes implemented
