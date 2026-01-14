# TASK: Implement GitHub Actions CI Pipeline

> **Worker:** Dev-Ops
> **Model:** Opus + /think (MANDATORY - use extended thinking for all decisions)
> **Priority:** 🔴 Critical
> **Estimated Time:** 1-2 hours

## ⚠️ Extended Thinking Required

Use `/think` before:
- Designing the workflow structure
- Writing the CI yaml file
- Making any commits
- Updating documentation

Example: `/think What's the best way to structure this CI workflow for reliability and speed?`

---

## Objective

Implement a GitHub Actions CI pipeline that makes broken builds impossible to ship.

---

## Context

Read the full implementation plan:
```bash
cat /Users/antti/Claude/.claude-team/planning/CI_IMPLEMENTATION_PLAN.md
```

**Current State:**
- `.github/workflows/` directory exists but is empty
- No CI/CD automation currently
- 743 tests, all passing locally
- `scripts/version-check.sh` validates doc versions

**Project Requirements:**
- macOS 14.0+ deployment target
- Swift 5.0
- Depends on rclone (brew install rclone)
- Tests use xcodebuild

---

## Deliverables

### 1. Create CI Workflow File
**File:** `.github/workflows/ci.yml`

**Must include:**
- Trigger on push to main AND pull requests
- macOS runner (macos-14)
- Xcode setup
- rclone installation via Homebrew
- DerivedData caching for faster builds
- Build step (xcodebuild build)
- Test step (xcodebuild test)
- Version check step (./scripts/version-check.sh)
- Test results artifact upload

### 2. Add Status Badge to README.md
```markdown
![CI](https://github.com/andybod1-lang/CloudSyncUltra/actions/workflows/ci.yml/badge.svg)
```

### 3. Verify Pipeline Works
- Push the workflow
- Watch the first run complete
- Ensure all steps pass
- Fix any issues

### 4. Update Documentation
- Update `OPERATIONAL_EXCELLENCE.md` - mark GitHub Actions CI as ✅ Done
- Update progress percentage for Pillar 1

---

## Technical Notes

### Build Command
```bash
xcodebuild build \
  -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -destination 'platform=macOS'
```

### Test Command
```bash
xcodebuild test \
  -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -destination 'platform=macOS'
```

### Version Check
```bash
./scripts/version-check.sh
```

---

## Success Criteria

- [ ] CI workflow file created and committed
- [ ] First CI run completes successfully
- [ ] Build step passes
- [ ] All 743 tests pass
- [ ] version-check.sh passes
- [ ] Status badge visible in README
- [ ] OPERATIONAL_EXCELLENCE.md updated

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `.github/workflows/ci.yml` | CREATE |
| `README.md` | ADD badge |
| `.claude-team/OPERATIONAL_EXCELLENCE.md` | UPDATE progress |
| `.claude-team/STATUS.md` | UPDATE when complete |

---

## When Complete

1. Update STATUS.md with completion
2. Create output report: `.claude-team/outputs/DEVOPS_CI_COMPLETE.md`
3. Commit all changes with message: `ci: Add GitHub Actions CI pipeline`
4. Push to GitHub

---

*Task assigned by Strategic Partner*
