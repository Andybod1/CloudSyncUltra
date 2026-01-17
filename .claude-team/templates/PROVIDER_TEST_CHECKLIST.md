# Provider Integration Test Checklist

> **Purpose:** Standardized verification for all cloud provider integrations.
> **Usage:** Complete this checklist for each provider integration study.
> **Version:** 1.0 (2026-01-17)

---

## Quick Reference

```
┌─────────────────────────────────────────────────────────────────────┐
│  PROVIDER TEST CHECKLIST                                            │
├─────────────────────────────────────────────────────────────────────┤
│  □ Authentication     Can connect with documented credentials       │
│  □ List Operations    Can browse folders and files                  │
│  □ Upload             Can upload files of various sizes             │
│  □ Download           Can download files correctly                  │
│  □ Delete             Can delete files (if supported)               │
│  □ Rename/Move        Can rename or move files (if supported)       │
│  □ Error Handling     Errors are clear and actionable               │
│  □ Edge Cases         Known quirks documented                       │
│  □ Documentation      Guide complete with all sections              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Section 1: Authentication Testing

### 1.1 Primary Auth Method

| Test | Status | Notes |
|------|--------|-------|
| Connect with valid credentials | ☐ Pass ☐ Fail ☐ N/A | |
| Credentials saved correctly | ☐ Pass ☐ Fail ☐ N/A | |
| Reconnect after app restart | ☐ Pass ☐ Fail ☐ N/A | |
| Invalid credentials show clear error | ☐ Pass ☐ Fail ☐ N/A | |

### 1.2 Two-Factor Authentication (if applicable)

| Test | Status | Notes |
|------|--------|-------|
| 2FA prompt appears when needed | ☐ Pass ☐ Fail ☐ N/A | |
| TOTP code accepted | ☐ Pass ☐ Fail ☐ N/A | |
| Wrong 2FA code shows clear error | ☐ Pass ☐ Fail ☐ N/A | |
| Session persists after 2FA | ☐ Pass ☐ Fail ☐ N/A | |

### 1.3 Session Management

| Test | Status | Notes |
|------|--------|-------|
| Token refresh works | ☐ Pass ☐ Fail ☐ N/A | |
| Expired session handled gracefully | ☐ Pass ☐ Fail ☐ N/A | |
| Disconnect clears credentials | ☐ Pass ☐ Fail ☐ N/A | |

---

## Section 2: File Operations Testing

### 2.1 List Operations

| Test | Status | Notes |
|------|--------|-------|
| List root directory | ☐ Pass ☐ Fail ☐ N/A | |
| List subdirectory | ☐ Pass ☐ Fail ☐ N/A | |
| Navigate into folder | ☐ Pass ☐ Fail ☐ N/A | |
| Navigate back (parent) | ☐ Pass ☐ Fail ☐ N/A | |
| Empty folder shows correctly | ☐ Pass ☐ Fail ☐ N/A | |
| Large folder (100+ items) | ☐ Pass ☐ Fail ☐ N/A | |
| File metadata (size, date) correct | ☐ Pass ☐ Fail ☐ N/A | |

### 2.2 Upload Operations

| Test | Status | Notes |
|------|--------|-------|
| Upload small file (<1MB) | ☐ Pass ☐ Fail ☐ N/A | |
| Upload medium file (10-50MB) | ☐ Pass ☐ Fail ☐ N/A | |
| Upload large file (100MB+) | ☐ Pass ☐ Fail ☐ N/A | |
| Upload to root | ☐ Pass ☐ Fail ☐ N/A | |
| Upload to subfolder | ☐ Pass ☐ Fail ☐ N/A | |
| Upload with progress indicator | ☐ Pass ☐ Fail ☐ N/A | |
| Cancel upload mid-transfer | ☐ Pass ☐ Fail ☐ N/A | |
| Resume interrupted upload | ☐ Pass ☐ Fail ☐ N/A | |

### 2.3 Download Operations

| Test | Status | Notes |
|------|--------|-------|
| Download small file | ☐ Pass ☐ Fail ☐ N/A | |
| Download large file | ☐ Pass ☐ Fail ☐ N/A | |
| Downloaded file matches original | ☐ Pass ☐ Fail ☐ N/A | |
| Download with progress indicator | ☐ Pass ☐ Fail ☐ N/A | |
| Cancel download mid-transfer | ☐ Pass ☐ Fail ☐ N/A | |

### 2.4 Delete Operations

| Test | Status | Notes |
|------|--------|-------|
| Delete single file | ☐ Pass ☐ Fail ☐ N/A | |
| Delete folder | ☐ Pass ☐ Fail ☐ N/A | |
| Delete confirmation shown | ☐ Pass ☐ Fail ☐ N/A | |
| Trash/recycle behavior (if applicable) | ☐ Pass ☐ Fail ☐ N/A | |

### 2.5 Rename/Move Operations

| Test | Status | Notes |
|------|--------|-------|
| Rename file | ☐ Pass ☐ Fail ☐ N/A | |
| Rename folder | ☐ Pass ☐ Fail ☐ N/A | |
| Move file to different folder | ☐ Pass ☐ Fail ☐ N/A | |
| Move folder | ☐ Pass ☐ Fail ☐ N/A | |

---

## Section 3: Sync Operations Testing

### 3.1 One-Way Sync

| Test | Status | Notes |
|------|--------|-------|
| Sync local → remote | ☐ Pass ☐ Fail ☐ N/A | |
| Sync remote → local | ☐ Pass ☐ Fail ☐ N/A | |
| New files synced | ☐ Pass ☐ Fail ☐ N/A | |
| Modified files synced | ☐ Pass ☐ Fail ☐ N/A | |
| Deleted files handled | ☐ Pass ☐ Fail ☐ N/A | |

### 3.2 Bi-Directional Sync (bisync)

| Test | Status | Notes |
|------|--------|-------|
| Initial bisync works | ☐ Pass ☐ Fail ☐ N/A | |
| Changes sync both directions | ☐ Pass ☐ Fail ☐ N/A | |
| Conflicts detected | ☐ Pass ☐ Fail ☐ N/A | |
| Conflict resolution works | ☐ Pass ☐ Fail ☐ N/A | |

---

## Section 4: Edge Cases & Error Handling

### 4.1 Filename Edge Cases

| Test | Status | Notes |
|------|--------|-------|
| Filename with spaces | ☐ Pass ☐ Fail ☐ N/A | |
| Filename with special chars (!@#$%) | ☐ Pass ☐ Fail ☐ N/A | |
| Filename with unicode/emoji | ☐ Pass ☐ Fail ☐ N/A | |
| Very long filename | ☐ Pass ☐ Fail ☐ N/A | |
| Hidden files (dot prefix) | ☐ Pass ☐ Fail ☐ N/A | |

### 4.2 Error Scenarios

| Test | Expected Message | Actual Message | Status |
|------|------------------|----------------|--------|
| Invalid credentials | Clear auth error | | ☐ OK ☐ Needs work |
| Network disconnected | Connection error | | ☐ OK ☐ Needs work |
| Rate limited | Retry message | | ☐ OK ☐ Needs work |
| Permission denied | Access error | | ☐ OK ☐ Needs work |
| Quota exceeded | Storage full | | ☐ OK ☐ Needs work |
| File not found | Not found error | | ☐ OK ☐ Needs work |

### 4.3 Provider-Specific Edge Cases

| Edge Case | Status | Notes |
|-----------|--------|-------|
| [Provider-specific issue 1] | ☐ Documented | |
| [Provider-specific issue 2] | ☐ Documented | |
| [Provider-specific issue 3] | ☐ Documented | |

---

## Section 5: Documentation Verification

### 5.1 Guide Completeness

| Section | Present | Quality |
|---------|---------|---------|
| Overview | ☐ Yes ☐ No | ☐ Good ☐ Needs work |
| Prerequisites | ☐ Yes ☐ No | ☐ Good ☐ Needs work |
| Authentication | ☐ Yes ☐ No | ☐ Good ☐ Needs work |
| Setup Steps | ☐ Yes ☐ No | ☐ Good ☐ Needs work |
| Troubleshooting | ☐ Yes ☐ No | ☐ Good ☐ Needs work |
| Edge Cases | ☐ Yes ☐ No | ☐ Good ☐ Needs work |
| References | ☐ Yes ☐ No | ☐ Good ☐ Needs work |

### 5.2 Screenshot/Visual Aids (Optional)

| Item | Included |
|------|----------|
| Auth flow screenshot | ☐ Yes ☐ No ☐ N/A |
| Success connection | ☐ Yes ☐ No ☐ N/A |
| Error example | ☐ Yes ☐ No ☐ N/A |

---

## Section 6: Final Summary

### Test Summary

| Category | Passed | Failed | N/A |
|----------|--------|--------|-----|
| Authentication | | | |
| File Operations | | | |
| Sync Operations | | | |
| Edge Cases | | | |
| Error Handling | | | |
| Documentation | | | |
| **TOTAL** | | | |

### Overall Assessment

☐ **Ready for Production** - All critical tests pass, documentation complete
☐ **Needs Work** - Some tests fail, requires fixes before production
☐ **Research Only** - No test account, documented from external sources

### Issues Found

| Issue | Severity | Follow-up Ticket |
|-------|----------|------------------|
| | ☐ High ☐ Med ☐ Low | #___ |
| | ☐ High ☐ Med ☐ Low | #___ |
| | ☐ High ☐ Med ☐ Low | #___ |

### Recommendations

1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

---

## Checklist Runner Script

To automate parts of this checklist, use:

```bash
./scripts/check-provider.sh [provider-name]
```

This script will:
- Verify guide file exists
- Check required sections are present
- Validate links in documentation

---

*Version 1.0 - Created 2026-01-17*
*Use this checklist for all provider integration studies*
