# CloudSync Ultra Logo Specifications

**Version:** 1.0
**Last Updated:** January 2026

---

## Table of Contents

1. [Logo Suite Overview](#logo-suite-overview)
2. [Primary Logo (Horizontal)](#primary-logo-horizontal)
3. [Secondary Logo (Stacked)](#secondary-logo-stacked)
4. [Icon Only](#icon-only)
5. [Clear Space Requirements](#clear-space-requirements)
6. [Minimum Size Requirements](#minimum-size-requirements)
7. [Color Variations](#color-variations)
8. [Usage Guidelines](#usage-guidelines)
9. [File Formats](#file-formats)

---

## Logo Suite Overview

The CloudSync Ultra logo system consists of three primary configurations, each designed for specific use cases.

| Logo Type | Dimensions | Primary Use |
|-----------|------------|-------------|
| Primary (Horizontal) | 240x60px | Website headers, documents |
| Secondary (Stacked) | 120x120px | Social profiles, square spaces |
| Icon Only | 64x64px (base) | App icons, favicons |

### Logo Elements

1. **Icon** - Stylized cloud with sync arrows, representing seamless multi-cloud synchronization
2. **Wordmark** - "CloudSync Ultra" in SF Pro Bold

---

## Primary Logo (Horizontal)

The primary horizontal logo is the default choice for most applications.

### Specifications

| Attribute | Value |
|-----------|-------|
| **Dimensions** | 240 x 60 px (base) |
| **Aspect Ratio** | 4:1 |
| **Icon Size** | 48 x 48 px |
| **Icon Position** | Left-aligned, vertically centered |
| **Wordmark** | SF Pro Bold, 28pt |
| **Spacing** | 12px between icon and wordmark |

### Scalable Sizes

| Size Name | Dimensions | Use Case |
|-----------|------------|----------|
| Small | 120 x 30 px | Mobile headers, compact spaces |
| Standard | 240 x 60 px | Website headers, documents |
| Large | 480 x 120 px | Hero sections, presentations |
| Print | 720 x 180 px | High-resolution print materials |

### Layout Grid

```
+--------------------------------------------------+
|  [ICON]  12px  [C l o u d S y n c   U l t r a]   |
|    48px         SF Pro Bold 28pt                  |
+--------------------------------------------------+
        ^                                     ^
      12px                                  12px
     padding                              padding
```

---

## Secondary Logo (Stacked)

The stacked logo is used when horizontal space is limited or square formats are required.

### Specifications

| Attribute | Value |
|-----------|-------|
| **Dimensions** | 120 x 120 px (base) |
| **Aspect Ratio** | 1:1 |
| **Icon Size** | 64 x 64 px |
| **Icon Position** | Top, horizontally centered |
| **Wordmark** | Two lines, centered |
| **Line 1** | "CloudSync" - SF Pro Bold, 14pt |
| **Line 2** | "Ultra" - SF Pro Medium, 12pt |
| **Spacing** | 8px between icon and text |

### Scalable Sizes

| Size Name | Dimensions | Use Case |
|-----------|------------|----------|
| Small | 80 x 80 px | Tight spaces |
| Standard | 120 x 120 px | Social avatars, cards |
| Large | 200 x 200 px | Feature highlights |

### Layout Grid

```
+------------------+
|                  |
|      [ICON]      |
|      64x64       |
|        8px       |
|    CloudSync     |
|      Ultra       |
|                  |
+------------------+
```

---

## Icon Only

The icon is used independently for app icons, favicons, and small-scale applications.

### App Icon Specifications

| Attribute | Value |
|-----------|-------|
| **Base Size** | 64 x 64 px |
| **Shape** | Cloud with integrated sync arrows |
| **Style** | Filled with gradient |
| **Corners** | Follows macOS icon corner radius |

### Icon Size Matrix

| Size (px) | Use Case |
|-----------|----------|
| 16 x 16 | Favicon (legacy), small UI elements |
| 32 x 32 | Favicon (standard), toolbar icons |
| 64 x 64 | Base icon, small displays |
| 128 x 128 | macOS Dock (low-res) |
| 256 x 256 | macOS Dock (standard) |
| 512 x 512 | macOS App Icon (Retina) |
| 1024 x 1024 | App Store, marketing materials |

### macOS App Icon Requirements

```
AppIcon.appiconset/
├── icon_16x16.png
├── icon_16x16@2x.png      (32x32)
├── icon_32x32.png
├── icon_32x32@2x.png      (64x64)
├── icon_128x128.png
├── icon_128x128@2x.png    (256x256)
├── icon_256x256.png
├── icon_256x256@2x.png    (512x512)
├── icon_512x512.png
├── icon_512x512@2x.png    (1024x1024)
└── Contents.json
```

### Favicon Package

```
favicon/
├── favicon.ico            (16, 32, 48 multi-size)
├── favicon-16x16.png
├── favicon-32x32.png
├── apple-touch-icon.png   (180x180)
├── android-chrome-192x192.png
├── android-chrome-512x512.png
└── site.webmanifest
```

---

## Clear Space Requirements

Clear space ensures the logo remains visually distinct and uncluttered.

### Primary Logo (Horizontal)

- **Minimum Clear Space:** Height of the icon (1x) on all sides
- At 240x60px, clear space = 48px

```
        48px clear space
    +-----------------------+
    |                       |
48px|   [LOGO HORIZONTAL]   |48px
    |                       |
    +-----------------------+
        48px clear space
```

### Secondary Logo (Stacked)

- **Minimum Clear Space:** 0.5x icon height on all sides
- At 120x120px base, clear space = 32px

### Icon Only

- **Minimum Clear Space:** 0.25x icon size on all sides
- At 64x64px, clear space = 16px

---

## Minimum Size Requirements

Below these sizes, legibility and brand recognition are compromised.

| Logo Type | Minimum Size | Notes |
|-----------|--------------|-------|
| Primary (Horizontal) | 120 x 30 px | Wordmark barely legible |
| Secondary (Stacked) | 80 x 80 px | Wordmark very small |
| Icon Only | 16 x 16 px | Detail loss expected |
| Icon (Print) | 0.5 inch / 12mm | 300 DPI minimum |

### Digital Minimum Guidelines

- **Icon without wordmark:** 16px minimum
- **Icon with wordmark:** 80px minimum height
- **Hero/feature display:** 256px minimum for impact

---

## Color Variations

### Full Color (Primary)

The default logo uses the CloudSync gradient:

| Element | Color |
|---------|-------|
| Icon Fill | Gradient (#6366F1 to #8B5CF6) |
| Wordmark | #1A1A2E (dark backgrounds) or #000000 (light backgrounds) |

### Monochrome Variations

#### Dark Monochrome
- **Use:** Light backgrounds, documents
- **Color:** #1A1A2E or #000000

#### Light Monochrome
- **Use:** Dark backgrounds, overlays
- **Color:** #FFFFFF

#### Gray Monochrome
- **Use:** Disabled states, low-emphasis
- **Color:** #8E8E93 (System Gray)

### Reversed (Knockout)

For use on dark or colored backgrounds:

| Background | Logo Color |
|------------|------------|
| Dark (#1A1A2E) | White (#FFFFFF) |
| Gradient | White (#FFFFFF) |
| Photo/Image | White (#FFFFFF) with subtle shadow |

### Color Usage Matrix

| Background Type | Recommended Logo |
|-----------------|------------------|
| White / Light | Full Color or Dark Mono |
| Light Gray | Full Color or Dark Mono |
| Dark | Reversed (White) |
| Brand Gradient | Reversed (White) |
| Photography | Reversed (White) + shadow |
| Colored | Test for contrast; use mono if needed |

---

## Usage Guidelines

### Do's

- Use provided logo files without modification
- Maintain proper clear space
- Ensure adequate contrast with background
- Scale proportionally
- Use appropriate color variation for context

### Don'ts

| Violation | Description |
|-----------|-------------|
| **No Stretching** | Never distort the aspect ratio |
| **No Rotation** | Keep the logo horizontal |
| **No Color Changes** | Use only approved color variations |
| **No Effects** | No shadows, glows, or filters |
| **No Cropping** | Show the complete logo |
| **No Busy Backgrounds** | Ensure readability |
| **No Outline** | Don't add strokes or borders |
| **No Rearranging** | Don't separate icon from wordmark |

### Placement Guidelines

#### Website Headers
- Left-aligned, vertically centered
- Minimum 16px padding from edges
- Links to homepage

#### App Interface
- Top-left for macOS conventions
- Consistent sizing across screens

#### Documents
- Top-left or centered in header
- Adequate margin from text

#### Social Media
- Centered in profile image areas
- Account for circular cropping

---

## File Formats

### Vector Formats (Preferred)

| Format | Use Case | Notes |
|--------|----------|-------|
| SVG | Web, responsive | Scalable, editable |
| PDF | Print, presentations | Vector quality |
| AI | Adobe workflows | Master source |
| EPS | Legacy print | Older systems |

### Raster Formats

| Format | Use Case | Notes |
|--------|----------|-------|
| PNG | Web, app | Transparent background |
| PNG @2x | Retina displays | 2x resolution |
| PNG @3x | High-DPI displays | 3x resolution |
| JPG | Photos, presentations | No transparency |
| WebP | Modern web | Smaller file size |
| ICNS | macOS app icon | Multi-resolution |
| ICO | Windows/favicon | Multi-resolution |

### Recommended Export Settings

#### PNG for Web
- Color space: sRGB
- Bit depth: 24-bit + alpha
- Resolution: 72 PPI (with @2x variants)

#### PNG for Print
- Color space: sRGB or Adobe RGB
- Resolution: 300 PPI minimum

#### SVG
- Optimized (SVGO)
- Inline styles preferred
- Viewbox defined

---

## Asset Checklist

### Logo Package Contents

```
CloudSyncUltra-Logo-Package/
├── Primary-Horizontal/
│   ├── cloudsync-logo-horizontal-color.svg
│   ├── cloudsync-logo-horizontal-color.png
│   ├── cloudsync-logo-horizontal-color@2x.png
│   ├── cloudsync-logo-horizontal-dark.svg
│   ├── cloudsync-logo-horizontal-dark.png
│   ├── cloudsync-logo-horizontal-white.svg
│   └── cloudsync-logo-horizontal-white.png
├── Secondary-Stacked/
│   ├── cloudsync-logo-stacked-color.svg
│   ├── cloudsync-logo-stacked-color.png
│   ├── cloudsync-logo-stacked-dark.svg
│   └── cloudsync-logo-stacked-white.svg
├── Icon-Only/
│   ├── cloudsync-icon-color.svg
│   ├── cloudsync-icon-color-[SIZE].png (all sizes)
│   ├── cloudsync-icon-dark.svg
│   ├── cloudsync-icon-white.svg
│   └── AppIcon.appiconset/
├── Favicon/
│   ├── favicon.ico
│   ├── favicon-16x16.png
│   ├── favicon-32x32.png
│   └── apple-touch-icon.png
└── README.md
```

---

*CloudSync Ultra Logo Specifications v1.0*
*For questions, contact the brand team.*
