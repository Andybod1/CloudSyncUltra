# TASK: IAP & Security Testing

## Ticket
**Type:** QA Testing
**Size:** M (1-2 hours)
**Priority:** High (pre-launch validation)

---

## Objective

Comprehensive testing of StoreKit 2 subscriptions and security hardening before App Store submission.

---

## Dependencies

Wait for completion of:
- **Revenue-Engineer**: StoreKit 2 implementation (#46)
- **Dev-3**: Security hardening (#74)

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
| Family sharing (if applicable) | Shared access works |

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

### Test File: SecurityTests.swift

```swift
// Tests to create:
- testLogFilePermissions()
- testConfigFilePermissions()
- testPathTraversalBlocked()
- testTempFileCleanup()
- testSecureTempFileCreation()
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
- [ ] All 743+ existing tests pass
- [ ] Transfer functionality works
- [ ] OAuth flows unchanged
- [ ] UI navigation intact

---

## Deliverables

1. **StoreKitManagerTests.swift** - New test file for IAP
2. **SecurityTests.swift** - New test file for security (or add to existing)
3. **QA Report** - `.claude-team/outputs/QA_v2023_REPORT.md`

### Report Template

```markdown
# QA Report: Sprint v2.0.23

## Summary
- Tests: XXX total (XXX passing)
- New Tests: XX added
- Coverage: XX%

## StoreKit Testing
| Test | Status |
|------|--------|
| ... | ✅/❌ |

## Security Testing
| Test | Status |
|------|--------|
| ... | ✅/❌ |

## Regression
- All existing tests: ✅/❌
- Manual smoke test: ✅/❌

## Issues Found
- [List any issues]

## Recommendation
Ready for TestFlight: YES/NO
```

---

## Acceptance Criteria

- [ ] StoreKit tests written and passing
- [ ] Security tests written and passing
- [ ] Full regression suite passes
- [ ] QA report completed
- [ ] No critical issues blocking release
- [ ] TestFlight validation successful

---

## Notes

- Use /think always for thorough test planning
- Coordinate with Revenue-Engineer and Dev-3 for timing
- Document any edge cases found

---

*Task created: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready"*
