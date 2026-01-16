# GitHub Actions CI/CD Implementation Plan

> **Goal:** Make broken builds impossible to ship
> **Prepared:** 2026-01-14
> **Status:** Planning

---

## Overview

### What We're Building

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions CI Pipeline                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TRIGGER: Push to main / Pull Request                          │
│      │                                                          │
│      ▼                                                          │
│  ┌─────────────┐                                                │
│  │ 1. CHECKOUT │ Get code                                       │
│  └──────┬──────┘                                                │
│         ▼                                                       │
│  ┌─────────────┐                                                │
│  │ 2. SETUP    │ Xcode, rclone, cache                          │
│  └──────┬──────┘                                                │
│         ▼                                                       │
│  ┌─────────────┐                                                │
│  │ 3. BUILD    │ xcodebuild build                              │
│  └──────┬──────┘                                                │
│         ▼                                                       │
│  ┌─────────────┐                                                │
│  │ 4. TEST     │ xcodebuild test (743 tests)                   │
│  └──────┬──────┘                                                │
│         ▼                                                       │
│  ┌─────────────┐                                                │
│  │ 5. VALIDATE │ version-check.sh                              │
│  └──────┬──────┘                                                │
│         ▼                                                       │
│  ┌─────────────┐                                                │
│  │ 6. REPORT   │ Status badge, annotations                     │
│  └─────────────┘                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Requirements

| Requirement | Value |
|-------------|-------|
| Platform | macOS 14.0+ |
| Swift | 5.0 |
| Xcode | 15.0+ (for macOS 14 SDK) |
| Dependencies | rclone (via Homebrew) |
| Test Count | 743 tests |
| Build Time (est.) | 3-5 minutes |

---

## Implementation Plan

### Phase 1: Basic CI (Today)

**File:** `.github/workflows/ci.yml`

**Triggers:**
- Push to `main` branch
- Pull requests to `main`

**Jobs:**
1. **Build** - Compile the app
2. **Test** - Run all 743 tests
3. **Validate** - Run version-check.sh

**Deliverable:** Green checkmark on every commit

---

### Phase 2: Enhanced CI (This Week)

**Additional checks:**
- Code coverage report
- SwiftLint (code style)
- Documentation validation
- Artifact upload (build output)

---

### Phase 3: CD - Continuous Deployment (Later)

**Automated releases:**
- Build signed app
- Notarize with Apple
- Create GitHub Release
- Upload to App Store Connect

---

## Workflow File Design

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  DEVELOPER_DIR: /Applications/Xcode.app/Contents/Developer

jobs:
  build-and-test:
    name: Build & Test
    runs-on: macos-14
    
    steps:
      # 1. Checkout
      - uses: actions/checkout@v4
      
      # 2. Setup
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app
      
      - name: Install rclone
        run: brew install rclone
      
      - name: Cache DerivedData
        uses: actions/cache@v4
        with:
          path: ~/Library/Developer/Xcode/DerivedData
          key: deriveddata-${{ hashFiles('**/*.swift') }}
      
      # 3. Build
      - name: Build
        run: |
          xcodebuild build \
            -project CloudSyncApp.xcodeproj \
            -scheme CloudSyncApp \
            -destination 'platform=macOS' \
            | xcpretty
      
      # 4. Test
      - name: Run Tests
        run: |
          xcodebuild test \
            -project CloudSyncApp.xcodeproj \
            -scheme CloudSyncApp \
            -destination 'platform=macOS' \
            | xcpretty --report junit
      
      # 5. Validate
      - name: Version Check
        run: ./scripts/version-check.sh
      
      # 6. Upload Results
      - name: Upload Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: build/reports/

  validate-docs:
    name: Validate Documentation
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Check Version Consistency
        run: ./scripts/version-check.sh
```

---

## Estimated Costs

| Resource | Free Tier | Our Usage |
|----------|-----------|-----------|
| macOS minutes | 2,000/month | ~50-100/month |
| Storage | 500MB | ~100MB |
| Artifacts | 500MB | ~50MB |

**Cost:** FREE (well within limits)

---

## Implementation Steps

### Step 1: Create Workflow File
```bash
# Create the CI workflow
touch .github/workflows/ci.yml
# Add workflow content
```

### Step 2: Test Locally First
```bash
# Verify our scripts work
./scripts/version-check.sh

# Verify build command
xcodebuild build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp

# Verify test command  
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS'
```

### Step 3: Push and Verify
```bash
git add .github/workflows/ci.yml
git commit -m "ci: Add GitHub Actions CI pipeline"
git push origin main
```

### Step 4: Add Status Badge
```markdown
# In README.md
![CI](https://github.com/andybod1-lang/CloudSyncUltra/actions/workflows/ci.yml/badge.svg)
```

### Step 5: Enable Branch Protection (Optional)
```
GitHub → Settings → Branches → Add rule
- Branch: main
- Require status checks: build-and-test
```

---

## Success Criteria

| Metric | Target |
|--------|--------|
| Build passes | Every commit |
| Tests pass | 743/743 |
| Version check | All docs match |
| CI runtime | < 10 minutes |
| False failures | < 1% |

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| macOS runner unavailable | Can't test | Use self-hosted runner as backup |
| rclone tests need credentials | Tests fail | Mock rclone for CI |
| Long build times | Slow feedback | Cache DerivedData aggressively |
| Flaky tests | False failures | Identify and fix flaky tests |

---

## Questions to Resolve

1. **Do any tests require actual cloud credentials?**
   - If yes, we need GitHub Secrets or mocking

2. **Should we block merges on CI failure?**
   - Recommended: Yes, after CI is stable

3. **Do we want PR-based workflow or direct push?**
   - Current: Direct push to main
   - Future: PR-based with required reviews

---

## Ready to Implement?

**Estimated time:** 1-2 hours

**Steps:**
1. ⬜ Create `.github/workflows/ci.yml`
2. ⬜ Test workflow triggers
3. ⬜ Add status badge to README
4. ⬜ Update OPERATIONAL_EXCELLENCE.md progress
5. ⬜ (Optional) Enable branch protection

---

*Plan approved by: ________________*
