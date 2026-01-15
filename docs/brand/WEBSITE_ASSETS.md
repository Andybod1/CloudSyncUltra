# CloudSync Ultra Website Assets Guide

**Version:** 1.0
**Last Updated:** January 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Hero Section Assets](#hero-section-assets)
3. [Provider Cloud Graphic](#provider-cloud-graphic)
4. [Animation Specifications](#animation-specifications)
5. [Feature Icons](#feature-icons)
6. [Screenshot Frames](#screenshot-frames)
7. [Responsive Breakpoints](#responsive-breakpoints)
8. [Performance Guidelines](#performance-guidelines)
9. [Asset Checklist](#asset-checklist)

---

## Overview

This guide defines specifications for website assets used on the CloudSync Ultra marketing site and landing pages.

### Design Principles

1. **Performance First** - Optimized file sizes, lazy loading
2. **Responsive** - Assets work across all breakpoints
3. **Accessible** - Alt text, reduced motion support
4. **Consistent** - Unified visual language with app

### Asset Categories

| Category | Purpose |
|----------|---------|
| Hero | Primary visual impact |
| Provider Cloud | Feature visualization |
| Animations | Dynamic engagement |
| Icons | Feature communication |
| Screenshots | Product showcase |

---

## Hero Section Assets

### Hero Banner

The primary visual element on the homepage.

| Attribute | Value |
|-----------|-------|
| **Base Dimensions** | 1440 x 900 px |
| **Aspect Ratio** | 16:10 (1.6:1) |
| **File Format** | WebP (primary), PNG (fallback) |
| **Max File Size** | 500 KB (WebP), 1.5 MB (PNG) |

#### Responsive Sizes

| Breakpoint | Dimensions | Notes |
|------------|------------|-------|
| Mobile | 640 x 400 px | Cropped/recomposed |
| Tablet | 1024 x 640 px | Medium density |
| Desktop | 1440 x 900 px | Standard |
| Large Desktop | 1920 x 1200 px | High resolution |
| Retina | 2880 x 1800 px | @2x desktop |

#### Content Layout

```
+------------------------------------------------+
|                                                |
|          CloudSync Ultra                       |
|          ─────────────────                     |
|          One app. Every cloud.                 |
|          Complete control.                     |
|                                                |
|       [Download Now]  [Learn More]             |
|                                                |
|          [App Screenshot/Mockup]               |
|                                                |
+------------------------------------------------+
```

#### Design Guidelines

- **Safe Zone:** Keep critical content within center 1200px
- **Visual Focus:** App mockup or abstract cloud visualization
- **Color:** Brand gradient background or dark theme
- **Motion:** Optional subtle animation (see Animation section)

### Hero Background Options

**Option A: Gradient Background**
```css
background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
```

**Option B: Dark with Accent**
```css
background: linear-gradient(180deg, #1A1A2E 0%, #16213E 50%, #0F3460 100%);
```

**Option C: Image with Overlay**
```css
background-image: url('hero-bg.webp');
background-color: rgba(26, 26, 46, 0.9);
background-blend-mode: overlay;
```

---

## Provider Cloud Graphic

Visual representation of CloudSync Ultra's 42+ supported providers.

### Specifications

| Attribute | Value |
|-----------|-------|
| **Dimensions** | 800 x 600 px |
| **Aspect Ratio** | 4:3 |
| **File Format** | SVG (preferred), PNG |
| **Provider Icons** | 42+ logos arranged |

### Layout Concept

```
            ☁️ ☁️ ☁️
          ☁️       ☁️
        ☁️    ⬆️     ☁️
       ☁️   [ICON]    ☁️
        ☁️    ⬇️     ☁️
          ☁️       ☁️
            ☁️ ☁️ ☁️

Provider icons arranged in cloud formation
CloudSync icon at center with sync arrows
```

### Provider Icon Requirements

| Provider Category | Icons to Include |
|-------------------|------------------|
| Major Cloud | Google Drive, Dropbox, OneDrive, iCloud, Box |
| Object Storage | S3, Backblaze B2, Wasabi, Cloudflare R2 |
| Enterprise | Azure, GCS, SharePoint |
| Self-Hosted | Nextcloud, ownCloud, Seafile |
| Specialty | MEGA, pCloud, Proton Drive |

### Icon Specifications

| Attribute | Value |
|-----------|-------|
| **Individual Icon Size** | 32 x 32 px (in composition) |
| **Icon Style** | Simplified, monochrome or brand color |
| **Arrangement** | Orbital/cloud formation |
| **Center Element** | CloudSync Ultra icon (64 x 64 px) |

### Animation Variant

An animated version showing icons floating/orbiting:
- Format: Lottie JSON or CSS animation
- Duration: 10-15 second loop
- Motion: Subtle floating, gentle orbit
- Respect: prefers-reduced-motion

---

## Animation Specifications

### Sync Animation

Primary animation showing the sync concept.

| Attribute | Value |
|-----------|-------|
| **Dimensions** | 400 x 400 px |
| **Duration** | 3 seconds (loop) |
| **Format** | Lottie JSON (primary), GIF (fallback) |
| **File Size** | < 100 KB (Lottie), < 500 KB (GIF) |
| **Frame Rate** | 60 fps (Lottie), 30 fps (GIF) |

#### Animation Concept

```
Frame 1-30:    Cloud icon appears
Frame 31-60:   Sync arrows activate (rotate)
Frame 61-90:   Files transfer visualization
Frame 91-120:  Success checkmark
Frame 121-180: Hold, then loop
```

#### Animation Guidelines

- **Easing:** Use ease-in-out for smooth motion
- **Colors:** Brand gradient with white accents
- **Style:** Flat design, consistent with app UI
- **Loop:** Seamless, no jarring transitions

### Micro-animations

Small animations for UI elements:

| Element | Duration | Trigger |
|---------|----------|---------|
| Button hover | 200ms | Hover |
| Card hover | 300ms | Hover |
| Icon pulse | 1.5s | Continuous |
| Progress bar | Variable | Data-driven |

### Reduced Motion

Always provide static alternatives:

```css
@media (prefers-reduced-motion: reduce) {
  .sync-animation {
    animation: none;
  }
  .sync-animation::after {
    content: url('sync-static.svg');
  }
}
```

---

## Feature Icons

Icons representing key product features.

### Specifications

| Attribute | Value |
|-----------|-------|
| **Size** | 48 x 48 px (base) |
| **Sizes Needed** | 24, 32, 48, 64, 96 px |
| **Format** | SVG (primary), PNG (fallback) |
| **Style** | Outline, 2px stroke weight |
| **Color** | Single color (inherits from context) |

### Icon Set

| Icon Name | SF Symbol Reference | Purpose |
|-----------|---------------------|---------|
| cloud-sync | arrow.triangle.2.circlepath.circle | Core sync feature |
| multi-provider | cloud.fill with badge | 42+ providers |
| encryption | lock.shield | Security feature |
| speed | gauge.high | Performance |
| bandwidth | arrow.up.arrow.down | Transfer control |
| schedule | clock.fill | Scheduled sync |
| local-first | internaldrive | Local storage |
| enterprise | building.2 | Business features |
| selective-sync | checklist | Choose what syncs |
| conflict-resolution | exclamationmark.triangle | Handles conflicts |

### Icon Design Guidelines

- **Grid:** 48 x 48 px with 4px padding
- **Stroke:** 2px, rounded caps and joins
- **Fill:** Outline style preferred, fill for emphasis
- **Optical Alignment:** Icons should appear same visual weight

### Icon Colors in Context

| Context | Color |
|---------|-------|
| Default | Secondary text (#8E8E93) |
| Hover | Primary brand (#6366F1) |
| Active | Brand gradient |
| Success | Green (#34C759) |
| Warning | Orange (#FF9500) |
| Error | Red (#FF3B30) |

---

## Screenshot Frames

Device mockups showcasing the app.

### macOS App Screenshots

| Attribute | Value |
|-----------|-------|
| **Screenshot Size** | 2880 x 1800 px (@2x) |
| **Display Size** | 1440 x 900 px (standard) |
| **Format** | PNG with transparency |
| **Window Chrome** | Include macOS title bar |

#### Screenshot Variants

| Screen | Focus | Key Elements |
|--------|-------|--------------|
| Dashboard | Overview | Stats, recent activity, provider list |
| Tasks | Sync tasks | Task list, progress, status |
| File Browser | Navigation | File tree, preview, actions |
| Settings | Configuration | Provider settings, preferences |
| Onboarding | First run | Welcome, setup flow |

### Device Mockup Frames

#### MacBook Pro Frame

| Attribute | Value |
|-----------|-------|
| **Frame Dimensions** | 3200 x 2000 px |
| **Screen Area** | 2880 x 1800 px |
| **Safe Area** | Center of screen |
| **Format** | PNG with transparency |

#### MacBook Air Frame

| Attribute | Value |
|-----------|-------|
| **Frame Dimensions** | 2800 x 1800 px |
| **Screen Area** | 2560 x 1600 px |
| **Format** | PNG with transparency |

### Screenshot Guidelines

1. **Content:** Use realistic but anonymized data
2. **Theme:** Default light mode (dark mode variant available)
3. **Resolution:** Always export @2x minimum
4. **Composition:** Feature being highlighted should be visible
5. **Annotations:** Optional callouts in separate layer

### App Store Screenshots

See [APP_STORE_CHECKLIST.md](../APP_STORE_CHECKLIST.md) for App Store-specific requirements.

| Size | Purpose |
|------|---------|
| 2880 x 1800 px | Mac App Store (Retina) |
| 1440 x 900 px | Mac App Store (Standard) |

---

## Responsive Breakpoints

### Standard Breakpoints

| Name | Width | Target |
|------|-------|--------|
| Mobile | 320-639 px | Phones |
| Tablet | 640-1023 px | Tablets, small laptops |
| Desktop | 1024-1439 px | Standard laptops |
| Large | 1440-1919 px | Large monitors |
| XL | 1920+ px | High-res displays |

### Asset Delivery

```html
<picture>
  <source
    media="(min-width: 1440px)"
    srcset="hero-large.webp 1920w, hero-xl.webp 2880w"
    type="image/webp">
  <source
    media="(min-width: 1024px)"
    srcset="hero-desktop.webp 1440w"
    type="image/webp">
  <source
    media="(min-width: 640px)"
    srcset="hero-tablet.webp 1024w"
    type="image/webp">
  <img
    src="hero-mobile.png"
    srcset="hero-mobile.webp 640w"
    alt="CloudSync Ultra dashboard"
    loading="lazy">
</picture>
```

### CSS Variables

```css
:root {
  /* Breakpoints */
  --breakpoint-mobile: 320px;
  --breakpoint-tablet: 640px;
  --breakpoint-desktop: 1024px;
  --breakpoint-large: 1440px;
  --breakpoint-xl: 1920px;

  /* Container widths */
  --container-mobile: 100%;
  --container-tablet: 600px;
  --container-desktop: 960px;
  --container-large: 1200px;
  --container-xl: 1400px;
}
```

---

## Performance Guidelines

### Image Optimization

| Format | Use Case | Compression |
|--------|----------|-------------|
| WebP | Photos, complex graphics | 80-85% quality |
| PNG | Logos, icons, transparency | Lossless, optimized |
| SVG | Icons, illustrations | Minified (SVGO) |
| AVIF | Modern browsers, photos | 70-80% quality |

### File Size Targets

| Asset Type | Max Size |
|------------|----------|
| Hero image | 500 KB |
| Feature image | 200 KB |
| Icon (SVG) | 5 KB |
| Icon (PNG) | 10 KB |
| Lottie animation | 100 KB |
| GIF fallback | 500 KB |

### Loading Strategy

| Priority | Assets | Strategy |
|----------|--------|----------|
| Critical | Above-fold hero, logo | Preload, inline |
| High | Primary CTAs, nav icons | Early load |
| Medium | Feature images, icons | Lazy load |
| Low | Below-fold, animations | Lazy load, defer |

### Preload Example

```html
<link rel="preload" href="/images/hero.webp" as="image" type="image/webp">
<link rel="preload" href="/fonts/sf-pro.woff2" as="font" type="font/woff2" crossorigin>
```

---

## Asset Checklist

### Website Asset Package

```
CloudSyncUltra-Website-Assets/
├── hero/
│   ├── hero-mobile.webp        (640x400)
│   ├── hero-tablet.webp        (1024x640)
│   ├── hero-desktop.webp       (1440x900)
│   ├── hero-large.webp         (1920x1200)
│   ├── hero-xl.webp            (2880x1800)
│   └── hero-fallback.png
├── provider-cloud/
│   ├── provider-cloud.svg
│   ├── provider-cloud-animated.json (Lottie)
│   └── provider-cloud-static.png
├── animations/
│   ├── sync-animation.json     (Lottie)
│   ├── sync-animation.gif      (fallback)
│   └── sync-static.svg         (reduced motion)
├── icons/
│   ├── feature-icons.svg       (sprite)
│   ├── cloud-sync-24.svg
│   ├── cloud-sync-48.svg
│   ├── multi-provider-24.svg
│   ├── multi-provider-48.svg
│   └── [all icons at 24, 32, 48, 64, 96]
├── screenshots/
│   ├── dashboard-2880x1800.png
│   ├── tasks-2880x1800.png
│   ├── file-browser-2880x1800.png
│   ├── settings-2880x1800.png
│   └── onboarding-2880x1800.png
├── mockups/
│   ├── macbook-pro-frame.png
│   ├── macbook-air-frame.png
│   └── composed/
│       ├── dashboard-macbook.png
│       └── tasks-macbook.png
└── backgrounds/
    ├── gradient-bg.svg
    ├── dark-bg.svg
    └── pattern-bg.svg
```

### Export Checklist

Before deploying assets:

- [ ] All sizes exported for responsive delivery
- [ ] WebP versions created with PNG fallbacks
- [ ] SVGs optimized with SVGO
- [ ] PNGs compressed (TinyPNG or similar)
- [ ] Lottie animations tested in browser
- [ ] Alt text documented for all images
- [ ] Dark mode variants created if needed
- [ ] Reduced motion alternatives ready
- [ ] File sizes within targets
- [ ] Color profiles set to sRGB

---

*CloudSync Ultra Website Assets Guide v1.0*
*For questions or asset requests, contact the brand team.*
