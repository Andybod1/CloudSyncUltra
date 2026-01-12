# Dev-1 Task: UI Quick Wins Batch

## Model: Sonnet (all XS/S tickets)

## Issues
- #18 (High, S): Remember transfer view state
- #17 (Low, XS): Mouseover highlight for username
- #22 (Low, S): Search field in add cloud storage
- #23 (Low, S): Remote name dialog timing

---

## Task 1: Remember Transfer View State (#18)

### Problem
When user navigates away from Transfer view and comes back, state resets (selected remotes, paths, etc.)

### Solution
Create persistent state that survives navigation using @StateObject or @SceneStorage.

### Implementation
```swift
// Option A: StateObject in parent (recommended)
// In MainWindow.swift or CloudSyncApp.swift

class TransferViewState: ObservableObject {
    @Published var sourceRemoteId: UUID?
    @Published var destRemoteId: UUID?
    @Published var sourcePath: String = ""
    @Published var destPath: String = ""
    @Published var selectedSourceFiles: Set<UUID> = []
    @Published var selectedDestFiles: Set<UUID> = []
}

// Create once at app level
@StateObject private var transferState = TransferViewState()

// Pass to TransferView
TransferView()
    .environmentObject(transferState)
```

```swift
// In TransferView.swift - use EnvironmentObject instead of @State
@EnvironmentObject var state: TransferViewState

// Replace local @State vars with state.property
```

### Files
- `CloudSyncApp/Views/MainWindow.swift` - Add StateObject, pass to TransferView
- `CloudSyncApp/Views/TransferView.swift` - Use EnvironmentObject

---

## Task 2: Mouseover Highlight (#17)

### Problem
Username display in sidebar needs hover highlight for better UX.

### Solution
Add onHover modifier to username text.

### Implementation
Find where username is displayed in sidebar (likely in `remoteSidebarItem` or similar):

```swift
// Add state for hover
@State private var isHoveringUsername = false

// In the view
Text(remote.username ?? "")
    .font(.caption)
    .foregroundColor(.secondary)
    .padding(.horizontal, 4)
    .padding(.vertical, 2)
    .background(isHoveringUsername ? Color.accentColor.opacity(0.1) : Color.clear)
    .cornerRadius(4)
    .onHover { hovering in
        isHoveringUsername = hovering
    }
```

### Files
- `CloudSyncApp/Views/MainWindow.swift` - remoteSidebarItem function

---

## Task 3: Search Field in Add Cloud Storage (#22)

### Problem
With 42 providers, finding one is tedious. Need search/filter.

### Solution
Add search TextField that filters provider grid.

### Implementation
```swift
// In AddRemoteView.swift

@State private var searchText = ""

var filteredProviders: [CloudProviderType] {
    if searchText.isEmpty {
        return CloudProviderType.allCases.filter { $0.isSupported }
    }
    return CloudProviderType.allCases.filter { provider in
        provider.isSupported &&
        provider.displayName.localizedCaseInsensitiveContains(searchText)
    }
}

var body: some View {
    VStack(spacing: 0) {
        // Search bar at top
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search providers...", text: $searchText)
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(.textBackgroundColor))
        .cornerRadius(8)
        .padding()
        
        // Provider grid uses filteredProviders
        ScrollView {
            LazyVGrid(...) {
                ForEach(filteredProviders, id: \.self) { provider in
                    // existing provider card
                }
            }
        }
    }
}
```

### Files
- `CloudSyncApp/Views/AddRemoteView.swift`

---

## Task 4: Remote Name Dialog Timing (#23)

### Problem
Remote name input field shows before provider is selected. Should only appear after selection.

### Solution
Conditionally show name field only when provider is selected.

### Implementation
```swift
// In AddRemoteView.swift

@State private var selectedProvider: CloudProviderType?
@State private var remoteName: String = ""

var body: some View {
    VStack {
        // Provider grid (always visible)
        providerGrid
        
        // Name field - only after provider selected
        if selectedProvider != nil {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Remote Name")
                    .font(.headline)
                TextField("Enter a name for this remote", text: $remoteName)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        
        // Continue button
        if selectedProvider != nil && !remoteName.isEmpty {
            Button("Continue") {
                // proceed to configuration
            }
            .buttonStyle(.borderedProminent)
        }
    }
    .animation(.default, value: selectedProvider)
}
```

### Files
- `CloudSyncApp/Views/AddRemoteView.swift`

---

## Completion Checklist
- [ ] #18: Transfer view state persists across navigation
- [ ] #17: Username shows highlight on hover
- [ ] #22: Search field filters providers
- [ ] #23: Name field appears after provider selection
- [ ] All changes compile
- [ ] Test each feature manually
- [ ] Update STATUS.md when done

## Commits
```bash
git commit -m "feat(ui): Remember transfer view state across navigation - Fixes #18"
git commit -m "feat(ui): Add hover highlight to sidebar username - Fixes #17"
git commit -m "feat(ui): Add search field to provider selection - Fixes #22"
git commit -m "feat(ui): Show remote name field after provider selection - Fixes #23"
```

Or combine:
```bash
git commit -m "feat(ui): UI quick wins batch - Fixes #18, #17, #22, #23"
```
