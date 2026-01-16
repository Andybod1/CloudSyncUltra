# Task: Remote Name Auto-Update on Provider Selection (#110)

## Worker: Dev-2
## Priority: MEDIUM
## Size: S (30 min - 1 hr)

---

## Issue

When selecting a cloud provider in the Add Cloud dialog, the "Remote Name" field doesn't update to match the selected provider.

Example: User selects "Proton Drive" but Remote Name still shows "Google Drive"

## Files to Find and Modify

Search for the Add Cloud / Add Remote dialog. Look for:
- Provider selection grid
- "Remote Name" text field
- `@State` property for the remote name

Likely locations:
- `CloudSyncApp/Views/AddCloudView.swift`
- `CloudSyncApp/Views/AddRemoteSheet.swift`
- Or similar

## Solution

When provider selection changes, update the remote name field to the provider's display name:

```swift
// In the provider selection handler or onChange:
.onChange(of: selectedProvider) { _, newProvider in
    if let provider = newProvider {
        remoteName = provider.displayName
    }
}
```

Or in the tap gesture:
```swift
.onTapGesture {
    selectedProvider = provider
    remoteName = provider.displayName  // Add this line
}
```

## Verification Steps

1. Build passes
2. Open Add Cloud dialog
3. Note the default Remote Name
4. Click on a different provider (e.g., Dropbox)
5. **Expected**: Remote Name updates to "Dropbox"
6. Click another provider (e.g., OneDrive)
7. **Expected**: Remote Name updates to "OneDrive"

## Edge Cases

- If user has manually edited the name, consider whether to overwrite
- Option A: Always update (simpler)
- Option B: Only update if name matches previous provider name (preserves user edits)

Recommend Option A for simplicity.

## Constraints

- Use existing CloudProviderType.displayName property
- DO NOT modify CloudProviderType enum
- Run `./scripts/worker-qa.sh` before marking complete
