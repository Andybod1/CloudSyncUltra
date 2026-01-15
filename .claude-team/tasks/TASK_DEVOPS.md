# Dev-Ops Task: Documentation & Release Prep

**Sprint:** Launch Ready (v2.0.21)
**Created:** 2026-01-15
**Worker:** Dev-Ops
**Model:** Opus (always use /think)

---

## Context

Sprint focuses on launch readiness. Dev-Ops supports with documentation updates and release preparation.

---

## Your Files (Exclusive Ownership)

```
.github/
scripts/
docs/
CHANGELOG.md
CONTRIBUTING.md
README.md
```

---

## Objectives

### 1. Sprint Support

- Monitor CI pipeline for all worker commits
- Help resolve any build/test failures
- Update documentation as features complete

### 2. Documentation Updates

**As sprint progresses, update:**
- README.md - feature list if new features added
- docs/ - any new user-facing features
- CHANGELOG.md - track sprint changes (will finalize at end)

### 3. Release Preparation

**Pre-release checklist:**
- [ ] All worker commits merged
- [ ] CI green on main
- [ ] version-check.sh passes
- [ ] CHANGELOG.md has v2.0.21 section
- [ ] Test count updated in docs
- [ ] No uncommitted changes

### 4. GitHub Housekeeping

**During sprint:**
- Add `in-progress` label to active issues
- Update issue comments with progress

**End of sprint:**
- Close completed issues
- Update labels

---

## Commands

```bash
# Check CI status
gh run list --limit 5

# Version check
./scripts/version-check.sh

# Dashboard
./scripts/dashboard.sh

# Close issue
gh issue close <number> -c "Completed in v2.0.21"
```

---

## Sprint Issues to Track

| # | Issue | Worker | Status |
|---|-------|--------|--------|
| #77 | App Icon | Dev-1 | 🔄 |
| #44 | UI Review | Dev-1 | 🔄 |
| #10 | Transfer Performance | Dev-2 | 🔄 |
| #20 | Crash Reporting | Dev-3 | 🔄 |
| #27 | Test Automation | QA | 🔄 |

---

*Coordinate with Strategic Partner for release timing*
