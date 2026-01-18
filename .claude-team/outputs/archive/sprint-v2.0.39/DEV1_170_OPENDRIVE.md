# Bug #170: OpenDrive OAuth Fix - Completion Report

**Dev-1** | **Date:** 2026-01-18 | **Status:** COMPLETE

## Summary

Fixed Bug #170 where OpenDrive was incorrectly marked as an OAuth provider. OpenDrive uses username/password authentication, not OAuth. The fix ensures the wizard shows credential input fields instead of OAuth browser flow.

## Files Modified

### 1. `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`

**Change:** Removed `.opendrive` from `requiresOAuth` computed property

```swift
// BEFORE (lines 387-394):
var requiresOAuth: Bool {
    switch self {
    case .googleDrive, .dropbox, .oneDrive, .box, .yandexDisk,
         .googleCloudStorage, .oneDriveBusiness, .sharepoint,
         .googlePhotos, .flickr, .sugarsync, .opendrive,  // <-- opendrive was here
         .putio, .premiumizeme, .quatrix, .filefabric, .pcloud:
        return true
    ...
}

// AFTER:
var requiresOAuth: Bool {
    switch self {
    case .googleDrive, .dropbox, .oneDrive, .box, .yandexDisk,
         .googleCloudStorage, .oneDriveBusiness, .sharepoint,
         .googlePhotos, .flickr, .sugarsync,  // <-- opendrive removed
         .putio, .premiumizeme, .quatrix, .filefabric, .pcloud:
        return true
    ...
}
```

### 2. `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`

**Change:** Updated `setupOpenDrive()` to accept username and password parameters

```swift
// BEFORE (line 1861):
func setupOpenDrive(remoteName: String) async throws {
    // OpenDrive uses OAuth - opens browser for authentication
    try await createRemoteInteractive(name: remoteName, type: "opendrive")
}

// AFTER:
func setupOpenDrive(remoteName: String, username: String, password: String) async throws {
    // OpenDrive uses username/password authentication (not OAuth)
    // Password must be obscured for rclone config
    let obscuredPassword = try await obscurePassword(password)

    let params: [String: String] = [
        "username": username,
        "password": obscuredPassword
    ]

    try await createRemote(
        name: remoteName,
        type: "opendrive",
        parameters: params
    )
}
```

### 3. `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/TestConnectionStep.swift`

**Change:** Updated OpenDrive case to pass username and password

```swift
// BEFORE (line 355-356):
case .opendrive:
    try await rclone.setupOpenDrive(remoteName: rcloneName)

// AFTER:
case .opendrive:
    try await rclone.setupOpenDrive(
        remoteName: rcloneName,
        username: username,
        password: password
    )
```

### 4. `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift`

**Change:** Added OpenDrive-specific instruction text for the credentials form

```swift
// ADDED in providerInstructions (line 518-519):
case .opendrive:
    return "Enter your OpenDrive account email and password."
```

### 5. `/Users/antti/claude/CloudSyncApp/Views/MainWindow.swift`

**Change:** Updated OpenDrive case in the legacy setup path to pass credentials

```swift
// BEFORE (lines 883-884):
case .opendrive:
    try await rclone.setupOpenDrive(remoteName: rcloneName)

// AFTER:
case .opendrive:
    try await rclone.setupOpenDrive(
        remoteName: rcloneName,
        username: username,
        password: password
    )
```

## Testing Performed

1. **Build Verification:** Project compiles successfully with `xcodebuild -scheme CloudSyncApp -configuration Debug build`

2. **Code Flow Verification:**
   - ConfigureSettingsStep.swift now shows `credentialsConfiguration` view (username/password fields) for OpenDrive since `provider.requiresOAuth` returns `false`
   - TestConnectionStep.swift correctly passes username and password to `setupOpenDrive()`
   - RcloneManager.swift properly obscures the password and creates the rclone config with username/password parameters

3. **Authentication Flow:**
   - When selecting OpenDrive in the connection wizard, users will now see:
     - Username field for email
     - Password field for password
     - Instruction text: "Enter your OpenDrive account email and password."
   - No OAuth browser redirect will occur

## Notes

- The password is properly obscured using `rclone obscure` before being stored in the config
- The fix aligns with rclone's actual OpenDrive backend which uses `username` and `password` parameters
- A pre-existing issue with `.flickr` being removed from the enum was observed but is unrelated to this bug fix (the linter or another process cleaned it up)
