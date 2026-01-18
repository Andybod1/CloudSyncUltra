# Sprint: v2.0.41 - Enhancement Backlog

**Started:** 2026-01-18
**Status:** 🟡 PLANNED

---

## Sprint Goal

Clear enhancement backlog - Local Storage security, Nextcloud UX, Enterprise OAuth

---

## Priority 1: High Priority

| # | Issue | Title | Size | Status |
|---|-------|-------|------|--------|
| 167 | [Enhancement] | Local Storage security-scoped bookmarks | M | ⬜ Pending |

**Details:** macOS sandboxing requires security-scoped bookmarks to persist access to user-selected folders across app launches. Without this, Local Storage connections break after restart.

## Priority 2: Low Priority

| # | Issue | Title | Size | Status |
|---|-------|-------|------|--------|
| 162 | [Enhancement] | Nextcloud UX Improvements | S | ⬜ Pending |
| 161 | [Enhancement] | Enterprise OAuth Configuration UI | M | ⬜ Pending |

---

## Task Breakdown

### #167 Local Storage Security-Scoped Bookmarks (M)
1. Add bookmark creation when user selects folder
2. Store bookmark data in UserDefaults/Keychain
3. Resolve bookmark on app launch to restore access
4. Handle bookmark staleness (folder moved/deleted)
5. Update LocalStorageConfigStep in wizard

### #162 Nextcloud UX Improvements (S)
1. Review Nextcloud wizard flow
2. Add server URL validation
3. Improve error messages
4. Add connection status indicators

### #161 Enterprise OAuth Configuration UI (M)
1. Add custom OAuth client ID/secret fields
2. Add custom auth/token endpoint fields
3. Support self-hosted OAuth providers
4. Add documentation/help text

---

## Progress Tracker

- [ ] Priority 1: #167 Local Storage (0/1)
- [ ] Priority 2: #162 Nextcloud, #161 OAuth (0/2)

**Total:** 0/3 issues

---

## Previous Sprint

**v2.0.40** - Completed 2026-01-18
- ✅ Contract Testing (11 tests)
- ✅ Performance Baselines (13 tests)
- ✅ Mutation Testing CI
- ✅ QA Score: 95/100

---

*Last Updated: 2026-01-18*
