# Dev-Ops Task: Issue Cleanup & GitHub Templates

**Created:** 2026-01-14 22:20
**Worker:** Dev-Ops
**Model:** Opus with /think
**Issues:** #57, #47, plus housekeeping

---

## Context

Sprint housekeeping: close completed issues, add GitHub issue templates, update documentation.

---

## Your Files (Exclusive Ownership)

```
.github/                    # GitHub config
CHANGELOG.md               # Version history
docs/*.md                  # Documentation (except test docs)
.claude-team/outputs/      # Reports
```

---

## Objectives

### Task 1: Close Completed Issues

Per CLAUDE_PROJECT_KNOWLEDGE.md v2.0.18, these are already done:

```bash
# Close with comments
gh issue close 72 -c "Already implemented in v2.0.18 - Multi-thread downloads with 30+ tests"
gh issue close 90 -c "Completed in v2.0.18 - NotificationManager verified working"
gh issue close 92 -c "Completed in v2.0.18 - CONTRIBUTING.md created (450+ lines)"
gh issue close 91 -c "Completed - CHANGELOG.md exists and maintained"
```

### Task 2: Issue #57 - GitHub Issue Templates

Create YAML-based issue templates:

**File: `.github/ISSUE_TEMPLATE/bug_report.yml`**
```yaml
name: Bug Report
description: Report a bug or unexpected behavior
title: "[Bug]: "
labels: ["bug", "triage"]
body:
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: What happened?
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: How can we reproduce this?
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
  - type: dropdown
    id: component
    attributes:
      label: Component
      options:
        - UI/Views
        - Core Engine
        - Services
        - Encryption
        - Menu Bar
        - Other
  - type: input
    id: version
    attributes:
      label: App Version
      placeholder: "e.g., 2.0.19"
```

**File: `.github/ISSUE_TEMPLATE/feature_request.yml`**
```yaml
name: Feature Request
description: Suggest a new feature or enhancement
title: "[Feature]: "
labels: ["enhancement", "triage"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem or Need
      description: What problem does this solve?
    validations:
      required: true
  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
  - type: dropdown
    id: priority
    attributes:
      label: Priority
      options:
        - Nice to have
        - Important
        - Critical
```

**File: `.github/ISSUE_TEMPLATE/config.yml`**
```yaml
blank_issues_enabled: true
contact_links:
  - name: Documentation
    url: https://github.com/Andybod1/CloudSyncUltra/wiki
    about: Check our documentation first
```

### Task 3: Issue #47 - Component Labels

Verify these labels exist on GitHub (create if missing):

```bash
# Check existing labels
gh label list

# Create any missing component labels
gh label create "component:encryption" --color "BFDADC" --description "Encryption features" 2>/dev/null || true
gh label create "component:scheduling" --color "D4E5F7" --description "Scheduled sync" 2>/dev/null || true
gh label create "component:menu-bar" --color "F9D0C4" --description "Menu bar features" 2>/dev/null || true
```

### Task 4: Prepare CHANGELOG Entry

Draft changelog entry for this sprint (don't commit yet - wait for sprint completion):

```markdown
## [2.0.20] - 2026-01-14

### Added
- First-time user onboarding flow (#80, #81, #82)
- Dynamic parallelism based on provider and file size (#70)
- Fast-list support for compatible providers (#71)
- Provider brand colors and improved icons (#95)
- GitHub issue templates (#57)

### Changed
- Visual consistency improvements across all views (#84)
- UI tests integrated and verified (#88)

### Fixed
- (list any bugs fixed)
```

---

## Deliverables

1. **Closed Issues:** #72, #90, #91, #92

2. **New Files:**
   - `.github/ISSUE_TEMPLATE/bug_report.yml`
   - `.github/ISSUE_TEMPLATE/feature_request.yml`
   - `.github/ISSUE_TEMPLATE/config.yml`

3. **Label Updates:** Verify component labels exist

4. **Draft:** CHANGELOG entry (save to `.claude-team/outputs/CHANGELOG_DRAFT.md`)

5. **Git Commit:**
   ```
   chore(github): Add issue templates and close completed issues
   
   - Bug report template with component dropdown (#57)
   - Feature request template with priority (#57)
   - Verify component labels exist (#47)
   - Close issues #72, #90, #91, #92 (already done)
   
   Implements #57, #47
   ```

---

## Notes

- Use /think for template structure decisions
- Don't modify CHANGELOG.md yet - just draft it
- Verify all gh commands work before committing
- Check that templates render correctly on GitHub
