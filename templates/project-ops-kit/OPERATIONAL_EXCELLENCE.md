# Operational Excellence Tracker
## Master the Operations → Deliver Unbeatable Quality

> **Goal:** World-class operations that guarantee world-class product
> **Status:** Template - Customize for your project
> **Last Updated:** 2026-01-16

---

## Progress Overview

```
Pillar 1: Automation First       [█████████░] 90%
Pillar 2: Quality Gates          [████████░░] 80%  ← Can reach 100% with branch protection!
Pillar 3: Single Source of Truth [█████████░] 90%
Pillar 4: Metrics & Visibility   [████████░░] 85%  ← Includes CI coverage!
Pillar 5: Knowledge Management   [████████░░] 80%
Pillar 6: Business Operations    [██░░░░░░░░] 20%
─────────────────────────────────────────────────
Overall Progress                 [████████░░] 75%
```

---

## Pillar 1: Automation First 🤖

**Principle:** If a human has to remember it, it will be forgotten.

| Item | Status | Script/File | Notes |
|------|--------|-------------|-------|
| VERSION.txt single source | ✅ Done | `VERSION.txt` | Single version source |
| Version check script | ✅ Done | `scripts/version-check.sh` | Validates all docs |
| Version update script | ✅ Done | `scripts/update-version.sh` | Updates all docs |
| Automated release | ✅ Done | `scripts/release.sh` | Full 6-step automation |
| GitHub Actions CI | ✅ Done | `.github/workflows/ci.yml` | Build + test on push |
| Pre-commit hooks | ✅ Done | `scripts/pre-commit` | Build check, syntax |
| Auto-changelog | ❌ TODO | - | From conventional commits |

---

## Pillar 2: Quality Gates 🚦

**Principle:** Quality enforced by systems, not willpower.

| Item | Status | Location | Notes |
|------|--------|----------|-------|
| Protected main branch | 🔲 Setup Required | GitHub Settings | CI must pass (see instructions below) |
| PR required for changes | 🔲 Setup Required | GitHub Settings | No direct push to main |
| Definition of Done check | ✅ Done | `.claude-team/DEFINITION_OF_DONE.md` | Checklist included |
| Test coverage threshold | ✅ Done | CI workflow | Coverage tracking in CI |
| Build verification | ✅ Done | Pre-commit hooks | Every commit builds |

**🚀 Path to 100%:** Enable branch protection with these commands:
```bash
# Enable branch protection for main (run from project root)
gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  --field required_status_checks='{"strict":true,"contexts":["build-and-test"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":true,"require_code_owner_reviews":false}' \
  --field restrictions=null

# Verify protection is enabled
gh api repos/{owner}/{repo}/branches/main/protection
```

---

## Pillar 3: Single Source of Truth 📋

**Principle:** Every fact exists in exactly one place.

| Item | Status | File | Notes |
|------|--------|------|-------|
| Version number | ✅ Done | `VERSION.txt` | All docs read from here |
| Project config | ✅ Done | `project.json` | Centralized metadata |
| Auto-generate doc stats | ✅ Done | `scripts/generate-stats.sh` | Code/git/issue stats |
| Decision Log (ADRs) | ✅ Done | `docs/decisions/` | Template included |
| API/Architecture docs | 🔲 Setup | `scripts/build-docs.sh` | Swift-DocC (see guide below) |

---

## Pillar 4: Metrics & Visibility 📊

**Principle:** Can't improve what you can't measure.

| Item | Status | Tool | Notes |
|------|--------|------|-------|
| Health dashboard | ✅ Done | `scripts/dashboard.sh` | Health score + alerts |
| Sprint velocity | ✅ Done | Dashboard | 7-day opened vs closed |
| Test count trend | ✅ Done | `.claude-team/metrics/` | Historical data |
| Build success rate | ❌ TODO | GitHub Actions | Historical data |
| Issue age tracking | ✅ Done | Dashboard | Oldest + stale count |
| Code coverage report | ✅ Done | CI workflow | Coverage in artifacts + PR summary |

---

## Pillar 5: Knowledge Management 🧠

**Principle:** Context survives any crash or session change.

| Item | Status | Location | Notes |
|------|--------|----------|-------|
| Session summaries | ✅ Done | `.claude-team/sessions/` | Template + script |
| Worker report archiving | ✅ Done | `tasks/archive/` | Sprint task archiving |
| Context restore script | ✅ Done | `scripts/restore-context.sh` | 2-min onboarding |
| Sprint retrospectives | ✅ Done | `.claude-team/retros/` | Template included |
| Runbook for common tasks | ✅ Done | `docs/RUNBOOK.md` | Step-by-step guides |

---

## Pillar 6: Business Operations 💼

**Principle:** Scale without hiring.

| Item | Status | Tool | Notes |
|------|--------|------|-------|
| App notarization | ❌ TODO | `scripts/notarize.sh` | Platform requirements |
| Store submission | ❌ TODO | `scripts/submit.sh` | Automated upload |
| In-app feedback | ❌ TODO | FeedbackManager | User → GitHub Issue |
| Crash reporting | ❌ TODO | CrashReportingManager | Privacy-first |
| Analytics integration | ❌ TODO | AnalyticsManager | Usage tracking |
| Support automation | ❌ TODO | Email → Issue | Auto-triage |

---

## Scripts Reference

```bash
# Statistics & metrics
./scripts/generate-stats.sh         # Auto-generate project stats
./scripts/record-test-count.sh      # Record test count to CSV

# Session management
./scripts/save-session.sh           # Quick session summary

# Version & release
./scripts/version-check.sh          # Validate doc versions
./scripts/update-version.sh X.Y.Z   # Update all versions
./scripts/release.sh X.Y.Z          # Full automated release

# Quality & health
./scripts/dashboard.sh              # Project health dashboard
./scripts/install-hooks.sh          # Install pre-commit hooks

# Documentation
./scripts/build-docs.sh             # Build Swift-DocC documentation
./scripts/build-docs.sh --open      # Build and open in Xcode
```

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Health Score | - | 95%+ |
| Open Issues | - | <15 |
| Operational Excellence | 70% | 80%+ |

---

## Branch Protection Setup Guide 🛡️

**Why:** Prevents accidental direct pushes to main, ensures all changes go through CI

### Quick Setup (GitHub CLI)

1. **Install GitHub CLI if needed:**
```bash
# macOS
brew install gh
gh auth login

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
gh auth login
```

2. **Enable branch protection:**
```bash
# Replace {owner} and {repo} with your values
gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  --field required_status_checks='{"strict":true,"contexts":["build-and-test"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":true,"require_code_owner_reviews":false}' \
  --field restrictions=null
```

3. **Verify it worked:**
```bash
gh api repos/{owner}/{repo}/branches/main/protection
```

### Manual Setup (GitHub UI)

1. Go to Settings → Branches
2. Add rule for `main` branch:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - Select "build-and-test" as required status check
3. Save changes

### After Setup

- All changes must go through PRs
- CI must pass before merging
- Direct pushes to main will be blocked
- Update Pillar 2 to 100% 🎉

---

## Swift-DocC Setup Guide 📚

**Why:** Auto-generated API documentation stays in sync with code (single source of truth)

### Quick Setup

1. **Run the build script (creates template if needed):**
```bash
./scripts/build-docs.sh
```

2. **Edit the generated documentation catalog:**
```
YourApp/YourApp.docc/
├── YourApp.md          # Landing page - edit topics
├── GettingStarted.md   # Tutorial article
└── Resources/          # Images, etc.
```

3. **Build and view:**
```bash
./scripts/build-docs.sh --open
```

### Landing Page Template

```markdown
# ``YourApp``

Brief description of your app.

## Overview

Detailed overview of features and capabilities.

## Topics

### Essentials
- <doc:GettingStarted>
- <doc:Architecture>

### Core Types
- ``MainModel``
- ``ViewModel``
- ``Manager``
```

### Writing Good Doc Comments

Use `///` comments in Swift for auto-generated docs:

```swift
/// Manages cloud storage operations.
///
/// Use this manager to list, upload, and download files
/// from configured cloud providers.
///
/// - Note: Requires rclone to be installed.
class CloudManager {
    /// Lists files at the specified path.
    /// - Parameters:
    ///   - path: The remote path to list
    ///   - recursive: Whether to list subdirectories
    /// - Returns: Array of file items
    /// - Throws: `CloudError` if the operation fails
    func listFiles(at path: String, recursive: Bool) async throws -> [FileItem]
}
```

### View in Xcode

1. Product → Build Documentation (⌃⇧⌘D)
2. Window → Developer Documentation
3. Search for your module name

### After Setup

- Update Pillar 3 to 100% 🎉
- Add documentation build to CI (optional)

---

*This tracker is the roadmap to operational excellence.*
*Update after each improvement.*
