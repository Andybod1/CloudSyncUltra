# Dev-3 Task: Crash Reporting

**Sprint:** Launch Ready (v2.0.21)
**Created:** 2026-01-15
**Worker:** Dev-3 (Services)
**Model:** Opus (use /think for architecture decisions)
**Issues:** #20

---

## Context

Production apps need crash reporting to identify and fix issues users encounter. This is essential for launch readiness - we need visibility into real-world crashes.

---

## Your Files (Exclusive Ownership)

```
CloudSyncApp/Models/
CloudSyncApp/*Manager.swift (except RcloneManager)
CloudSyncApp/Services/
CloudSyncApp/CrashReportingManager.swift (if exists)
```

---

## Objectives

### Issue #20: Crash Reporting

**Requirements:**
1. Capture unhandled exceptions
2. Capture signal-based crashes (SIGSEGV, etc.)
3. Log stack traces
4. Store crash reports locally
5. (Optional) Send to backend

**Investigation:**
- Check existing CrashReportingManager.swift
- Review Apple's crash reporting APIs
- Consider MetricKit for App Store builds
- NSSetUncaughtExceptionHandler for exceptions

**Approach:**
1. Audit existing crash reporting code
2. Implement missing functionality
3. Add crash report storage (local file)
4. Add crash report viewing in Settings
5. Test with intentional crashes (debug only)
6. Add tests

**Implementation Checklist:**
- [ ] Exception handler installed
- [ ] Signal handlers for SIGSEGV, SIGABRT, SIGBUS
- [ ] Stack trace symbolication
- [ ] Crash report model (date, type, stack, device info)
- [ ] Local storage (JSON files in App Support)
- [ ] Previous crash detection on launch
- [ ] Settings UI to view/clear crash reports

---

## Deliverables

1. [ ] CrashReportingManager complete
2. [ ] Crash reports stored locally
3. [ ] Settings integration for viewing
4. [ ] Tests pass
5. [ ] Commit with descriptive message

---

## Commands

```bash
# Build & test
cd ~/Claude && xcodebuild build 2>&1 | tail -5

# Check existing crash code
find CloudSyncApp -name "*.swift" | xargs grep -l -i "crash\|exception"

# Run tests
xcodebuild test -destination 'platform=macOS' 2>&1 | grep "Executed"
```

---

*Report completion to Strategic Partner when done*
