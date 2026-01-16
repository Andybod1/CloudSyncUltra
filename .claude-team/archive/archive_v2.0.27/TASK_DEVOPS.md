# TASK: App Store Screenshots & Metadata (#78)

## Ticket
**GitHub:** #78
**Type:** Operations / App Store Submission
**Size:** M (1-2 hours)
**Priority:** High (required for submission)

---

## Objective

Prepare all App Store submission assets including screenshots, metadata, keywords, and categories.

---

## Deliverables

### 1. Screenshots

**Required Sizes (macOS):**
- 1280 x 800 pixels (minimum)
- 2560 x 1600 pixels (recommended for Retina)
- Up to 10 screenshots

**Screens to Capture:**
1. Main window with sidebar and file browser
2. Transfer in progress with progress bars
3. Settings view showing providers
4. Add Remote wizard
5. Encryption settings
6. Menu bar integration
7. Quick Actions menu (Cmd+Shift+N)

**Screenshot Guidelines:**
- Use sample/demo data (no personal info)
- Clean, professional appearance
- Highlight key features
- Consider adding callouts/annotations

### 2. App Metadata

| Field | Content |
|-------|---------|
| App Name | CloudSync Ultra |
| Subtitle | Multi-Cloud File Sync |
| Category | Utilities |
| Secondary | Productivity |

### 3. Description

Write compelling App Store description:
- Lead with key benefit
- List major features
- Mention 42+ providers
- Include encryption/security
- Call to action

**Structure:**
```
[Hook - 1 sentence]

[Key benefits - bullet points]

[Feature highlights]

[Trust/security message]

[Call to action]
```

### 4. Keywords

Research and select 100 characters of keywords:
- cloud sync
- file backup
- dropbox
- google drive
- s3
- encryption
- multi-cloud
- file transfer

### 5. Support Information

| Field | Value |
|-------|-------|
| Support URL | [TBD - needs landing page] |
| Marketing URL | [TBD] |
| Privacy Policy URL | [From Legal-Advisor] |

### 6. Age Rating

Complete age rating questionnaire:
- No objectionable content
- No user-generated content
- No location data shared
- Rating: 4+ (all ages)

---

## Output Directory

Create: `docs/APP_STORE_SUBMISSION/`

```
docs/APP_STORE_SUBMISSION/
├── screenshots/
│   ├── 01-main-window.png
│   ├── 02-transfer-progress.png
│   ├── 03-settings.png
│   ├── 04-add-remote.png
│   ├── 05-encryption.png
│   ├── 06-menu-bar.png
│   └── 07-quick-actions.png
├── DESCRIPTION.md
├── KEYWORDS.txt
├── METADATA.md
└── CHECKLIST.md
```

---

## Screenshot Capture Process

1. Build and launch latest app
2. Configure with demo remotes
3. Set up sample data
4. Capture each screen
5. Resize to required dimensions
6. Review for quality

**Tools:**
- macOS Screenshot (Cmd+Shift+4)
- Preview for resizing
- Optional: Add annotations

---

## Acceptance Criteria

- [ ] All required screenshots captured
- [ ] Screenshots at correct resolution
- [ ] App description written
- [ ] Keywords selected (100 char max)
- [ ] Categories chosen
- [ ] Age rating completed
- [ ] All files in `docs/APP_STORE_SUBMISSION/`
- [ ] Checklist document created

---

## Reference

- Existing docs: `docs/APP_STORE_CHECKLIST.md`
- App Store guidelines: https://developer.apple.com/app-store/review/guidelines/
- Screenshot specs: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications

---

## Notes

- Use /think for keyword research
- Coordinate with Marketing-Lead for messaging consistency
- Screenshots should match landing page style

---

*Task created: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready"*
