# CloudSync Ultra Brand Guidelines

**Version:** 1.0
**Last Updated:** January 2026
**Status:** Official

---

## Table of Contents

1. [Brand Overview](#brand-overview)
2. [Color Palette](#color-palette)
3. [Typography](#typography)
4. [Voice & Tone](#voice--tone)
5. [Usage Guidelines](#usage-guidelines)
6. [Accessibility](#accessibility)

---

## Brand Overview

### Mission
CloudSync Ultra empowers users to seamlessly manage and synchronize their files across 42+ cloud storage providers with enterprise-grade security and an intuitive macOS-native experience.

### Brand Personality
- **Professional** - Trusted for enterprise and personal use
- **Approachable** - Complex technology made simple
- **Technical** - Powerful features, expertly crafted
- **Accessible** - Clear communication, no jargon barrier

### Brand Promise
"One app. Every cloud. Complete control."

---

## Color Palette

### Primary Brand Colors

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| **CloudSync Indigo** | `#6366F1` | rgb(99, 102, 241) | Primary brand color, gradients, CTAs |
| **CloudSync Purple** | `#8B5CF6` | rgb(139, 92, 246) | Secondary brand, gradient endpoints |

### Primary Gradient
The signature CloudSync gradient flows from Indigo to Purple, representing seamless data flow.

```
Direction: Top-Leading to Bottom-Trailing
Start: #6366F1 (Indigo)
End: #8B5CF6 (Purple)
```

### Status Colors

| Status | Hex Code | RGB | System Equivalent | Usage |
|--------|----------|-----|-------------------|-------|
| **Success** | `#34C759` | rgb(52, 199, 89) | Color.green | Completed syncs, success states |
| **Warning** | `#FF9500` | rgb(255, 149, 0) | Color.orange | Attention needed, pending |
| **Error** | `#FF3B30` | rgb(255, 59, 48) | Color.red | Sync failures, errors |
| **Info** | `#007AFF` | rgb(0, 122, 255) | Color.blue | Information, links |
| **Encryption** | `#AF52DE` | rgb(175, 82, 222) | Color.purple | Security indicators |

### Background Colors (Dark Theme)

| Name | Hex Code | Usage |
|------|----------|-------|
| **Background Dark 1** | `#1A1A2E` | Primary dark background |
| **Background Dark 2** | `#16213E` | Secondary dark layer |
| **Background Dark 3** | `#0F3460` | Tertiary/accent dark |

### Neutral Colors

| Name | Description | Usage |
|------|-------------|-------|
| **Primary Text** | System primary | Main content text |
| **Secondary Text** | System secondary | Supporting text, labels |
| **Tertiary Text** | System tertiary | Hints, placeholders |
| **Window Background** | NSColor.windowBackgroundColor | Main window |
| **Control Background** | NSColor.controlBackgroundColor | Cards, inputs |

---

## Typography

### Primary Typeface
**SF Pro** (System Font)

CloudSync Ultra uses the native macOS system font to ensure:
- Perfect rendering at all sizes
- Accessibility compliance
- Native platform feel
- Optimal performance

### Font Fallback Stack
```css
font-family: -apple-system, BlinkMacSystemFont, "SF Pro", "Helvetica Neue", Arial, sans-serif;
```

### Type Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| **Hero Title** | 40px | Bold, Rounded | App name in onboarding |
| **Large Title** | 34px | Bold | Screen titles |
| **Title** | 22px | Medium | Section headers |
| **Title 2** | 22px | Regular | Secondary titles |
| **Headline** | 17px | Semibold | Card headers |
| **Subheadline** | 15px | Semibold | List headers |
| **Body** | 17px | Regular | Main content |
| **Caption** | 12px | Regular | Supporting info |
| **Caption 2** | 11px | Regular | Fine print, timestamps |

### Line Height Guidelines
- Body text: 1.4-1.5x font size
- Headlines: 1.2-1.3x font size
- Captions: 1.3x font size

### Swift Usage

```swift
// AppTheme typography tokens
AppTheme.heroTitleFont      // 40pt Bold Rounded
AppTheme.largeTitleFont     // Large Title Bold
AppTheme.titleFont          // Title 2 Medium
AppTheme.headlineFont       // Headline Semibold
AppTheme.subheadlineFont    // Subheadline Semibold
AppTheme.bodyFont           // Body Regular
AppTheme.captionFont        // Caption Regular
AppTheme.caption2Font       // Caption 2 Regular
```

---

## Voice & Tone

### Core Voice Attributes

1. **Professional but Approachable**
   - Confident without being arrogant
   - Technical expertise communicated simply
   - Helpful and supportive

2. **Clear and Concise**
   - Get to the point quickly
   - Use active voice
   - Avoid unnecessary jargon

3. **Empowering**
   - Focus on user capabilities
   - Celebrate achievements
   - Provide guidance, not commands

### Writing Guidelines

#### Do's
- Use "you" and "your" to address users directly
- Lead with benefits, follow with features
- Break complex ideas into digestible pieces
- Use specific numbers and facts

#### Don'ts
- Don't use overly technical jargon without explanation
- Don't use passive voice when active is clearer
- Don't make promises the product can't keep
- Don't use fear-based messaging

### Example Copy

#### Headlines
- **Good:** "Sync 42+ cloud providers with one click"
- **Good:** "Your files, everywhere, always secure"
- **Avoid:** "Revolutionary cloud synchronization paradigm"

#### Button Labels
- **Good:** "Start Syncing" / "Connect Provider" / "Get Started"
- **Avoid:** "Submit" / "Click Here" / "Do It"

#### Error Messages
- **Good:** "Unable to connect to Dropbox. Check your internet connection and try again."
- **Avoid:** "Error code 503: Connection failed"

#### Success Messages
- **Good:** "Sync complete! 247 files updated across 3 providers."
- **Avoid:** "Operation successful"

### Tone Variations

| Context | Tone | Example |
|---------|------|---------|
| Onboarding | Welcoming, encouraging | "Welcome to CloudSync Ultra! Let's get you set up." |
| Success | Celebratory, brief | "Done! Your files are synced." |
| Error | Calm, helpful | "Something went wrong. Here's what you can try..." |
| Marketing | Confident, benefit-focused | "Enterprise-grade sync for everyone." |
| Documentation | Clear, instructive | "To add a provider, click the + button..." |

---

## Usage Guidelines

### Logo Usage

See [LOGO_SPECIFICATIONS.md](./LOGO_SPECIFICATIONS.md) for complete logo guidelines.

**Quick Rules:**
- Maintain clear space equal to icon height on all sides
- Never stretch, rotate, or distort the logo
- Use approved color variations only
- Minimum size: 24px for icon, 120px for horizontal logo

### Color Usage

#### Primary Colors
- Use CloudSync Indigo/Purple gradient for primary CTAs and brand moments
- Reserve for important actions and brand touchpoints
- Don't overuse - maintain visual hierarchy

#### Status Colors
- Use consistently across all interfaces
- Green = success/complete
- Orange = warning/attention
- Red = error/failure
- Blue = information/links
- Purple = encryption/security

#### Background Colors
- Dark backgrounds for immersive experiences (onboarding, splash)
- Light system backgrounds for daily-use interfaces
- Maintain adequate contrast for accessibility

### Spacing System

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXS` | 4px | Tight grouping |
| `spacingS` | 8px | Related elements |
| `spacingM` | 12px | Standard gap |
| `spacing` | 16px | Content sections |
| `spacingL` | 24px | Major sections |
| `spacingXL` | 32px | Page sections |

### Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| `cornerRadiusS` | 6px | Small elements, badges |
| `cornerRadius` | 10px | Standard cards, buttons |
| `cornerRadiusM` | 12px | Medium cards |
| `cornerRadiusL` | 16px | Large cards, modals |
| `cornerRadiusXL` | 20px | Hero elements |

---

## Accessibility

### Color Contrast

All color combinations must meet WCAG 2.1 AA standards:
- Normal text: minimum 4.5:1 contrast ratio
- Large text (18px+ or 14px+ bold): minimum 3:1 contrast ratio
- UI components: minimum 3:1 contrast ratio

### Tested Combinations

| Foreground | Background | Ratio | Pass? |
|------------|------------|-------|-------|
| White | CloudSync Indigo (#6366F1) | 4.6:1 | AA |
| White | Background Dark 1 (#1A1A2E) | 14.5:1 | AAA |
| Primary Text | Window Background | System | AAA |
| Error Red | White | 4.5:1 | AA |

### Color-Blind Considerations

- Never rely on color alone to convey information
- Always pair colors with icons, text, or patterns
- Test designs with color blindness simulators
- Status indicators include icons: checkmark, warning triangle, X

### Motion and Animation

- Respect system "Reduce Motion" preferences
- Provide static alternatives for animated content
- Keep animations brief (under 0.5s for micro-interactions)
- Avoid flashing or strobing effects

---

## Swift Implementation Reference

```swift
// Import the theme
import SwiftUI

// Access colors
AppTheme.primaryIndigo
AppTheme.primaryPurple
AppTheme.primaryGradient
AppTheme.success
AppTheme.warning
AppTheme.error

// Access typography
AppTheme.heroTitleFont
AppTheme.bodyFont

// Access spacing
AppTheme.spacing
AppTheme.spacingL

// Access corner radius
AppTheme.cornerRadius
AppTheme.cornerRadiusL
```

---

## Resources

- [COLOR_REFERENCE.md](./COLOR_REFERENCE.md) - Quick color lookup
- [LOGO_SPECIFICATIONS.md](./LOGO_SPECIFICATIONS.md) - Logo details
- [SOCIAL_MEDIA_ASSETS.md](./SOCIAL_MEDIA_ASSETS.md) - Social assets
- [WEBSITE_ASSETS.md](./WEBSITE_ASSETS.md) - Web assets

---

*CloudSync Ultra Brand Guidelines v1.0*
*Copyright 2026 CloudSync Ultra. All rights reserved.*
