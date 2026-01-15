# CloudSync Ultra Color Reference

**Version:** 1.0
**Last Updated:** January 2026

Quick reference for all CloudSync Ultra brand colors with Swift, CSS, and design tool values.

---

## Primary Brand Colors

### CloudSync Indigo (Primary)

| Format | Value |
|--------|-------|
| **Hex** | `#6366F1` |
| **RGB** | `rgb(99, 102, 241)` |
| **HSL** | `hsl(239, 84%, 67%)` |
| **Swift** | `Color(hex: "6366F1")` |
| **SwiftUI** | `AppTheme.primaryIndigo` |
| **CSS Variable** | `--color-primary-indigo: #6366F1;` |
| **Tailwind** | `indigo-500` (closest) |

### CloudSync Purple (Secondary)

| Format | Value |
|--------|-------|
| **Hex** | `#8B5CF6` |
| **RGB** | `rgb(139, 92, 246)` |
| **HSL** | `hsl(258, 90%, 66%)` |
| **Swift** | `Color(hex: "8B5CF6")` |
| **SwiftUI** | `AppTheme.primaryPurple` |
| **CSS Variable** | `--color-primary-purple: #8B5CF6;` |
| **Tailwind** | `violet-500` (closest) |

### Primary Gradient

```swift
// Swift
AppTheme.primaryGradient
// or
LinearGradient(
    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

```css
/* CSS */
background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);

/* CSS Variable */
--gradient-primary: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
```

---

## Status Colors

### Success Green

| Format | Value |
|--------|-------|
| **Hex** | `#34C759` |
| **RGB** | `rgb(52, 199, 89)` |
| **HSL** | `hsl(135, 60%, 49%)` |
| **Swift** | `Color.green` |
| **SwiftUI** | `AppTheme.success` or `AppTheme.successColor` |
| **CSS Variable** | `--color-success: #34C759;` |
| **Tailwind** | `green-500` (closest) |

### Warning Orange

| Format | Value |
|--------|-------|
| **Hex** | `#FF9500` |
| **RGB** | `rgb(255, 149, 0)` |
| **HSL** | `hsl(35, 100%, 50%)` |
| **Swift** | `Color.orange` |
| **SwiftUI** | `AppTheme.warning` or `AppTheme.warningColor` |
| **CSS Variable** | `--color-warning: #FF9500;` |
| **Tailwind** | `orange-500` (closest) |

### Error Red

| Format | Value |
|--------|-------|
| **Hex** | `#FF3B30` |
| **RGB** | `rgb(255, 59, 48)` |
| **HSL** | `hsl(3, 100%, 59%)` |
| **Swift** | `Color.red` |
| **SwiftUI** | `AppTheme.error` or `AppTheme.errorColor` |
| **CSS Variable** | `--color-error: #FF3B30;` |
| **Tailwind** | `red-500` (closest) |

### Info Blue

| Format | Value |
|--------|-------|
| **Hex** | `#007AFF` |
| **RGB** | `rgb(0, 122, 255)` |
| **HSL** | `hsl(211, 100%, 50%)` |
| **Swift** | `Color.blue` |
| **SwiftUI** | `AppTheme.info` or `AppTheme.infoColor` |
| **CSS Variable** | `--color-info: #007AFF;` |
| **Tailwind** | `blue-500` (closest) |

### Encryption Purple

| Format | Value |
|--------|-------|
| **Hex** | `#AF52DE` |
| **RGB** | `rgb(175, 82, 222)` |
| **HSL** | `hsl(280, 68%, 60%)` |
| **Swift** | `Color.purple` |
| **SwiftUI** | `AppTheme.encryptionColor` |
| **CSS Variable** | `--color-encryption: #AF52DE;` |
| **Tailwind** | `purple-500` (closest) |

---

## Background Colors (Dark Theme)

### Background Dark 1 (Primary)

| Format | Value |
|--------|-------|
| **Hex** | `#1A1A2E` |
| **RGB** | `rgb(26, 26, 46)` |
| **HSL** | `hsl(240, 28%, 14%)` |
| **Swift** | `Color(hex: "1A1A2E")` |
| **SwiftUI** | `AppTheme.backgroundDark1` |
| **CSS Variable** | `--color-bg-dark-1: #1A1A2E;` |

### Background Dark 2 (Secondary)

| Format | Value |
|--------|-------|
| **Hex** | `#16213E` |
| **RGB** | `rgb(22, 33, 62)` |
| **HSL** | `hsl(224, 48%, 16%)` |
| **Swift** | `Color(hex: "16213E")` |
| **SwiftUI** | `AppTheme.backgroundDark2` |
| **CSS Variable** | `--color-bg-dark-2: #16213E;` |

### Background Dark 3 (Tertiary)

| Format | Value |
|--------|-------|
| **Hex** | `#0F3460` |
| **RGB** | `rgb(15, 52, 96)` |
| **HSL** | `hsl(213, 73%, 22%)` |
| **Swift** | `Color(hex: "0F3460")` |
| **SwiftUI** | `AppTheme.backgroundDark3` |
| **CSS Variable** | `--color-bg-dark-3: #0F3460;` |

### Dark Background Gradient

```swift
// Swift
AppTheme.backgroundGradient
// or
LinearGradient(
    colors: [
        Color(hex: "1A1A2E"),
        Color(hex: "16213E"),
        Color(hex: "0F3460")
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

```css
/* CSS */
background: linear-gradient(135deg, #1A1A2E 0%, #16213E 50%, #0F3460 100%);

/* CSS Variable */
--gradient-dark-bg: linear-gradient(135deg, #1A1A2E 0%, #16213E 50%, #0F3460 100%);
```

---

## System Colors (Light Theme)

These use native macOS system colors for light mode interfaces:

| Color | Swift | CSS Equivalent |
|-------|-------|----------------|
| Window Background | `Color(NSColor.windowBackgroundColor)` | `#ECECEC` approx |
| Control Background | `Color(NSColor.controlBackgroundColor)` | `#FFFFFF` approx |
| Section Background | `Color(NSColor.underPageBackgroundColor)` | `#F5F5F5` approx |
| Primary Text | `Color.primary` | System dependent |
| Secondary Text | `Color.secondary` | System dependent |
| Tertiary Text | `Color(NSColor.tertiaryLabelColor)` | System dependent |

---

## Complete CSS Variables

```css
:root {
  /* Primary Brand */
  --color-primary-indigo: #6366F1;
  --color-primary-purple: #8B5CF6;

  /* Status */
  --color-success: #34C759;
  --color-warning: #FF9500;
  --color-error: #FF3B30;
  --color-info: #007AFF;
  --color-encryption: #AF52DE;

  /* Dark Backgrounds */
  --color-bg-dark-1: #1A1A2E;
  --color-bg-dark-2: #16213E;
  --color-bg-dark-3: #0F3460;

  /* Gradients */
  --gradient-primary: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
  --gradient-primary-horizontal: linear-gradient(90deg, #6366F1 0%, #8B5CF6 100%);
  --gradient-dark-bg: linear-gradient(135deg, #1A1A2E 0%, #16213E 50%, #0F3460 100%);

  /* Text on Dark */
  --color-text-on-dark: #FFFFFF;
  --color-text-on-dark-secondary: rgba(255, 255, 255, 0.8);
  --color-text-on-dark-tertiary: rgba(255, 255, 255, 0.7);

  /* Card Dark Theme */
  --color-card-bg-dark: rgba(255, 255, 255, 0.12);
  --color-card-bg-dark-hover: rgba(255, 255, 255, 0.18);
  --color-card-border-dark: rgba(255, 255, 255, 0.15);

  /* Card Light Theme */
  --color-card-border-light: rgba(0, 0, 0, 0.1);

  /* Accent */
  --color-accent: #007AFF;
}
```

---

## Complete Swift Reference

```swift
import SwiftUI

// MARK: - Primary Brand Colors
AppTheme.primaryIndigo      // #6366F1
AppTheme.primaryPurple      // #8B5CF6
AppTheme.primaryGradient    // Indigo -> Purple gradient

// MARK: - Status Colors
AppTheme.success            // Green #34C759
AppTheme.successColor       // Alias
AppTheme.warning            // Orange #FF9500
AppTheme.warningColor       // Alias
AppTheme.error              // Red #FF3B30
AppTheme.errorColor         // Alias
AppTheme.info               // Blue #007AFF
AppTheme.infoColor          // Alias
AppTheme.encryptionColor    // Purple #AF52DE
AppTheme.accentColor        // System accent

// MARK: - Background Colors
AppTheme.backgroundDark1    // #1A1A2E
AppTheme.backgroundDark2    // #16213E
AppTheme.backgroundDark3    // #0F3460
AppTheme.backgroundGradient // Dark gradient

// MARK: - System Colors
AppTheme.windowBackground   // NSColor.windowBackgroundColor
AppTheme.controlBackground  // NSColor.controlBackgroundColor
AppTheme.sectionBackground  // NSColor.underPageBackgroundColor

// MARK: - Text Colors
AppTheme.textOnDark         // White
AppTheme.textOnDarkSecondary // White 80%
AppTheme.textOnDarkTertiary // White 70%
AppTheme.textPrimary        // Primary
AppTheme.textSecondary      // Secondary

// MARK: - Card Colors
AppTheme.cardBackgroundDark      // White 12%
AppTheme.cardBackgroundDarkHover // White 18%
AppTheme.cardBorderDark          // White 15%
AppTheme.cardBackgroundLight     // System control bg
AppTheme.cardBorderLight         // Primary 10%

// MARK: - Legacy Compatibility
AppColors.primary           // Accent color
AppColors.success           // Green
AppColors.warning           // Orange
AppColors.error             // Red
AppColors.info              // Blue
```

---

## Provider Brand Colors

Quick reference for cloud provider colors (from `AppTheme.ProviderColors`):

| Provider | Hex | Swift |
|----------|-----|-------|
| Google Drive | `#4285F4` | `AppTheme.ProviderColors.googleDrive` |
| Dropbox | `#0061FF` | `AppTheme.ProviderColors.dropbox` |
| OneDrive | `#0078D4` | `AppTheme.ProviderColors.oneDrive` |
| iCloud | `#3693F3` | `AppTheme.ProviderColors.iCloud` |
| Box | `#0061D5` | `AppTheme.ProviderColors.box` |
| MEGA | `#D9272E` | `AppTheme.ProviderColors.mega` |
| pCloud | `#00C0FF` | `AppTheme.ProviderColors.pCloud` |
| Proton Drive | `#6D4AFF` | `AppTheme.ProviderColors.protonDrive` |
| Amazon S3 | `#FF9900` | `AppTheme.ProviderColors.amazonS3` |
| Backblaze B2 | `#E21E29` | `AppTheme.ProviderColors.backblazeB2` |
| Wasabi | `#00B64F` | `AppTheme.ProviderColors.wasabi` |
| Cloudflare R2 | `#F87D1E` | `AppTheme.ProviderColors.cloudflareR2` |
| Nextcloud | `#0082C9` | `AppTheme.ProviderColors.nextcloud` |

Use `AppTheme.providerColor(for: "dropbox")` for dynamic lookup.

---

## Color Accessibility

### Contrast Ratios (on White)

| Color | Ratio | WCAG AA | WCAG AAA |
|-------|-------|---------|----------|
| Indigo #6366F1 | 4.6:1 | Pass | Fail |
| Purple #8B5CF6 | 3.4:1 | Large only | Fail |
| Success #34C759 | 2.8:1 | Large only | Fail |
| Warning #FF9500 | 2.7:1 | Large only | Fail |
| Error #FF3B30 | 4.5:1 | Pass | Fail |
| Info #007AFF | 4.5:1 | Pass | Fail |

### Contrast Ratios (White on Color)

| Color | Ratio | WCAG AA | WCAG AAA |
|-------|-------|---------|----------|
| Indigo #6366F1 | 4.6:1 | Pass | Fail |
| Dark BG #1A1A2E | 14.5:1 | Pass | Pass |
| Dark BG #16213E | 12.8:1 | Pass | Pass |
| Dark BG #0F3460 | 9.2:1 | Pass | Pass |

---

## Quick Copy Reference

### Hex Codes Only

```
Primary Indigo:    #6366F1
Primary Purple:    #8B5CF6
Success Green:     #34C759
Warning Orange:    #FF9500
Error Red:         #FF3B30
Info Blue:         #007AFF
Encryption Purple: #AF52DE
Dark BG 1:         #1A1A2E
Dark BG 2:         #16213E
Dark BG 3:         #0F3460
```

### RGB Values Only

```
Primary Indigo:    99, 102, 241
Primary Purple:    139, 92, 246
Success Green:     52, 199, 89
Warning Orange:    255, 149, 0
Error Red:         255, 59, 48
Info Blue:         0, 122, 255
Encryption Purple: 175, 82, 222
Dark BG 1:         26, 26, 46
Dark BG 2:         22, 33, 62
Dark BG 3:         15, 52, 96
```

---

*CloudSync Ultra Color Reference v1.0*
*See BRAND_GUIDELINES.md for complete brand documentation.*
