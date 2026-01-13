# TASK: Transfer Performance Audit (#10)

## Worker: Dev-2 (Engine)
## Size: L
## Model: Opus (large ticket)
## Ticket: #10

**Use extended thinking (`/think`) for analysis and recommendations.**

---

## Problem

All file transfers are slow compared to:
- Native cloud apps (Dropbox, Google Drive, OneDrive apps)
- Available bandwidth

User expectation: Match native app speed using efficient parallel transfers.

---

## Phase 1: Current Implementation Analysis

### 1.1 Review RcloneManager.swift
- Find all transfer-related methods
- Document current rclone flags being used
- Identify where parallelization could be added

### 1.2 Check Current Flags
Look for these in the codebase:
```
--transfers      (parallel file transfers, default: 4)
--checkers       (parallel checkers, default: 8)
--multi-thread-streams (streams per file, default: 4)
--buffer-size    (memory buffer, default: 16M)
--s3-chunk-size  (chunk size for multipart)
```

### 1.3 Document Findings
Create a table of current vs recommended settings.

---

## Phase 2: rclone Performance Research

### 2.1 Research rclone Parallel Options
Use `rclone help flags` or web search to understand:

| Flag | Purpose | Default | Recommended |
|------|---------|---------|-------------|
| `--transfers N` | Parallel file transfers | 4 | 8-16? |
| `--checkers N` | Parallel hash checkers | 8 | 16-32? |
| `--multi-thread-streams N` | Streams per large file | 4 | 8? |
| `--multi-thread-cutoff SIZE` | Min size for multi-thread | 250M | 10M? |
| `--buffer-size SIZE` | In-memory buffer | 16M | 64M? |
| `--use-mmap` | Memory-mapped files | false | true? |
| `--fast-list` | Recursive list optimization | false | true? |

### 2.2 Provider-Specific Optimizations
Research optimizations for our top providers:
- Google Drive: `--drive-chunk-size`, `--drive-upload-cutoff`
- Dropbox: `--dropbox-chunk-size`
- OneDrive: `--onedrive-chunk-size`
- S3: `--s3-chunk-size`, `--s3-upload-concurrency`
- Proton Drive: Any specific flags?

### 2.3 Memory/CPU Tradeoffs
Document resource implications of aggressive parallelization.

---

## Phase 3: Implementation Plan

### 3.1 Design Settings
Propose user-configurable performance settings:
```swift
// Example structure
struct TransferSettings {
    var parallelTransfers: Int = 8      // --transfers
    var parallelCheckers: Int = 16      // --checkers  
    var multiThreadStreams: Int = 8     // --multi-thread-streams
    var bufferSize: String = "64M"      // --buffer-size
    var useMultiThread: Bool = true     // Enable multi-threading
}
```

### 3.2 Identify Code Changes
List specific changes needed in:
- `RcloneManager.swift` - Add flags to transfer commands
- Settings UI - Add performance settings section
- Models - Add TransferSettings model

### 3.3 Create Implementation Tickets
Break down into sub-tasks:
- [ ] Add parallel transfer flags to RcloneManager
- [ ] Add performance settings UI
- [ ] Add per-provider optimizations
- [ ] Add bandwidth limiting option (already exists?)

---

## Phase 4: Benchmarking Plan

### 4.1 Propose Test Methodology
- Test file sizes: 1MB, 10MB, 100MB, 1GB
- Test scenarios: Single file, 100 small files, mixed
- Measure: Time, throughput (MB/s), CPU%, Memory

### 4.2 Create Benchmark Script
If time permits, create a simple benchmark script.

---

## Deliverables

1. **Audit Report** documenting:
   - Current implementation
   - Available optimizations
   - Recommended settings
   - Resource tradeoffs

2. **Implementation Plan** with:
   - Code changes needed
   - Sub-tickets for implementation
   - Priority order

3. **Quick Win** (if obvious):
   - If a simple flag change can help immediately, implement it

---

## Output

Write comprehensive report to:
`/Users/antti/Claude/.claude-team/outputs/DEV2_PERFORMANCE_AUDIT.md`

Update STATUS.md when starting and completing.

---

## Commands Reference

```bash
# Check rclone flags
rclone help flags | grep -E "transfer|parallel|thread|buffer|chunk"

# Test transfer with verbose output
rclone copy source: dest: -v --stats 1s

# Benchmark a remote
rclone test info remote: --full
```

---

## Acceptance Criteria

- [ ] Current implementation documented
- [ ] All rclone parallel options researched
- [ ] Provider-specific optimizations listed
- [ ] Implementation plan with code snippets
- [ ] Resource tradeoffs documented
- [ ] Report written to outputs/
