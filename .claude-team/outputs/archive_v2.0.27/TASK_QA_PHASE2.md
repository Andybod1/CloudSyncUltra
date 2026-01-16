# TASK: QA Phase 2 - IAP & Security Testing

## Ticket
**Type:** QA Testing
**Size:** M (1-2 hours)
**Priority:** High (pre-launch validation)
**Phase:** 2 (after Sprint v2.0.23 Phase 1 completes)

---

## Prerequisites

**Wait for completion of:**
- ✅ **Revenue-Engineer**: StoreKit 2 implementation (#46)
- ✅ **Dev-3**: Security hardening (#74)

**Do not start until both are marked complete in STATUS.md**

---

## Objective

Comprehensive testing of StoreKit 2 subscriptions and security hardening before App Store submission.

---

## Part 1: StoreKit/IAP Testing

### Sandbox Testing Setup
1. Use Xcode StoreKit Configuration file for local testing
2. Create sandbox Apple ID for App Store Connect testing
3. Test all subscription tiers

### Test Scenarios

| Scenario | Expected Result |
|----------|-----------------|
| Fresh install (no purchase) | Free tier features only |
| Purchase Pro subscription | Pro features unlocked |
| Cancel subscription | Grace period, then downgrade |
| Restore purchases | Previous subscription restored |
| Expired subscription | Downgrade to Free |

### Subscription State Tests
- [ ] Free → Pro upgrade flow
- [ ] Pro → Free downgrade (expiry)
- [ ] Restore on new device
- [ ] Receipt validation
- [ ] Offline behavior
- [ ] Network failure during purchase

### Test File: StoreKitManagerTests.swift

```swift
// Tests to create:
- testFreshInstallShowsFreeTier()
- testPurchaseProUnlocksFeatures()
- testRestorePurchasesWorks()
- testExpiredSubscriptionDowngrades()
- testOfflinePurchaseHandling()
- testReceiptValidation()
- testFeatureGatingFreeUser()
- testFeatureGatingProUser()
```

---

## Part 2: Security Testing

### Permission Tests
- [ ] Log files have 600 permissions
- [ ] Config files have 600 permissions
- [ ] Temp files properly secured
- [ ] Temp files cleaned up

### Path Validation Tests
- [ ] Path traversal blocked (`../`)
- [ ] Null byte injection blocked
- [ ] Symbolic link handling
- [ ] Special characters handled

### Test File: SecurityTests.swift (or add to existing)

```swift
// Tests to create:
- testLogFilePermissions()
- testConfigFilePermissions()
- testPathTraversalBlocked()
- testTempFileCleanup()
- testSecureTempFileCreation()
- testPathSanitization()
```

---

## Part 3: Regression Suite

Run full test suite to ensure no regressions:

```bash
xcodebuild test -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -destination 'platform=macOS' \
  2>&1 | grep -E "Executed|passed|failed"
```

### Key Areas to Verify
- [ ] All existing tests pass (743+)
- [ ] Transfer functionality works
- [ ] OAuth flows unchanged
- [ ] UI navigation intact
- [ ] New StoreKit code doesn't break existing features

---

## Part 4: Integration Testing

### Manual Test Checklist

**StoreKit Flow:**
- [ ] Launch app → Free tier active
- [ ] Open paywall → Tiers display correctly
- [ ] Purchase Pro (sandbox) → Features unlock
- [ ] Restart app → Subscription persists
- [ ] Restore purchases → Works correctly

**Security Flow:**
- [ ] Create new log → Check permissions (600)
- [ ] Add remote → Config file secured
- [ ] Attempt path traversal → Blocked
- [ ] Check temp files → Cleaned up after transfer

---

## Deliverables

1. **StoreKitManagerTests.swift** - New test file for IAP
2. **SecurityTests.swift** - Security tests (new or added to existing)
3. **QA Report** - `.claude-team/outputs/QA_v2023_PHASE2_REPORT.md`

### Report Template

```markdown
# QA Report: Sprint v2.0.23 Phase 2

## Summary
- Tests: XXX total (XXX passing)
- New Tests: XX added
- Coverage: XX%

## StoreKit Testing
| Test | Status | Notes |
|------|--------|-------|
| Fresh install free tier | ✅/❌ | |
| Purchase flow | ✅/❌ | |
| Restore purchases | ✅/❌ | |
| Feature gating | ✅/❌ | |

## Security Testing
| Test | Status | Notes |
|------|--------|-------|
| Log permissions | ✅/❌ | |
| Config permissions | ✅/❌ | |
| Path traversal | ✅/❌ | |
| Temp file cleanup | ✅/❌ | |

## Regression
- All existing tests: ✅/❌
- Manual smoke test: ✅/❌

## Issues Found
- [List any issues]

## Recommendation
Ready for TestFlight: YES/NO
Ready for App Store: YES/NO
```

---

## Acceptance Criteria

- [ ] StoreKit tests written and passing
- [ ] Security tests written and passing
- [ ] Full regression suite passes
- [ ] Manual integration tests pass
- [ ] QA report completed
- [ ] No critical issues blocking release
- [ ] Recommend ready for TestFlight

---

## Notes

- Use /think always for thorough test planning
- Test in Xcode sandbox environment first
- Document any edge cases discovered
- Coordinate with Strategic Partner if blockers found

---

*Task created: 2026-01-15*
*Phase: 2 (after Phase 1 completes)*
*Sprint: v2.0.23 "Launch Ready"*
