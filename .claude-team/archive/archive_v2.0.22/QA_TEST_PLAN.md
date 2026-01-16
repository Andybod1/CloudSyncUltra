# Test Plan for Sprint Features

**Tickets:** #10 (Transfer Performance), #20 (Crash Reporting)
**Date:** 2026-01-15
**Sprint:** Launch Ready (v2.0.21)

## Requirements Summary

### #10 - Transfer Performance
Optimize transfer speeds with dynamic parallelism and fast-list support for providers. The TransferOptimizer.swift module adjusts parallelism based on file count and size.

### #20 - Crash Reporting
Add crash reporting capability to track and report application crashes for production monitoring. CrashReportingManager handles crash detection and reporting.

---

## Test Plan: #10 Transfer Performance

### Happy Path Tests
- `test_OptimizeForSingleFile` - Single file uses minimal parallelism
- `test_OptimizeForSmallFiles` - Many small files get high parallelism
- `test_OptimizeForLargeFiles` - Few large files get moderate parallelism
- `test_FastListEnabledForSupported` - Fast-list enabled for supporting providers

### Edge Cases
- `test_OptimizeWithZeroFiles` - Handle empty file list gracefully
- `test_OptimizeWithVeryLargeFileCount` - Handle 10,000+ files without overflow
- `test_NegativeFileSizes` - Guard against invalid file sizes
- `test_MixedFileSizes` - Optimize for mix of small and large files
- `test_ProviderSpecificLimits` - Respect provider-specific parallelism caps

### Error Scenarios
- `test_UnsupportedProvider` - Gracefully handle unknown provider types
- `test_NilFileInfo` - Handle missing file information
- `test_ConcurrentOptimization` - Thread-safe optimization calls
- `test_MemoryPressure` - Reduce parallelism under memory pressure

### Integration Points
- TransferEngine ↔ TransferOptimizer: Verify configuration is applied
- CloudProvider ↔ TransferOptimizer: Provider capabilities detected correctly
- PerformanceMonitor ↔ TransferOptimizer: Metrics tracked accurately

### Performance Tests
- `test_OptimizationSpeed` - Optimization completes < 10ms for 1000 files
- `test_MemoryFootprint` - No significant memory allocation during optimization
- `test_ParallelismScaling` - Verify linear scaling up to provider limits

---

## Test Plan: #20 Crash Reporting

### Happy Path Tests
- `test_InitializeCrashReporter` - Manager initializes correctly
- `test_RecordCrashReport` - Crash data captured with all fields
- `test_SendCrashReport` - Reports sent to backend successfully
- `test_CrashReportPersistence` - Reports saved locally before sending

### Edge Cases
- `test_StartupCrash` - Handle crash during app initialization
- `test_MultipleCrashes` - Queue multiple reports correctly
- `test_LargeCrashLog` - Handle crash with extensive stack trace
- `test_SymbolicatedReport` - Include symbolicated stack traces
- `test_AnonymizedData` - PII removed from crash reports

### Error Scenarios
- `test_NetworkUnavailable` - Queue reports when offline
- `test_BackendTimeout` - Retry logic for failed sends
- `test_CorruptedCrashData` - Handle malformed crash logs
- `test_DiskFull` - Graceful handling when can't save report
- `test_PrivacySettings` - Respect user opt-out preferences

### Integration Points
- AppDelegate ↔ CrashReportingManager: Crash handler registration
- NetworkManager ↔ CrashReporting: Report upload coordination
- UserDefaults ↔ CrashReporting: Privacy preference integration
- Analytics ↔ CrashReporting: Crash metrics tracking

### Privacy & Security Tests
- `test_NoSensitiveData` - Verify no passwords/tokens in reports
- `test_UserConsent` - Only send reports with user permission
- `test_DataRetention` - Old reports cleaned up after 30 days
- `test_EncryptedTransmission` - Reports sent over HTTPS only

---

## Risks & Questions

### Transfer Performance (#10)
- ⚠️ Risk: Provider API rate limits might cap effective parallelism
- ⚠️ Risk: High parallelism could overwhelm slower networks
- ❓ Question: Should parallelism adapt based on network speed?
- ❓ Question: How to handle provider-specific quirks?

### Crash Reporting (#20)
- ⚠️ Risk: GDPR compliance for EU users - need clear consent
- ⚠️ Risk: Crash handler might interfere with debugging
- ❓ Question: Which crash reporting service backend?
- ❓ Question: Should we support offline crash log viewing?

---

## Recommendations for Implementation

### Transfer Performance
- Consider: Add network speed detection for smarter parallelism
- Consider: Implement backoff strategy when transfers fail
- Consider: Add manual override for power users
- Consider: Profile real-world transfer scenarios

### Crash Reporting
- Consider: Add debug mode that bypasses crash handler
- Consider: Implement crash report preview before sending
- Consider: Add crash grouping/deduplication
- Consider: Include breadcrumb trail for context

---

## Test Coverage Metrics

### Target Coverage
- TransferOptimizer.swift: 90%+ line coverage
- CrashReportingManager.swift: 85%+ line coverage
- Edge cases: 100% of identified scenarios
- Integration: End-to-end test for both features

### Test Execution Strategy
1. Unit tests run on every commit
2. Integration tests run before merge
3. Performance tests run nightly
4. Manual testing for crash scenarios

---

**Status:** Test plans created, ready for implementation