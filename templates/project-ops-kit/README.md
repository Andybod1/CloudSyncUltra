# Project Operations Kit

> **Reusable operational excellence template for any project**
> 
> One-person. Billion-dollar operations.

---

## What's Included

| Component | Purpose |
|-----------|---------|
| `project.conf` | Project-specific settings (edit this first!) |
| `scripts/dashboard.sh` | Command center with health score |
| `scripts/restore-context.sh` | 2-min onboarding for new sessions |
| `scripts/archive-outputs.sh` | Archive old worker reports |
| `scripts/version-check.sh` | Validate doc versions match |
| `scripts/update-version.sh` | Update version everywhere |
| `scripts/release.sh` | One-command release process |
| `.claude-team/` | Worker coordination structure |
| `.github/workflows/ci.yml` | CI pipeline template |
| `OPERATIONAL_EXCELLENCE.md` | Progress tracker |

---

## Quick Setup (5 minutes)

### 1. Copy to Your Project

```bash
# From your new project root:
cp -r /Users/antti/Claude/templates/project-ops-kit/* .
cp -r /Users/antti/Claude/templates/project-ops-kit/.* . 2>/dev/null || true
```

### 2. Edit project.conf

```bash
nano project.conf
```

Update these values:
```bash
PROJECT_NAME="Your Project Name"
PROJECT_DESCRIPTION="Short description"
GITHUB_REPO="username/repo-name"
BUILD_COMMAND="your build command"
TEST_COMMAND="your test command"
```

### 3. Run Setup

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

### 4. Verify

```bash
./scripts/dashboard.sh
./scripts/restore-context.sh
```

---

## Adapting for Different Tech Stacks

### Swift/Xcode (macOS)
```bash
BUILD_COMMAND="xcodebuild -project App.xcodeproj -scheme App build 2>&1 | tail -5"
TEST_COMMAND="xcodebuild test -project App.xcodeproj -scheme App -destination 'platform=macOS'"
```

### Node.js
```bash
BUILD_COMMAND="npm run build"
TEST_COMMAND="npm test"
```

### Python
```bash
BUILD_COMMAND="python -m py_compile src/*.py"
TEST_COMMAND="pytest"
```

### Rust
```bash
BUILD_COMMAND="cargo build"
TEST_COMMAND="cargo test"
```

### Go
```bash
BUILD_COMMAND="go build ./..."
TEST_COMMAND="go test ./..."
```

---

## CI Pipeline

The included `.github/workflows/ci.yml` is a template. Customize for your stack:

- **Xcode**: Uses `macos-14` runner
- **Node/Python/Go**: Uses `ubuntu-latest` runner

---

## Worker Team Structure

The `.claude-team/` folder supports parallel AI workers:

```
Strategic Partner (Opus) ─── Oversight
    ├── Dev-1 (Sonnet/Opus) ─ UI/Frontend
    ├── Dev-2 (Sonnet/Opus) ─ Core/Engine
    ├── Dev-3 (Sonnet/Opus) ─ Services/API
    ├── QA (Opus) ─────────── Testing
    └── Dev-Ops (Opus) ────── Git/CI/Docs
```

Adjust roles in `.claude-team/templates/` for your project.

---

## Health Score Calculation

The dashboard calculates health from:

| Factor | Deduction |
|--------|-----------|
| No CI configured | -15% |
| Version mismatch | -10% |
| Critical issues | -10% |
| Triage backlog >10 | -5% |
| Uncommitted changes >5 | -5% |
| Output files >20 | -5% |
| Negative velocity | -10% |

Target: **90%+ health score**

---

## Files to Customize

| File | What to Change |
|------|----------------|
| `project.conf` | All project-specific settings |
| `.github/workflows/ci.yml` | Build/test commands, runner |
| `.claude-team/templates/*` | Worker briefings for your domain |
| `CLAUDE_PROJECT_KNOWLEDGE.md` | Your project's knowledge base |

---

## Commands Reference

```bash
./scripts/dashboard.sh              # Health overview
./scripts/restore-context.sh        # Quick onboarding
./scripts/release.sh 1.0.0          # Release new version
./scripts/version-check.sh          # Verify doc versions
./scripts/update-version.sh 1.0.1   # Update all versions
./scripts/archive-outputs.sh        # Clean up reports
```

---

*Built from CloudSync Ultra's operational excellence framework*
