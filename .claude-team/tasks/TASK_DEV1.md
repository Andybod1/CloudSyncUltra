# Dev-1 Task: UI Quick Wins Batch

## Model: Sonnet (all S/XS tickets)

## Issues
- #18 (High, S): Remember transfer view state
- #17 (Low, XS): Mouseover highlight for username
- #22 (Low, S): Search field in add cloud storage
- #23 (Low, S): Remote name dialog timing

---

## Task 1: Remember Transfer View State (#18)

### Problem
When user navigates away from Transfer view and returns, state resets (selected remotes, paths, etc.)

### Solution
Create persistent state holder using @StateObject or @EnvironmentObject

### Implementation
```swift
// Create in CloudSyncApp/ViewModels/TransferViewState.swift
class TransferViewState: ObservableObject {
    @Published var sourceRemote: CloudRemote?
    @Published var destRemote: CloudRemote?
    @Published var sourcePath: String = ""
    @Published var destPath: String = ""
    @Published var selectedSourceFiles: Set<UUID> = []
    @Published var selectedDestFiles: Set<UUID> = []
}

// In MainWindow.swift - create once
@StateObject private var transferState = TransferViewState()

// Pass to TransferView
TransferView()
    .environmentObject(transferState)

// In TransferView - use environment object
@EnvironmentObject var state: TransferViewState
```

### Files
- **Create**: `CloudSyncApp/ViewModels/TransferViewState.swift`
- **Modify**: `CloudSyncApp/Views/MainWindow.swift`
- **Modify**: `CloudSyncApp/Views/TransferView.swift`

---

## Task 2: Mouseover Highlight (#17)

### Problem
Username in sidebar cloud service list has no hover feedback

### Solution
Add hover effect to username display

### Implementation
```swift
// In sidebar remote item
@State private var isHovering = false

Text(remote.username ?? "")
    .font(.caption)
    .foregroundColor(.secondary)
    .padding(.horizontal, 4)
    .padding(.vertical, 2)
    .background(isHovering ? Color.accentColor.opacity(0.1) : Color.clear)
    .cornerRadius(4)
    .onHover { hovering in
        isHovering = hovering
    }
```

### Files
- **Modify**: `CloudSyncApp/Views/MainWindow.swift` (sidebar remote item)

---

## Task 3: Search Field in Add Cloud Storage (#22)

### Problem
42 providers - hard to find specific one by scrolling

### Solution
Add search/filter field at top of provider grid

### Implementation
```swift
@State private var searchText = ""

var filteredProviders: [CloudProviderType] {
    if searchText.isEmpty {
        return CloudProviderType.allCases
    }
    return CloudProviderType.allCases.filter {
        $0.displayName.localizedCaseInsensitiveContains(searchText)
    }
}

var body: some View {
    VStack {
        // Search field
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
        .padding(.horizontal)
        
        // Filtered grid
        ScrollView {
            LazyVGrid(columns: [...], spacing: 12) {
                ForEach(filteredProviders, id: \.self) { provider in
                    ProviderCard(provider: provider)
                }
            }
        }
    }
}
```

### Files
- **Modify**: `CloudSyncApp/Views/AddRemoteView.swift`

---

## Task 4: Remote Name Dialog Timing (#23)

### Problem
"Enter remote name" field shows before provider is selected

### Solution
Only show name field after provider selection

### Implementation
```swift
@State private var selectedProvider: CloudProviderType?
@State private var remoteName: String = ""

var body: some View {
    VStack {
        // Provider grid (always visible)
        ProviderGridView(selection: $selectedProvider)
        
        // Only show after selection
        if selectedProvider != nil {
            Divider()
            
            HStack {
                Text("Remote name:")
                TextField("my-cloud", text: $remoteName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }
            .padding()
        }
    }
}
```

### Files
- **Modify**: `CloudSyncApp/Views/AddRemoteView.swift`

---

## Completion Checklist
- [ ] #18: Transfer view state persists across navigation
- [ ] #17: Username shows hover highlight
- [ ] #22: Search field filters providers
- [ ] #23: Remote name only shows after provider selected
- [ ] All changes compile
- [ ] Update STATUS.md when done

## Commits
```
git commit -m "feat(ui): Persist transfer view state - Fixes #18"
git commit -m "feat(ui): Add hover highlight to username - Fixes #17"
git commit -m "feat(ui): Add provider search field - Fixes #22"
git commit -m "feat(ui): Show remote name after provider selection - Fixes #23"
```
