# TASK: Product Strategy & Business Logic (#45)

## Agent: Product-Manager
## Model: Opus (always)

**Use extended thinking (`/think`) for strategic analysis.**

---

## Objective

Define CloudSync Ultra's product strategy, user needs, and feature roadmap.

---

## Analysis Areas

### 1. Product Vision
- What should CloudSync Ultra become?
- Key differentiators vs competition
- Target market positioning

### 2. User Personas
Define 3-4 key user types:
- Who are they?
- What are their goals?
- What are their pain points?
- How does CloudSync help them?

### 3. Core User Journeys
Map the critical paths:
- New user → first successful sync
- Power user → multi-cloud management
- Privacy-focused user → encrypted backup
- Team/business user → shared workflows

### 4. Feature Prioritization
Review backlog and categorize:
- **Must Have** - Core functionality gaps
- **Should Have** - Significant improvements
- **Could Have** - Nice to have
- **Won't Have** - Out of scope

### 5. Competitive Analysis
| Feature | CloudSync | Dropbox | Google Drive | OneDrive |
|---------|-----------|---------|--------------|----------|
| Multi-cloud | ? | ? | ? | ? |
| Encryption | ? | ? | ? | ? |
| etc... | | | | |

### 6. Success Metrics
Define KPIs:
- User acquisition
- Feature adoption
- User satisfaction
- Technical health

---

## Resources to Review

```bash
# Current features
cat CHANGELOG.md | head -100

# Open issues (backlog)
gh issue list --state open

# Closed issues (history)
gh issue list --state closed --limit 50

# Provider list
grep -A50 "enum CloudProviderType" CloudSyncApp/Models/CloudProvider.swift
```

---

## Deliverables

1. **Product Strategy Document** with:
   - Vision statement
   - User personas (detailed)
   - User journey maps
   - Feature prioritization matrix
   - Competitive analysis
   - 90-day roadmap suggestion

2. **GitHub Issues** for any new feature ideas identified

---

## Output

Write to: `/Users/antti/Claude/.claude-team/outputs/PRODUCT_MANAGER_COMPLETE.md`

Update STATUS.md when starting/completing.

---

## Acceptance Criteria

- [ ] Clear product vision defined
- [ ] 3-4 user personas documented
- [ ] Core user journeys mapped
- [ ] Backlog prioritized (MoSCoW)
- [ ] Roadmap suggestion provided
