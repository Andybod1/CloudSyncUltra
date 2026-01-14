# Performance Engineer Task: Large File List Pagination

**Sprint:** Maximum Productivity
**Priority:** Medium
**Worker:** Performance Engineer

---

## Objective

Implement lazy loading and pagination for file lists with more than 1000 files to prevent UI blocking and memory issues.

## Files to Modify

- `CloudSyncApp/Views/FileBrowserView.swift`
- `CloudSyncApp/RcloneManager.swift` (potentially - for paginated fetching)

## Files to Create

- `CloudSyncApp/PaginatedFileLoader.swift` (optional - if extracted)

## Tasks

### 1. Analyze Current Implementation

```bash
# Find FileBrowserView
cat CloudSyncApp/Views/FileBrowserView.swift | head -100

# Check how files are loaded
grep -n "listFiles\|fetchFiles\|getFiles" CloudSyncApp/*.swift
```

### 2. Implement Lazy Loading

Use SwiftUI's `LazyVStack` instead of `VStack` for file lists:

```swift
// Before
ScrollView {
    VStack {
        ForEach(files) { file in
            FileRow(file: file)
        }
    }
}

// After
ScrollView {
    LazyVStack {
        ForEach(files) { file in
            FileRow(file: file)
        }
    }
}
```

### 3. Implement Pagination

Load files in chunks (e.g., 100 at a time):

```swift
struct FileBrowserView: View {
    @State private var displayedFiles: [RemoteFile] = []
    @State private var allFiles: [RemoteFile] = []
    @State private var currentPage = 0
    @State private var isLoading = false
    private let pageSize = 100

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(displayedFiles) { file in
                    FileRow(file: file)
                        .onAppear {
                            // Load more when reaching end
                            if file.id == displayedFiles.last?.id {
                                loadMoreIfNeeded()
                            }
                        }
                }

                if isLoading {
                    ProgressView()
                        .padding()
                }

                if hasMoreFiles {
                    Button("Load More (\(remainingCount) files)") {
                        loadMoreFiles()
                    }
                    .buttonStyle(.link)
                }
            }
        }
    }

    private var hasMoreFiles: Bool {
        displayedFiles.count < allFiles.count
    }

    private var remainingCount: Int {
        allFiles.count - displayedFiles.count
    }

    private func loadMoreIfNeeded() {
        guard !isLoading && hasMoreFiles else { return }
        loadMoreFiles()
    }

    private func loadMoreFiles() {
        isLoading = true
        let startIndex = displayedFiles.count
        let endIndex = min(startIndex + pageSize, allFiles.count)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            displayedFiles.append(contentsOf: allFiles[startIndex..<endIndex])
            currentPage += 1
            isLoading = false
        }
    }

    private func resetPagination(with files: [RemoteFile]) {
        allFiles = files
        displayedFiles = Array(files.prefix(pageSize))
        currentPage = 1
    }
}
```

### 4. Add Virtual Scrolling Indicator

Show position in large lists:

```swift
// Add to scroll view
.overlay(alignment: .trailing) {
    if allFiles.count > 500 {
        ScrollPositionIndicator(
            current: displayedFiles.count,
            total: allFiles.count
        )
    }
}
```

### 5. Memory Optimization

For very large directories, consider releasing non-visible items:

```swift
// Track visible range
@State private var visibleRange: Range<Int> = 0..<100

// Only keep metadata for visible + buffer items
private func optimizeMemory() {
    // Keep full data for visible items
    // Reduce to minimal data for offscreen items
}
```

### 6. Profile Performance

```swift
// Add timing instrumentation
import os

let logger = Logger(subsystem: "com.cloudsync", category: "performance")

func loadFiles() async {
    let signpost = OSSignposter()
    let id = signpost.makeSignpostID()
    let state = signpost.beginInterval("LoadFiles", id: id)

    // Load files...

    signpost.endInterval("LoadFiles", state)
    logger.info("Loaded \(files.count) files in \(duration)s")
}
```

## Verification

1. Create a test directory with 10,000+ files:
   ```bash
   mkdir test_large
   for i in {1..10000}; do touch "test_large/file_$i.txt"; done
   ```

2. Open the directory in FileBrowserView
3. Verify:
   - UI remains responsive
   - Memory usage stays reasonable
   - Scrolling is smooth
   - Loading indicator appears while fetching more

## Metrics to Capture

- Time to first render (should be <500ms)
- Memory usage with 1K, 5K, 10K files
- Scroll frame rate (should be 60fps)
- Time to load additional pages

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/PERFORMANCE_COMPLETE.md`

Include:
- Implementation approach
- Before/after performance metrics
- Memory usage comparison
- Files modified

## Success Criteria

- [ ] LazyVStack implemented for file lists
- [ ] Pagination loads 100 files at a time
- [ ] "Load More" indicator when more files available
- [ ] UI remains responsive with 10,000+ files
- [ ] Memory usage reasonable (<500MB for 10K files)
- [ ] Build succeeds
- [ ] Existing tests pass
