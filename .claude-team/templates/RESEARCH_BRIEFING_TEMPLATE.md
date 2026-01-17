# Research Briefing: [Worker-ID]
## Issue #[NUMBER]: [Integration Study Title]

**Sprint:** v[X.X.X]
**Priority:** [High/Medium/Low]
**Size:** [S/M/L]
**Worker:** [Dev-Ops / QA / Specialized Agent]
**Type:** Research / Integration Study

---

## Objective

[Clear description of what needs to be researched and documented. 2-3 sentences max.]

---

## Provider Details

| Field | Value |
|-------|-------|
| **Provider Name** | [e.g., Amazon S3] |
| **rclone backend** | [e.g., `s3`] |
| **Auth type** | [e.g., Access Key + Secret Key] |
| **Complexity** | [Low/Medium/High] |
| **Category** | [Object Storage / Self-Hosted / Consumer / Enterprise] |

---

## Research Scope

### 1. Authentication Flow
- [ ] Document primary auth method
- [ ] Document alternative auth methods (if any)
- [ ] Identify 2FA/MFA requirements
- [ ] Note token refresh/session handling

### 2. Edge Cases to Investigate
- [ ] File size limits
- [ ] Character encoding issues
- [ ] Rate limiting behavior
- [ ] Error message quality
- [ ] Special folder/path handling

### 3. CloudSync Integration Points
- [ ] Required UI fields
- [ ] Config parameters for rclone
- [ ] Error handling requirements
- [ ] Any special wizard steps needed

### 4. Security Considerations
- [ ] Credential storage requirements
- [ ] Key rotation recommendations
- [ ] Encryption options

---

## Deliverables

### 1. Provider Guide (REQUIRED)
**File:** `docs/providers/[PROVIDER]_GUIDE.md`

Must include these sections:
```markdown
# [Provider] Integration Guide

## Overview
[What is this provider, who uses it]

## Prerequisites
[What user needs before connecting]

## Authentication
[Step-by-step auth flow]

## Setup Steps
[How to connect in CloudSync Ultra]

## Troubleshooting
[Common errors and solutions]

## Edge Cases
[Known limitations, quirks]

## References
[Links to rclone docs, provider docs]
```

### 2. Test Results (REQUIRED)
**File:** Include in completion report

| Test | Status | Notes |
|------|--------|-------|
| Auth flow | | |
| List files | | |
| Upload file | | |
| Download file | | |
| Delete file | | |
| Error handling | | |

### 3. Code Changes (IF NEEDED)
Only if the provider requires special handling in CloudSync Ultra.

---

## Test Account Requirements

- [ ] Account type: [Free tier / Paid / Enterprise trial]
- [ ] Credentials needed: [API key / OAuth / Username+Password]
- [ ] Test data: [Empty bucket / Sample files]

**Note:** If no test account available, document this and research using rclone docs + community resources.

---

## Research Process

### Step 1: rclone Documentation Review
```bash
# Read rclone docs for this provider
open https://rclone.org/[backend]/
```

### Step 2: Manual rclone Test (if account available)
```bash
# Test auth flow manually
rclone config

# Test operations
rclone lsd remote:
rclone copy testfile.txt remote:
rclone ls remote:
```

### Step 3: Document Findings
- Create guide in `docs/providers/`
- Note any CloudSync-specific requirements
- Identify error messages that need mapping

### Step 4: Verify with Checklist
```bash
./scripts/check-provider.sh [provider-name]
```

---

## Acceptance Criteria

All must be true to mark complete:

- [ ] Provider guide created at `docs/providers/[PROVIDER]_GUIDE.md`
- [ ] Guide includes all required sections
- [ ] Auth flow documented with steps
- [ ] Edge cases identified
- [ ] Troubleshooting section has common errors
- [ ] Test results documented (or "No test account" noted)
- [ ] GitHub issue updated with summary

---

## Definition of Done (Research)

Copy this to your completion report:

```markdown
## Definition of Done - Research Task
- [ ] Guide file exists: docs/providers/[PROVIDER]_GUIDE.md
- [ ] Required sections present (Overview, Auth, Setup, Troubleshooting)
- [ ] Edge cases documented
- [ ] Test results included (or noted as untested)
- [ ] GitHub issue closed with summary comment
```

---

## Completion Report Template

```markdown
# [Worker] Research Completion Report

**Task:** [Integration Study] - [Provider Name] (#XXX)
**Status:** COMPLETE
**Date:** YYYY-MM-DD

## Research Summary
[2-3 sentence summary of findings]

## Deliverables Created
| File | Purpose |
|------|---------|
| `docs/providers/[PROVIDER]_GUIDE.md` | User-facing guide |

## Key Findings

### Authentication
[Summary of auth flow]

### Edge Cases Discovered
1. [Edge case 1]
2. [Edge case 2]

### CloudSync Integration Notes
- [Any special handling needed]
- [UI considerations]

## Test Results
| Test | Status | Notes |
|------|--------|-------|
| Auth | [Pass/Fail/Untested] | |
| List | [Pass/Fail/Untested] | |
| Upload | [Pass/Fail/Untested] | |
| Download | [Pass/Fail/Untested] | |
| Delete | [Pass/Fail/Untested] | |

## Recommendations
- [Any follow-up work needed]
- [Code changes required]

## Definition of Done
- [x] Guide file created
- [x] All required sections present
- [x] Edge cases documented
- [x] Test results included
- [x] Issue closed
```

---

## If Blocked

1. **No test account available:**
   - Document based on rclone docs and community resources
   - Mark test results as "Untested - no account"
   - This is acceptable for low-priority providers

2. **Provider requires special code changes:**
   - Document what changes are needed
   - Create follow-up ticket for implementation
   - Complete research portion

3. **Unclear requirements:**
   - Check existing guides for similar providers
   - Ask Strategic Partner for clarification

---

*Template Version: 1.0*
*Created: 2026-01-17*
