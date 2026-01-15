# TASK: Update Project-Ops-Kit for $1B Solo Founder Operations

## Ticket
**Type:** Operations / Template Enhancement  
**Size:** L (2-3 hours)  
**Priority:** High

---

## Objective

Make `templates/project-ops-kit/` a complete, battle-tested template that enables any developer to run billion-dollar-scale solo founder operations with Claude Code workers.

---

## Gap Analysis (What's Missing)

| Item | Live Project | Template | Status |
|------|--------------|----------|--------|
| Post-Sprint Checklist | ✅ In CLAUDE_PROJECT_KNOWLEDGE.md | ❌ Missing | **CRITICAL** |
| RECOVERY.md | ✅ Comprehensive | ❌ Missing | **CRITICAL** |
| Billion Dollar Framework | ✅ Created | ❌ Missing | **HIGH** |
| CI Code Coverage | ✅ Enabled | ❌ Generic | **HIGH** |
| Branch Protection Guide | ✅ Enabled | ❌ Not documented | **MEDIUM** |
| Ops Excellence Updated | ✅ Pillar 2 at 100% | ❌ Shows 60% | **MEDIUM** |

---

## Deliverables

### 1. Update CLAUDE_PROJECT_KNOWLEDGE.md Template

Add the **MANDATORY Post-Sprint Checklist** section (copy pattern from live project):

```markdown
### ⚠️ MANDATORY: Post-Sprint Documentation

> **🔒 PROTECTED SECTION** - Do NOT skip these steps

**🚀 AUTOMATED OPTION:** Run `./scripts/release.sh X.X.X`

**After EVERY sprint, complete ALL steps:**

#### 0. Check Project Health FIRST
#### 1. Verify Build & Tests
#### 2. Update Version (use scripts!)
#### 3. Update Documentation Files
#### 4. GitHub Housekeeping
#### 5. Clean Up Sprint Files
#### 6. Commit, Tag & Push
#### 7. Reflect on Operational Excellence
```

Make it a template with placeholders but include the FULL checklist structure.

---

### 2. Create RECOVERY.md Template

Create `templates/project-ops-kit/RECOVERY.md` with:

```markdown
# {PROJECT_NAME} - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash
> **Version:** {VERSION} | **Tests:** {TEST_COUNT} | **Last Updated:** {DATE}

## 🚀 Quick Recovery (3 Steps)
### Step 1: Check GitHub Issues
### Step 2: Check Git Status  
### Step 3: Verify Build

## 📋 Restore Strategic Partner Context
## 🔄 Resume Workers (If Mid-Task)
## 📊 Key Files to Read
## ⚡ Emergency Commands
```

---

### 3. Create BILLION_DOLLAR_FRAMEWORK.md Template

Create `templates/project-ops-kit/.claude-team/planning/BILLION_DOLLAR_FRAMEWORK.md`:

Generic version covering:
- Revenue math (ARR targets for different price points)
- Evolved 6 Pillars (Product Automation, Customer Quality, etc.)
- Solo Founder Leverage (AI support, self-serve, PLG)
- Phase roadmap template (Foundation → Growth → Scale → Platform)
- Key metrics (MRR, CAC, LTV, Churn, NRR)

Remove CloudSync-specific references, make it applicable to any SaaS.

---

### 4. Update CI Template with Coverage

Update `.github/workflows/ci.yml` to include:
- Code coverage collection pattern (commented examples for different stacks)
- Coverage threshold warning pattern
- Artifact upload for coverage reports
- PR summary for coverage

---

### 5. Update OPERATIONAL_EXCELLENCE.md

- Update Pillar 2 to show path to 100%
- Add CI coverage to Pillar 4
- Add branch protection setup instructions
- Include GitHub CLI commands for branch protection

---

### 6. Update README.md

Add sections for:
- Branch protection setup (with `gh api` commands)
- CI coverage setup
- Post-sprint checklist reference
- Recovery process overview

---

### 7. Add Setup Instructions

Update `scripts/setup.sh` to:
- Prompt for project name
- Replace all `{PROJECT_NAME}`, `{PROJECT_ROOT}` placeholders
- Initialize git if needed
- Offer to set up branch protection
- Create initial VERSION.txt

---

## Files to Create/Update

| Action | File |
|--------|------|
| UPDATE | `CLAUDE_PROJECT_KNOWLEDGE.md` - Add post-sprint checklist |
| CREATE | `RECOVERY.md` - Crash recovery template |
| CREATE | `.claude-team/planning/BILLION_DOLLAR_FRAMEWORK.md` |
| UPDATE | `.github/workflows/ci.yml` - Add coverage patterns |
| UPDATE | `OPERATIONAL_EXCELLENCE.md` - Update to reflect best practices |
| UPDATE | `README.md` - Add setup sections |
| UPDATE | `scripts/setup.sh` - Enhanced initialization |

---

## Success Criteria

- [ ] CLAUDE_PROJECT_KNOWLEDGE.md has full post-sprint checklist
- [ ] RECOVERY.md template created
- [ ] BILLION_DOLLAR_FRAMEWORK.md template created (generic)
- [ ] CI template includes coverage examples
- [ ] OPERATIONAL_EXCELLENCE.md updated
- [ ] README.md has comprehensive setup guide
- [ ] setup.sh handles all placeholder replacements
- [ ] All files use `{PROJECT_ROOT}`, `{PROJECT_NAME}` placeholders
- [ ] No CloudSync-specific references remain
- [ ] Git committed and pushed

---

## Reference Files (Copy Patterns From)

```
/Users/antti/Claude/CLAUDE_PROJECT_KNOWLEDGE.md  # Post-sprint checklist
/Users/antti/Claude/RECOVERY.md                   # Recovery guide
/Users/antti/Claude/.claude-team/planning/BILLION_DOLLAR_FRAMEWORK.md
/Users/antti/Claude/.github/workflows/ci.yml      # Coverage setup
/Users/antti/Claude/.claude-team/OPERATIONAL_EXCELLENCE.md
```

---

## Notes

- This template will help other solo founders replicate our operational excellence
- Quality matters - this is the foundation for scaling without employees
- Test the setup.sh script after changes
- Use /think for strategic decisions about what to include/exclude

---

*Task created: 2026-01-15*
*Use /think for thorough analysis*
