# Task: Dev-3 - Model Updates (#14, #25)

> **Worker:** Dev-3 (Services/Models)
> **Model:** Sonnet (S-sized tasks)
> **Sprint:** Quick Wins + Polish
> **Tickets:** #14, #25 (Model portions)

---

## Overview

You are implementing model layer changes to support:
1. Cloud remote reordering (sortOrder)
2. Account name storage (accountName)
3. RemotesViewModel methods for reordering

---

## Task 1: Update CloudRemote Model

### File to Modify
`/Users/antti/Claude/CloudSyncApp/Models/CloudProvider.swift`

### Find CloudRemote Struct (around line 441)

**Add two new properties:**

```swift
struct CloudRemote: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var type: CloudProviderType
    var isConfigured: Bool
    var path: String
    var isEncrypted: Bool
    var customRcloneName: String?
    var sortOrder: Int  // ADD THIS - for custom ordering
    var accountName: String?  // ADD THIS - email/username for the connected account
```

**Update the init:**

```swift
init(id: UUID = UUID(), name: String, type: CloudProviderType, isConfigured: Bool = false, path: String = "", isEncrypted: Bool = false, customRcloneName: String? = nil, sortOrder: Int = 0, accountName: String? = nil) {
    self.id = id
    self.name = name
    self.type = type
    self.isConfigured = isConfigured
    self.path = path
    self.isEncrypted = isEncrypted
    self.customRcloneName = customRcloneName
    self.sortOrder = sortOrder
    self.accountName = accountName
}
```

---

## Task 2: Update RemotesViewModel

### File to Modify
`/Users/antti/Claude/CloudSyncApp/ViewModels/RemotesViewModel.swift`

### Add Storage Version Bump

Find the storageKey (around line 20) and bump it:

```swift
private let storageKey = "cloudRemotes_v6"  // Bump from v5 to v6
```

### Add moveCloudRemotes Method

Add this method to RemotesViewModel:

```swift
/// Move cloud remotes to reorder them in the sidebar
/// - Parameters:
///   - source: IndexSet of items to move
///   - destination: Target index
func moveCloudRemotes(from source: IndexSet, to destination: Int) {
    // Get cloud-only remotes (excluding local)
    var cloudRemotes = remotes.filter { $0.type != .local }
    let localRemotes = remotes.filter { $0.type == .local }
    
    // Perform the move
    cloudRemotes.move(fromOffsets: source, toOffset: destination)
    
    // Update sort orders
    for (index, _) in cloudRemotes.enumerated() {
        cloudRemotes[index].sortOrder = index
    }
    
    // Rebuild full remotes array: local first, then sorted cloud remotes
    remotes = localRemotes + cloudRemotes
    
    saveRemotes()
}

/// Update account name for a remote
/// - Parameters:
///   - remoteName: The rclone name of the remote
///   - accountName: The account email or username
func setAccountName(_ accountName: String, for remoteName: String) {
    if let index = remotes.firstIndex(where: { $0.rcloneName == remoteName }) {
        remotes[index].accountName = accountName
        saveRemotes()
    }
}
```

### Update loadRemotes to Sort by sortOrder

Find the `scanRcloneConfig()` call in `loadRemotes()` and add sorting after it:

```swift
func loadRemotes() {
    // Start fresh with local storage
    remotes = [
        CloudRemote(name: "Local Storage", type: .local, isConfigured: true, path: NSHomeDirectory())
    ]
    
    // Scan rclone config for existing remotes
    scanRcloneConfig()
    
    // Sort cloud remotes by sortOrder
    let localRemotes = remotes.filter { $0.type == .local }
    let cloudRemotes = remotes.filter { $0.type != .local }.sorted { $0.sortOrder < $1.sortOrder }
    remotes = localRemotes + cloudRemotes
    
    saveRemotes()
}
```

---

## Task 3: Account Name Extraction (Optional Enhancement)

For OAuth providers, we can try to extract the email from the token. This is optional but adds value.

### File to Modify (if time permits)
`/Users/antti/Claude/CloudSyncApp/Components/ConnectRemoteSheet.swift`

After successful OAuth, try to extract account info:

```swift
// After OAuth completion, try to extract account name
private func extractAccountName(from tokenData: String, for providerType: CloudProviderType) -> String? {
    // For Google services, the token often contains an email
    guard let data = tokenData.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }
    
    // Different providers store email in different places
    if let email = json["email"] as? String {
        return email
    }
    
    return nil
}
```

**Note:** This is lower priority. The main value comes from the model fields being available for future enhancement.

---

## Verification

1. Build the app
2. Verify remotes load correctly (no crashes from model changes)
3. Check that drag & drop in sidebar triggers moveCloudRemotes (once Dev-1 implements UI)
4. Verify remotes maintain order after app restart

---

## Completion Checklist

- [ ] CloudRemote has sortOrder property
- [ ] CloudRemote has accountName property
- [ ] Init updated with new parameters
- [ ] Storage version bumped to v6
- [ ] moveCloudRemotes() method added
- [ ] setAccountName() method added
- [ ] loadRemotes() sorts by sortOrder
- [ ] Build succeeds

---

## Output

When complete, create a summary file:
```
/Users/antti/Claude/.claude-team/outputs/DEV3_COMPLETE.md
```

Include:
- Files modified
- Properties/methods added
- Build status

---

*Task assigned by Strategic Partner*
