# Sprint v2.0.23 Planning
> "Security & Polish"
> Target: After v2.0.22 completion

---

## Sprint Goals

1. **Security hardening** - Address audit findings
2. **Performance UI** - User control over sync settings
3. **Provider expansion** - Dropbox support
4. **Accessibility** - Keyboard navigation

---

## Proposed Tickets

### Dev-1: Performance Settings UI (#40)
**Size:** M | **Est:** 1-2 hours

Create a dedicated Performance Settings panel:
- Bandwidth limit controls (upload/download)
- Concurrent transfer slider
- Chunk size presets
- Provider-specific overrides toggle

**Files:** Views/PerformanceSettingsView.swift, SettingsView.swift

---

### Dev-2: Dropbox Support (#37)
**Size:** M | **Est:** 1-2 hours

Add Dropbox as supported provider:
- OAuth flow implementation
- Provider configuration in CloudProvider.swift
- Dropbox-specific settings
- Test with real Dropbox account

**Files:** Models/CloudProvider.swift, RcloneManager.swift

---

### Dev-3: Secure File Handling (#74)
**Size:** M | **Est:** 1-2 hours

Security audit findings VULN-007/008:
- Restrict log file permissions (600)
- Secure config file permissions
- Sanitize file paths in logs
- Add secure temp file handling

**Files:** Logger+Extensions.swift, RcloneManager.swift

---

### QA: Security & Integration Tests
**Size:** M | **Est:** 1-2 hours

- Write security tests for #74 fixes
- Integration tests for Dropbox
- Performance settings validation tests
- Regression test suite run

---

### Dev-Ops: Keyboard Navigation Audit (#54)
**Size:** S | **Est:** 30-60 min

Audit and document keyboard navigation:
- Tab order through all views
- Focus indicators
- Escape key handling
- Document accessibility shortcuts

---

## Capacity Planning

| Worker | Ticket | Size | Model |
|--------|--------|------|-------|
| Dev-1 | #40 Performance Settings UI | M | Opus |
| Dev-2 | #37 Dropbox Support | M | Opus |
| Dev-3 | #74 Secure File Handling | M | Opus |
| QA | Security & Integration Tests | M | Opus |
| Dev-Ops | #54 Keyboard Nav Audit | S | Opus |

**Total Sprint Size:** 4M + 1S = ~5-7 hours parallel work

---

## Dependencies

- #40 depends on: #73 (chunk sizes) - completing this sprint
- #37 requires: Test Dropbox account credentials
- #74 requires: Security audit report reference

---

## Success Criteria

- [ ] Performance Settings UI functional and tested
- [ ] Dropbox OAuth flow working end-to-end
- [ ] Log/config file permissions hardened
- [ ] All security tests passing
- [ ] Keyboard navigation documented
- [ ] VERSION → 2.0.23
- [ ] All changes committed and pushed

---

## Alternatives Considered

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| #48 Analytics Dashboard | User value | Large (L) | Defer to v2.0.24 |
| #45 Business Logic | Strategic | Needs Product-Manager | Defer |
| #75 Input Validation | Security | Can batch with #74 | Consider adding |

---

*Sprint planned by Strategic Partner*
*Ready to execute after v2.0.22 integration*
