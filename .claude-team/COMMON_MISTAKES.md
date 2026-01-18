# Common Mistakes & How to Avoid Them

> **Purpose:** Learn from past errors to prevent repeat issues.
> **Last Updated:** 2026-01-18

---

## Critical Mistakes (Block CI/Release)

### 1. Swift Strict Concurrency Errors in Release Builds

**Problem:** Code builds in Debug but fails in Release due to stricter concurrency checking.

**Symptom:**
```
error: reference to captured var 'self' in concurrently-executing code
```

**Wrong:**
```swift
timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
    Task { @MainActor in
        await self?.doSomething()  // ERROR in Release!
    }
}
```

**Correct:**
```swift
timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
    guard let strongSelf = self else { return }
    Task { @MainActor in
        await strongSelf.doSomething()  // OK
    }
}
```

**Files fixed for this issue:**
- `ScheduleManager.swift`
- `SyncManager.swift`
- `StatusBarController.swift`
- `RcloneManager.swift`
- `ProtonDriveManager.swift`

**Prevention:** Always test with Release build before marking done:
```bash
xcodebuild -scheme CloudSyncApp -configuration Release build
```

---

### 2. Using @Previewable (Xcode 16+ Only)

**Problem:** `@Previewable` macro is Xcode 16+ only, CI uses Xcode 15.

**Symptom:**
```
error: Unknown attribute 'Previewable'
```

**Wrong:**
```swift
#Preview {
    @Previewable @State var selection: Provider? = nil
    MyView(selection: $selection)
}
```

**Correct:**
```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView(selection: .constant(nil))
    }
}
```

**Prevention:** Don't use `@Previewable` until CI upgrades to Xcode 16.

---

### 3. Mutable Variables in Pipe Handlers

**Problem:** Mutable variables captured in `readabilityHandler` closures.

**Symptom:**
```
error: mutation of captured var 'errorOutput' in concurrently-executing code
```

**Wrong:**
```swift
var errorOutput = ""
stderrPipe.fileHandleForReading.readabilityHandler = { handle in
    errorOutput += String(data: handle.availableData, encoding: .utf8) ?? ""
}
```

**Correct:**
```swift
nonisolated(unsafe) var errorOutput = ""
stderrPipe.fileHandleForReading.readabilityHandler = { handle in
    errorOutput += String(data: handle.availableData, encoding: .utf8) ?? ""
}
```

**Note:** Only use `nonisolated(unsafe)` when you've verified the access pattern is safe.

---

## Build Errors

### 4. Forgetting to Add Files to Xcode Project

**Problem:** New Swift file created but not added to `project.pbxproj`.

**Symptom:**
```
error: cannot find 'MyNewType' in scope
```

**Prevention:**
- Create files through Xcode, not manually
- Or manually add to `project.pbxproj`:
  1. PBXBuildFile section
  2. PBXFileReference section
  3. PBXGroup (correct folder)
  4. PBXSourcesBuildPhase

---

### 5. Missing Switch Cases

**Problem:** Adding new enum case but forgetting all switch statements.

**Symptom:**
```
error: switch must be exhaustive
```

**Common locations to check:**
- `TestConnectionStep.swift` - `configureRemoteWithRclone()`
- `ConfigureSettingsStep.swift` - provider-specific UI
- `RcloneManager.swift` - setup functions

**Prevention:** Search for `switch.*providerType` or `switch.*provider` before marking done.

---

## Test Failures

### 6. Not Running Tests Before Commit

**Problem:** Tests fail but worker didn't run them.

**Prevention:**
```bash
./scripts/worker-qa.sh  # Runs build AND tests
```

---

### 7. Flaky Tests Due to Timing

**Problem:** Tests pass locally but fail in CI due to timing.

**Wrong:**
```swift
sleep(1)  // Arbitrary delay
XCTAssertTrue(viewModel.isLoaded)
```

**Correct:**
```swift
let expectation = XCTestExpectation(description: "Loading")
viewModel.$isLoaded
    .filter { $0 }
    .sink { _ in expectation.fulfill() }
    .store(in: &cancellables)
wait(for: [expectation], timeout: 5.0)
```

---

## Code Quality Issues

### 8. Hardcoded Strings

**Problem:** User-visible strings not localized.

**Wrong:**
```swift
Text("Connection failed")
```

**Correct:**
```swift
Text("connection_failed", comment: "Error message when connection fails")
// Or for now:
Text("Connection failed")  // TODO: Localize
```

---

### 9. Force Unwrapping

**Problem:** Force unwrap (`!`) causes crashes.

**Wrong:**
```swift
let url = URL(string: urlString)!
```

**Correct:**
```swift
guard let url = URL(string: urlString) else {
    throw ConfigurationError.invalidURL
}
```

---

### 10. Ignoring Result of Throwing Functions

**Problem:** Async function result ignored, errors silently swallowed.

**Wrong:**
```swift
Task {
    try await saveData()  // Error ignored!
}
```

**Correct:**
```swift
Task {
    do {
        try await saveData()
    } catch {
        Logger.error("Save failed: \(error)")
    }
}
```

---

## Output & Documentation Mistakes

### 11. Incomplete Worker Output

**Problem:** Worker output missing required sections.

**Required sections for integration studies:**
- [ ] Executive Summary
- [ ] Current Implementation Status
- [ ] rclone Backend Analysis
- [ ] Recommendations
- [ ] Implementation Checklist

**Required sections for dev tasks:**
- [ ] What was done
- [ ] Files changed
- [ ] How to test
- [ ] Known limitations

---

### 12. Not Updating STATUS.md

**Problem:** Task done but STATUS.md not updated.

**Prevention:** After completing task:
```bash
# Update sprint progress in .claude-team/STATUS.md
```

---

## Git Mistakes

### 13. Committing Secrets

**Problem:** API keys, tokens committed to repo.

**Files to never commit:**
- `.env`
- `*.pem`
- `*credentials*`
- `*secret*`

**Prevention:** Pre-commit hook scans for secrets automatically.

---

### 14. Giant Commits

**Problem:** 1000+ line commits are hard to review.

**Prevention:**
- PR size warning triggers at 500 lines
- Break large features into smaller PRs

---

### 15. Non-Conventional Commit Messages

**Problem:** Commit messages don't follow format.

**Wrong:**
```
fixed the bug
```

**Correct:**
```
fix(sync): resolve race condition in file upload

- Add mutex lock around upload state
- Prevent duplicate uploads

Fixes #123
```

**Format:** `type(scope): description`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## CI-Specific Issues

### 16. CI Works, Local Doesn't (or Vice Versa)

**Common causes:**
- Different Xcode version (CI: 15, Local: 16)
- Different macOS version
- Missing environment variables
- Cache differences

**Prevention:**
```bash
# Test Release build locally
xcodebuild -scheme CloudSyncApp -configuration Release build
```

---

### 17. GitHub Actions Minutes Exhausted

**Problem:** CI fails with billing error.

**Symptom:**
```
The job was not started because recent account payments have failed
```

**Fix:** Make repo public for unlimited minutes, or fix billing.

---

## Quick Reference Checklist

Before marking ANY task complete:

```
[ ] ./scripts/worker-qa.sh passes
[ ] Release build works: xcodebuild -configuration Release build
[ ] All switch statements updated (if adding enum case)
[ ] Files added to project.pbxproj (if new files)
[ ] No @Previewable usage
[ ] No force unwraps added
[ ] Output file has all required sections
[ ] Commit message follows conventional format
```

---

*Add new mistakes to this doc as they're discovered.*
