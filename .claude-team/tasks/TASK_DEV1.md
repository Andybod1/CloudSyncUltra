# Task Assignment: Dev-1 (UI)

## Ticket: #40 — Performance Settings UI
**Size:** M | **Priority:** High

---

## Objective
Build Performance Settings UI with profiles (Conservative/Balanced/Performance) and advanced customization options.

---

## Requirements

### 1. Create PerformanceProfile Model

**File:** `CloudSyncApp/Models/PerformanceProfile.swift`

```swift
enum PerformanceProfile: String, CaseIterable {
    case conservative
    case balanced
    case performance
    case custom
}

struct PerformanceSettings {
    var parallelTransfers: Int      // 1-16
    var bandwidthLimit: Int         // MB/s, 0 = unlimited
    var chunkSizeMB: Int            // 8, 16, 32, 64, 128
    var cpuPriority: CPUPriority    // low, normal, high
    var checkFrequency: CheckFrequency // everyFile, sampling, trustRemote
}
```

### 2. Profile Defaults

| Setting | Conservative | Balanced | Performance |
|---------|-------------|----------|-------------|
| parallelTransfers | 2 | 4 | 16 |
| bandwidthLimit | 1 | 5 | 0 (unlimited) |
| chunkSizeMB | 8 | 32 | 64 |
| cpuPriority | .low | .normal | .high |
| checkFrequency | .everyFile | .sampling | .trustRemote |

### 3. Settings → Performance Tab

**File:** `CloudSyncApp/Views/PerformanceSettingsView.swift`

- Profile selector (segmented control: Conservative / Balanced / Performance / Custom)
- Checkbox: "Show quick toggle in Transfer View" (default: ON)
- Collapsible "Advanced" section:
  - Parallel transfers slider (1-16)
  - Bandwidth limit field (MB/s, 0 = unlimited)
  - Chunk size picker (8 / 16 / 32 / 64 / 128 MB)
  - CPU priority picker (Low / Normal / High)
  - Check frequency picker (Every file / Sampling / Trust remote)
- Auto-switch to "Custom" when advanced values differ from profile presets

### 4. Transfer View Quick Toggle

**File:** Modify `CloudSyncApp/Views/TransferView.swift`

- Add compact profile selector (only if enabled in settings)
- 3-button segmented control or picker
- Session-only override (doesn't persist to global settings)

### 5. Integration with SettingsView

**File:** Modify `CloudSyncApp/SettingsView.swift`

- Add "Performance" tab to the existing tab view
- Use PerformanceSettingsView as content

### 6. Storage

- Store in UserDefaults via `@AppStorage`
- Keys: `performanceProfile`, `showQuickToggle`, individual setting keys
- Default profile: `.balanced`

---

## Critical Rules

⚠️ **DO NOT override provider-specific chunk sizes**
- ChunkSizeConfig already handles per-provider optimal chunks
- Profile chunk size is a MAXIMUM
- Use: `min(profileChunkSize, providerOptimalChunk)`

---

## Acceptance Criteria

- [ ] PerformanceProfile model with all 5 settings
- [ ] PerformanceSettingsView with profile selector + advanced section
- [ ] Performance tab added to SettingsView
- [ ] Quick toggle in TransferView (optional, controlled by setting)
- [ ] Settings persist via UserDefaults
- [ ] Profile auto-switches to "Custom" when values modified
- [ ] Unit tests for PerformanceProfile model
- [ ] Build passes, app launches

---

## Deliverables

1. `CloudSyncApp/Models/PerformanceProfile.swift` (new)
2. `CloudSyncApp/Views/PerformanceSettingsView.swift` (new)
3. `CloudSyncApp/SettingsView.swift` (modified - add tab)
4. `CloudSyncApp/Views/TransferView.swift` (modified - add quick toggle)
5. `CloudSyncAppTests/PerformanceProfileTests.swift` (new)

---

## When Done

1. Run all tests: `xcodebuild test -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed"`
2. Build and launch app to verify UI
3. Git commit with message: `feat(ui): Add Performance Settings UI with profiles (#40)`
4. Update STATUS.md with completion
5. Report back to Strategic Partner

---

*Assigned: 2026-01-15*
*Worker: Dev-1 (Opus)*
