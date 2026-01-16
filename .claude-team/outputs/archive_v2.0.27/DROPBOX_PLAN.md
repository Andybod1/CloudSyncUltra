# Dropbox Implementation Plan (#37)

## Overview

Dropbox is a critical cloud service for CloudSync Ultra. This document plans thorough validation and any needed improvements.

## Current Implementation Status

### Already Implemented ✅
- `CloudProviderType.dropbox` in Models
- OAuth authentication via `setupDropbox()` in RcloneManager
- UI integration in MainWindow (provider selection, setup flow)
- rclone type: `dropbox`

### rclone Dropbox Backend
- Uses OAuth2 authentication
- Supports full file operations (list, upload, download, delete, move, copy)
- Supports shared folders
- Supports Team Drives (business accounts)

---

## Validation Test Plan

### Phase 1: Authentication Testing
| Test | Expected | Status |
|------|----------|--------|
| OAuth flow opens browser | Browser opens to Dropbox auth | ⬜ |
| User grants access | Token stored in rclone config | ⬜ |
| Re-authentication works | Can reconnect after token expires | ⬜ |
| Cancel auth gracefully | No crash, proper error message | ⬜ |

### Phase 2: File Operations
| Test | Expected | Status |
|------|----------|--------|
| List root folder | Shows all top-level files/folders | ⬜ |
| List nested folders | Can navigate deep folder structures | ⬜ |
| Upload small file (<1MB) | File appears in Dropbox | ⬜ |
| Upload large file (>100MB) | Progress shown, completes | ⬜ |
| Download file | File saved locally | ⬜ |
| Delete file | File removed from Dropbox | ⬜ |
| Rename file | Name changed in Dropbox | ⬜ |
| Move file between folders | File relocated | ⬜ |

### Phase 3: Edge Cases
| Test | Expected | Status |
|------|----------|--------|
| Special characters in filename | Handled correctly | ⬜ |
| Unicode filenames (日本語.txt) | Works | ⬜ |
| Very long filenames | Works or clear error | ⬜ |
| Empty folders | Displayed correctly | ⬜ |
| Shared folders | Accessible and listed | ⬜ |
| Dropbox Paper docs | Listed (read-only) | ⬜ |

### Phase 4: Sync Operations
| Test | Expected | Status |
|------|----------|--------|
| One-way sync to Dropbox | Files uploaded | ⬜ |
| One-way sync from Dropbox | Files downloaded | ⬜ |
| Bidirectional sync | Both directions work | ⬜ |
| Conflict handling | User notified | ⬜ |

### Phase 5: Error Handling
| Test | Expected | Status |
|------|----------|--------|
| Network disconnect during transfer | Graceful error, retry option | ⬜ |
| Dropbox storage full | Clear error message | ⬜ |
| Rate limiting | Backoff and retry | ⬜ |
| Invalid token | Prompt for re-auth | ⬜ |

---

## Known Dropbox Limitations (rclone)

1. **No server-side copy** for files >50MB
2. **Case insensitive** - Dropbox treats "File.txt" and "file.txt" as same
3. **Modification times** - May not be preserved perfectly
4. **Shared folders** - Some restrictions on operations

---

## Test Account Requirements

For thorough testing, need:
- [ ] Free Dropbox account (2GB storage)
- [ ] Test files of various sizes
- [ ] Folders with special characters
- [ ] Shared folder to test

---

## Recommended Actions

### If All Tests Pass
1. Mark Dropbox as "Verified" in documentation
2. Close #37 as validated
3. Add Dropbox to list of tested providers in README

### If Issues Found
1. Create specific bug tickets for each issue
2. Prioritize based on severity
3. Fix and re-test

---

## Worker Assignment

| Phase | Worker | Model |
|-------|--------|-------|
| Test execution | Andy (manual) or Cowork | - |
| Bug fixes (if needed) | Dev-2 (Engine) | Sonnet/Opus |
| Test automation | QA | Opus |
| Documentation | Dev-Ops | Opus |

---

*Created: 2026-01-13*
*Ticket: #37*
