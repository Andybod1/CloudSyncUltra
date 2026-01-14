# Design Task: Create App Icon Set

**Issue:** #77
**Sprint:** Next Sprint
**Priority:** CRITICAL (Blocking Release)
**Worker:** Brand Designer
**Model:** Opus + Extended Thinking

---

## Objective

Create a professional app icon set for CloudSync Ultra that works across all macOS contexts (Dock, Finder, Spotlight, App Store).

## Requirements

### Icon Sizes Needed

macOS requires these sizes in Assets.xcassets/AppIcon.appiconset/:

| Size | Scale | Filename | Context |
|------|-------|----------|---------|
| 16x16 | 1x | icon_16x16.png | Finder list |
| 16x16 | 2x | icon_16x16@2x.png | Retina Finder |
| 32x32 | 1x | icon_32x32.png | Finder |
| 32x32 | 2x | icon_32x32@2x.png | Retina Finder |
| 128x128 | 1x | icon_128x128.png | Finder preview |
| 128x128 | 2x | icon_128x128@2x.png | Retina preview |
| 256x256 | 1x | icon_256x256.png | Finder preview |
| 256x256 | 2x | icon_256x256@2x.png | Retina preview |
| 512x512 | 1x | icon_512x512.png | App Store |
| 512x512 | 2x | icon_512x512@2x.png | Retina App Store |

### Design Guidelines

**Brand Identity (from Brand_Identity_Report.pdf):**
- Primary colors: Blues/teals for cloud/sync theme
- Modern, clean aesthetic
- Professional but approachable

**macOS Icon Guidelines:**
- Use rounded square (squircle) shape
- 3D-like with subtle shadows/gradients
- Face forward, not tilted
- Simple, recognizable at small sizes
- Unique - stand out in Dock

**Concept Ideas:**
1. Cloud with sync arrows
2. Multiple clouds connected
3. Abstract cloud formation
4. "C" or "U" with cloud elements
5. Folder with cloud badge

## Tasks

### 1. Research Competitors

Look at icons for:
- Transmit (Panic)
- CloudMounter
- Mountain Duck
- Dropbox
- Google Drive

### 2. Create Concepts

Design 3-5 icon concepts at 512x512:
- Sketch/wireframe first
- Consider how it looks at 16x16
- Test on light and dark backgrounds

### 3. Select Best Design

Criteria:
- Recognizable at all sizes
- Distinct from competitors
- Reflects app purpose (multi-cloud sync)
- Works on light/dark backgrounds

### 4. Generate All Sizes

From master 1024x1024:
```bash
# Using sips (macOS built-in)
sips -z 16 16 master.png --out icon_16x16.png
sips -z 32 32 master.png --out icon_16x16@2x.png
# ... etc for all sizes
```

### 5. Update Contents.json

```json
{
  "images": [
    {
      "filename": "icon_16x16.png",
      "idiom": "mac",
      "scale": "1x",
      "size": "16x16"
    },
    // ... all sizes
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

### 6. Place in Project

```
CloudSyncApp/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
├── icon_16x16.png
├── icon_16x16@2x.png
├── icon_32x32.png
├── icon_32x32@2x.png
├── icon_128x128.png
├── icon_128x128@2x.png
├── icon_256x256.png
├── icon_256x256@2x.png
├── icon_512x512.png
└── icon_512x512@2x.png
```

## Tools

- Figma / Sketch / Affinity Designer
- SF Symbols (for inspiration)
- IconJar (icon management)
- makeappicon.com (size generation)

## Verification

1. Build app and check Dock icon
2. Check in Finder at different view sizes
3. Check in Spotlight
4. Preview in App Store Connect (if available)

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/APP_ICON_COMPLETE.md`

Deliver:
- All icon sizes in correct folder
- Updated Contents.json
- Icon design rationale
- Before/after screenshots

## Success Criteria

- [ ] All 10 icon sizes created
- [ ] Contents.json properly configured
- [ ] Icon visible in Dock after build
- [ ] Works on light and dark mode
- [ ] Distinct and professional look
- [ ] Build succeeds
