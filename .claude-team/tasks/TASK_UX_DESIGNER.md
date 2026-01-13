# TASK: Full UX Review (#44)

## Agent: UX-Designer
## Model: Opus (always)

**Use extended thinking (`/think`) for thorough analysis.**

---

## Objective

Conduct a comprehensive UX review of CloudSync Ultra and provide actionable recommendations.

---

## Analysis Areas

### 1. First-Time User Experience
- App launch → first sync completion
- Onboarding clarity
- Time to value

### 2. Core User Flows
- Adding a cloud provider (OAuth, credentials)
- Browsing files
- Transferring files (upload/download)
- Setting up scheduled sync
- Configuring encryption

### 3. Visual Design
- Consistency across views
- Visual hierarchy
- Use of color and iconography
- Information density

### 4. Interaction Design
- Button placement and sizing
- Feedback (progress, success, errors)
- Keyboard navigation
- Drag and drop

### 5. Error Handling UX
- Error message clarity
- Recovery paths
- Help/documentation access

### 6. Competitive Comparison
Compare to native apps:
- Dropbox desktop app
- Google Drive app
- OneDrive app

---

## Files to Review

```bash
# List all views
ls -la CloudSyncApp/Views/

# Key files
CloudSyncApp/Views/MainWindow.swift
CloudSyncApp/Views/SettingsView.swift
CloudSyncApp/Views/TransferView.swift
CloudSyncApp/Views/FileBrowserView.swift
```

---

## Deliverables

1. **UX Audit Report** with:
   - Current state assessment (score 1-10)
   - User flow diagrams (text-based)
   - Pain points list (prioritized)
   - Recommendations (quick wins + major improvements)
   - Competitive comparison table

2. **GitHub Issues** for top 5 UX improvements

---

## Output

Write to: `/Users/antti/Claude/.claude-team/outputs/UX_DESIGNER_COMPLETE.md`

Update STATUS.md when starting/completing.

---

## Acceptance Criteria

- [ ] All 5 analysis areas covered
- [ ] Pain points identified and prioritized
- [ ] At least 10 actionable recommendations
- [ ] GitHub issues created for top findings
