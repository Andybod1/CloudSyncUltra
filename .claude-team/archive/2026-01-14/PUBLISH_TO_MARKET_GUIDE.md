# CloudSync Ultra - How to Publish to Market

**Author:** Product-Manager
**Date:** 2026-01-14
**GitHub Issue:** #64
**Model:** Opus 4.5

---

## Executive Summary

This guide documents the complete process for publishing CloudSync Ultra to market. Given the app's architecture (SwiftUI + bundled rclone engine), we have specific considerations for each distribution channel. **Recommended strategy: Start with Direct Download + Homebrew Cask, then expand to Setapp for subscription revenue.**

---

## Table of Contents

1. [Pre-Publication Checklist](#1-pre-publication-checklist)
2. [Distribution Channels Overview](#2-distribution-channels-overview)
3. [Mac App Store](#3-mac-app-store)
4. [Direct Download (Website)](#4-direct-download-website)
5. [Homebrew Cask](#5-homebrew-cask)
6. [Setapp](#6-setapp)
7. [Channel Comparison Matrix](#7-channel-comparison-matrix)
8. [Recommended Strategy](#8-recommended-strategy)
9. [Timeline & Action Plan](#9-timeline--action-plan)

---

## 1. Pre-Publication Checklist

Before publishing to ANY channel, ensure the following items are complete:

### Required for All Channels

- [ ] **Apple Developer Program Membership**
  - Cost: $99 USD/year
  - Enrollment: [developer.apple.com/programs](https://developer.apple.com/programs/)
  - Processing time: 24-48 hours (individual), up to 2 weeks (organization)

- [ ] **Developer ID Certificate**
  - Type: "Developer ID Application" certificate
  - Required for: Direct download, Homebrew, Setapp
  - Generate in: Xcode > Settings > Accounts > Manage Certificates

- [ ] **App Icon Assets**
  - 1024x1024 PNG (App Store)
  - All required sizes in Assets.xcassets

- [ ] **Privacy Policy URL**
  - Required for App Store and Setapp
  - Host on your website

- [ ] **Support URL / Contact**
  - Required for all channels

- [ ] **Marketing Assets**
  - App screenshots (various sizes)
  - App description (short and long versions)
  - Feature list / bullet points
  - Keywords for App Store optimization

### Technical Requirements

- [ ] **Bundle Identifier Set**
  - Current: Use format `com.yourcompany.CloudSyncUltra`
  - Must be unique across all Apple apps

- [ ] **Version Numbers Configured**
  - CFBundleShortVersionString (e.g., "2.0")
  - CFBundleVersion (build number, e.g., "2")

- [ ] **Minimum macOS Version**
  - Current: Set in MACOSX_DEPLOYMENT_TARGET
  - Recommendation: macOS 12.0+ (Monterey) for Apple Silicon optimization

- [ ] **Code Signing Configured**
  - Signing certificate selected
  - Team ID configured

- [ ] **Entitlements Reviewed**
  - Current entitlements in `CloudSyncApp.entitlements`:
    - App Sandbox: Enabled
    - User-selected file access: Read/Write
    - Security-scoped bookmarks: App scope
    - Downloads folder: Read/Write
    - Network client: Enabled
    - Home directory exception for app support

### CloudSync Ultra Specific Considerations

- [ ] **rclone Binary Bundling**
  - rclone must be properly signed and sandboxed
  - Use inherited sandbox entitlement for helper tool
  - See [Section 3.2](#32-sandbox-and-rclone-bundling-challenge) for Mac App Store implications

- [ ] **Provider OAuth Configurations**
  - Ensure OAuth callback URLs are configured
  - Test with production credentials

---

## 2. Distribution Channels Overview

| Channel | Best For | Revenue Model | Time to Market |
|---------|----------|---------------|----------------|
| **Mac App Store** | Maximum reach, trust | 15-30% commission | 2-4 weeks |
| **Direct Download** | Full control, no commission | Self-managed | 1 week |
| **Homebrew Cask** | Developer audience | Free distribution | 1-2 weeks |
| **Setapp** | Subscription revenue | 10-30% commission | 2-4 weeks |

---

## 3. Mac App Store

### 3.1 Overview

The Mac App Store provides the widest distribution reach and built-in user trust, but comes with strict sandboxing requirements and commission fees.

### 3.2 Sandbox and rclone Bundling Challenge

**Critical Issue for CloudSync Ultra:**

The Mac App Store requires full sandboxing of all executables, including bundled command-line tools like rclone. This presents significant challenges:

1. **Embedded CLI tools must use inherited sandbox** (`com.apple.security.inherit`)
2. **File access is restricted** - tools cannot access paths passed via command-line arguments without special handling
3. **rclone's functionality may be limited** by sandbox restrictions on:
   - Accessing arbitrary file system locations
   - Network configurations
   - OAuth browser callbacks

**Potential Solutions:**
- Use XPC Services for rclone communication
- Implement security-scoped bookmarks for file access
- Pass file access through App Groups
- Consider a "lite" version for App Store with reduced functionality

**Recommendation:** Due to rclone integration complexity, the Mac App Store should be a **Phase 2 goal** after establishing presence through other channels.

### 3.3 Requirements

| Requirement | Details |
|-------------|---------|
| **Developer Program** | Apple Developer Program ($99/year) |
| **Xcode Version** | Xcode 16+ (current requirement) |
| **SDK Version** | macOS Tahoe 26 SDK by April 2026 |
| **Sandboxing** | Mandatory - all code must be sandboxed |
| **Notarization** | Automatic through App Store submission |
| **Review Guidelines** | Must comply with [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) |

### 3.4 Commission Structure

| Scenario | Commission Rate |
|----------|-----------------|
| Standard (>$1M annual proceeds) | 30% |
| Small Business Program (<$1M) | 15% |
| Subscriptions after Year 1 | 15% |
| EU Alternative Terms | 10% (with Small Business) |

**Small Business Program Eligibility:**
- Total proceeds under $1M USD in previous calendar year
- Applies across all associated developer accounts
- Enroll at: [developer.apple.com/app-store/small-business-program](https://developer.apple.com/app-store/small-business-program/)

### 3.5 Step-by-Step Process

1. **Prepare App Store Connect**
   - Log in to [App Store Connect](https://appstoreconnect.apple.com)
   - Create new app record
   - Fill in metadata (name, description, keywords, categories)
   - Upload screenshots for all required sizes
   - Add privacy policy URL
   - Configure pricing

2. **Configure Xcode Project**
   ```
   - Select target > Signing & Capabilities
   - Enable "Automatically manage signing"
   - Select Team
   - Add required capabilities/entitlements
   ```

3. **Archive and Upload**
   ```bash
   # In Xcode:
   Product > Archive
   # Then: Distribute App > App Store Connect > Upload
   ```

4. **Submit for Review**
   - In App Store Connect, select build
   - Complete App Review Information
   - Add demo account if needed
   - Submit for Review

5. **Monitor Review Status**
   - Track in App Store Connect
   - Respond to any reviewer questions promptly

### 3.6 Review Timeline

| Submission Type | Expected Time |
|-----------------|---------------|
| New App (first-time developer) | 48-72 hours |
| New App (established developer) | 24-48 hours |
| App Updates | 12-24 hours |
| TestFlight Builds | Under 24 hours |

**Factors That May Extend Review:**
- First submission from account
- Finance, health, or education category apps
- Apps using sensitive permissions (camera, location, health data)
- Third-party login integrations
- Weekend submissions or Apple event periods

### 3.7 Pros and Cons

**Pros:**
- Largest macOS user reach
- Built-in trust and discovery
- Automatic updates for users
- No payment processing needed
- Global distribution with localization support

**Cons:**
- 15-30% commission on all sales
- Strict sandboxing limits functionality
- Review process can cause delays
- Limited pricing flexibility
- rclone integration may be problematic
- No trial/demo versions allowed

---

## 4. Direct Download (Website)

### 4.1 Overview

Distributing directly from your website provides full control, no commission fees, and fewer restrictions on functionality. This is the **recommended primary channel** for CloudSync Ultra.

### 4.2 Requirements

| Requirement | Details |
|-------------|---------|
| **Developer ID Certificate** | "Developer ID Application" certificate |
| **Notarization** | Required for Gatekeeper approval |
| **Website/Hosting** | Secure (HTTPS) download location |
| **Code Signing** | All binaries must be signed |

### 4.3 Notarization Process

Notarization is Apple's malware scanning service. Without it, users see scary Gatekeeper warnings.

**Tools Required:**
- Xcode 14+ (notarytool)
- Valid Developer ID certificate
- App-specific password for Apple ID

**Step-by-Step Notarization:**

1. **Create App-Specific Password**
   - Go to [appleid.apple.com](https://appleid.apple.com)
   - Security > App-Specific Passwords > Generate

2. **Archive Your App**
   ```bash
   # Build release version
   xcodebuild -scheme CloudSyncUltra -configuration Release archive
   ```

3. **Sign the App (if not already signed)**
   ```bash
   codesign --deep --force --verify --verbose \
     --sign "Developer ID Application: Your Name (TEAM_ID)" \
     --options runtime \
     CloudSyncUltra.app
   ```

4. **Create ZIP for Notarization**
   ```bash
   ditto -c -k --keepParent CloudSyncUltra.app CloudSyncUltra.zip
   ```

5. **Submit for Notarization**
   ```bash
   xcrun notarytool submit CloudSyncUltra.zip \
     --apple-id "your@email.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password" \
     --wait
   ```

6. **Staple the Ticket**
   ```bash
   xcrun stapler staple CloudSyncUltra.app
   ```

7. **Create Final DMG**
   ```bash
   hdiutil create -volname "CloudSync Ultra" \
     -srcfolder CloudSyncUltra.app \
     -ov -format UDZO \
     CloudSyncUltra.dmg

   # Notarize the DMG too
   xcrun notarytool submit CloudSyncUltra.dmg \
     --apple-id "your@email.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password" \
     --wait

   xcrun stapler staple CloudSyncUltra.dmg
   ```

### 4.4 Gatekeeper Behavior

| Signing Status | User Experience |
|----------------|-----------------|
| Signed + Notarized + Stapled | Opens without warning |
| Signed + Notarized (not stapled) | Opens after online check |
| Signed only | Warning: "Cannot verify developer" |
| Unsigned | Blocked: "App is damaged" |

### 4.5 Distribution Options

**DMG (Recommended):**
- Professional appearance
- Can include custom background/layout
- Easy drag-to-Applications install

**ZIP:**
- Simpler to create
- Slightly less professional

**PKG Installer:**
- More control over installation
- Can run pre/post-install scripts
- Better for complex setups

### 4.6 Update Mechanism

For direct distribution, implement your own update mechanism:

**Options:**
1. **Sparkle Framework** (Recommended)
   - Industry standard for macOS apps
   - Supports delta updates
   - [sparkle-project.org](https://sparkle-project.org)

2. **Custom Implementation**
   - Check version endpoint periodically
   - Download and prompt user

### 4.7 Costs

| Item | Cost |
|------|------|
| Apple Developer Program | $99/year |
| Website Hosting | $5-50/month |
| CDN (optional) | $10-100/month |
| **Total Annual** | **~$200-600** |

### 4.8 Pros and Cons

**Pros:**
- No commission fees
- Full functionality (no sandbox restrictions)
- Immediate availability after notarization
- Trial versions allowed
- Flexible pricing models
- Direct customer relationship

**Cons:**
- Need own website and payment processing
- Handle own updates
- Less discoverable than App Store
- Users may be wary of non-App Store downloads
- Must manage notarization process

---

## 5. Homebrew Cask

### 5.1 Overview

Homebrew Cask is a package manager for macOS applications, popular among developers and power users. It's free distribution with technical credibility.

### 5.2 Requirements

| Requirement | Details |
|-------------|---------|
| **Code Signing** | Mandatory (enforced since 2024) |
| **Notarization** | Required - Casks fail audit without it |
| **Stable Download URL** | Versioned URL that won't change |
| **macOS Compatibility** | Must run on latest macOS |

**Important Deadline:** Unsigned/unnotarized casks will be removed by **September 2026**.

### 5.3 Step-by-Step Process

1. **Prepare Your App**
   - Ensure app is signed and notarized
   - Host DMG/ZIP at stable, versioned URL
   - Example: `https://yoursite.com/releases/CloudSyncUltra-2.0.dmg`

2. **Create the Cask File**
   ```bash
   brew create --cask https://yoursite.com/releases/CloudSyncUltra-2.0.dmg \
     --set-name cloudsync-ultra
   ```

3. **Edit the Cask Definition**
   ```ruby
   cask "cloudsync-ultra" do
     version "2.0"
     sha256 "abc123..."  # SHA-256 of your DMG

     url "https://yoursite.com/releases/CloudSyncUltra-#{version}.dmg"
     name "CloudSync Ultra"
     desc "Multi-cloud management for macOS with 40+ provider support"
     homepage "https://cloudsync-ultra.com"

     livecheck do
       url "https://yoursite.com/releases/latest.json"
       strategy :json do |json|
         json["version"]
       end
     end

     app "CloudSync Ultra.app"

     zap trash: [
       "~/Library/Application Support/CloudSyncApp",
       "~/Library/Preferences/com.yourcompany.CloudSyncUltra.plist",
       "~/Library/Caches/com.yourcompany.CloudSyncUltra",
     ]
   end
   ```

4. **Test Locally**
   ```bash
   brew install --cask ./cloudsync-ultra.rb
   brew uninstall --cask cloudsync-ultra
   ```

5. **Submit Pull Request**
   - Fork [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask)
   - Add your cask file to `Casks/c/cloudsync-ultra.rb`
   - Submit PR with description

6. **Maintain the Cask**
   - Submit PRs for version updates
   - Or use automated tools like `brew bump-cask-pr`

### 5.4 Naming Guidelines

- Use lowercase with hyphens: `cloudsync-ultra`
- Avoid generic names
- Include vendor prefix if forking another app
- Beta/nightly versions: `cloudsync-ultra@beta`

### 5.5 Acceptance Criteria

**Accepted:**
- GUI applications distributed as binaries
- Apps with stable, versioned downloads
- Signed and notarized apps
- Freemium apps (if full version doesn't require re-download)

**Not Accepted:**
- Mac App Store-only apps
- Trial versions requiring separate full download
- Unsigned applications (deadline: September 2026)

### 5.6 Timeline

| Step | Duration |
|------|----------|
| Prepare signed/notarized app | 1-2 days |
| Create and test cask locally | 1 day |
| PR review and merge | 3-7 days |
| **Total** | **1-2 weeks** |

### 5.7 Pros and Cons

**Pros:**
- Free distribution
- Credibility with developer audience
- Easy installation for users (`brew install --cask cloudsync-ultra`)
- Automatic update path
- Good for power user target market

**Cons:**
- Limited audience (Homebrew users only)
- Must maintain cask for updates
- No revenue directly from channel
- PR review process for each update

---

## 6. Setapp

### 6.1 Overview

Setapp is a subscription service offering 240+ Mac apps for a monthly fee. Revenue is shared based on app usage. **Highly recommended** for CloudSync Ultra given the target market overlap.

### 6.2 Requirements

| Requirement | Details |
|-------------|---------|
| **App Quality** | High design standards, professional polish |
| **macOS Compatibility** | macOS 10.13+ recommended |
| **No In-App Purchases** | Premium features must be fully unlocked |
| **No Ads** | Clean user experience required |
| **Original Work** | No mimicking well-known products |

### 6.3 Revenue Model

**Revenue Split:**

| Scenario | Developer Share | Setapp Share |
|----------|-----------------|--------------|
| Direct user (no partner) | 70% | 30% |
| Partner-referred user | 70% | 10% (+ 20% to partner) |
| Maximum possible | Up to 90% | 10% minimum |

**How Revenue is Calculated:**
- Based on user engagement (app opens/usage time)
- Higher price tier = higher multiplier in calculations
- Revenue distributed among all apps a user opened that billing period

**Price Tiers:**
- Tier based on your app's annual subscription price
- Higher-priced apps earn more per user engagement
- Annual subscription prioritized over monthly × 12

**Payment Timeline:**
- Reports finalized at end of month + 1
- First payment: ~2-2.5 months after user sign-up

### 6.4 Step-by-Step Process

1. **Apply to Setapp**
   - Contact: developers@setapp.com
   - Or wait for Setapp to reach out (they scout apps)
   - Include: app description, screenshots, value proposition

2. **Prepare Application**
   - Ensure app meets quality guidelines
   - Remove any in-app purchases or paywalls
   - Verify macOS 10.13+ compatibility
   - Test thoroughly (no demo/trial versions)

3. **Technical Integration**
   - Integrate Setapp SDK/Framework
   - Implement license verification
   - Configure bundle ID to match Setapp pattern
   - Handle "Setapp user" vs "direct purchase" logic

4. **Submit for Review**
   - Upload build through Setapp Developer Portal
   - Provide metadata, screenshots, descriptions
   - Initial review may take 1-2 weeks

5. **Launch and Monitor**
   - Setapp announces addition to catalog
   - Monitor usage statistics in developer dashboard
   - Submit updates through facilitated review process

### 6.5 Partner Program

As a Setapp developer, you can become a Partner:
- Invite your existing users to Setapp
- Earn 20% of their subscription fees
- Revenue independent of your app's usage
- Good way to monetize non-Setapp users

### 6.6 Exclusions

**Not Accepted:**
- Gaming, gambling, dating apps
- Apps with misleading information
- Apps with in-app stores or paywalls
- Apps with intrusive ads
- Low-quality or poorly designed apps
- Apps mimicking well-known products

### 6.7 CloudSync Ultra Fit Assessment

**Strengths for Setapp:**
- Productivity/utility category (popular on Setapp)
- High-quality native macOS app
- Clear value proposition
- No ads or data collection
- Professional target audience overlap

**Considerations:**
- Must remove any planned paid tiers for Setapp users
- rclone bundling should work fine (no App Store sandbox)
- Need to implement Setapp licensing SDK

### 6.8 Pros and Cons

**Pros:**
- Steady subscription revenue
- Access to 1M+ Setapp subscribers
- No sandbox restrictions (like direct download)
- Setapp handles payments and customer support
- Marketing exposure through Setapp catalog
- Partner program for additional revenue

**Cons:**
- Revenue depends on user engagement
- 2-2.5 month payment delay
- Must remove in-app purchases
- Curation may reject app
- Less control over pricing
- Revenue sharing reduces per-user income

---

## 7. Channel Comparison Matrix

| Factor | Mac App Store | Direct Download | Homebrew | Setapp |
|--------|---------------|-----------------|----------|--------|
| **Initial Cost** | $99/year | $99/year + hosting | $99/year | $99/year |
| **Commission** | 15-30% | 0% | 0% | 10-30% |
| **Time to Market** | 2-4 weeks | 1 week | 1-2 weeks | 2-4 weeks |
| **Audience Size** | Largest | Medium | Small (devs) | Medium |
| **User Trust** | Highest | Medium | High (devs) | High |
| **Functionality** | Limited (sandbox) | Full | Full | Full |
| **rclone Compatible** | Challenging | Yes | Yes | Yes |
| **Trial Versions** | No | Yes | Yes (freemium) | N/A |
| **Update Control** | Apple-managed | Self-managed | PR-based | Setapp-managed |
| **Payment Handling** | Apple | Self | N/A | Setapp |
| **Revenue Model** | Per-sale | Per-sale | Free | Usage-based |

---

## 8. Recommended Strategy

### Phase 1: Foundation (Month 1-2)

**Primary Channel: Direct Download**
- Full rclone functionality
- No commission fees
- Build initial user base
- Implement Sparkle for updates
- Offer free tier + paid upgrades

**Secondary Channel: Homebrew Cask**
- Reach developer audience
- Build credibility
- Free marketing to power users
- Low maintenance after initial setup

### Phase 2: Revenue Expansion (Month 3-4)

**Add: Setapp**
- Subscription revenue stream
- Access to 1M+ subscribers
- Good fit for productivity app category
- Complements direct sales

### Phase 3: Maximum Reach (Month 6+)

**Consider: Mac App Store**
- Only after:
  - Solving rclone sandbox integration
  - Or creating "Lite" version
  - Validating demand through other channels
- Maximum visibility
- Built-in trust and payments

### Pricing Strategy Across Channels

| Channel | Model | Suggested Pricing |
|---------|-------|-------------------|
| Direct | Freemium + Lifetime License | Free / $49 one-time |
| Direct | Subscription | $4.99/month or $39/year |
| Homebrew | Free (leads to Direct) | Free |
| Setapp | Included in subscription | N/A (usage-based revenue) |
| App Store | Subscription (if launched) | $4.99/month or $39/year |

---

## 9. Timeline & Action Plan

### Week 1-2: Prerequisites
- [ ] Ensure Apple Developer Program membership active
- [ ] Generate Developer ID Application certificate
- [ ] Set up code signing in Xcode
- [ ] Prepare marketing assets (screenshots, descriptions)
- [ ] Create privacy policy page
- [ ] Set up website/landing page

### Week 3: Direct Download Launch
- [ ] Create release build
- [ ] Sign all binaries (including rclone)
- [ ] Submit for notarization
- [ ] Staple notarization ticket
- [ ] Create DMG with professional appearance
- [ ] Notarize DMG
- [ ] Set up download hosting (GitHub Releases or CDN)
- [ ] Implement Sparkle for auto-updates
- [ ] **LAUNCH on website**

### Week 4: Homebrew Submission
- [ ] Create cask file
- [ ] Test locally with `brew install --cask`
- [ ] Fork homebrew-cask repository
- [ ] Submit pull request
- [ ] Respond to reviewer feedback
- [ ] **LIVE on Homebrew** (after PR merge)

### Week 5-6: Setapp Application
- [ ] Contact developers@setapp.com
- [ ] Prepare application materials
- [ ] Begin Setapp SDK integration
- [ ] Submit app for review
- [ ] Iterate based on feedback

### Month 3+: Ongoing
- [ ] Monitor user feedback
- [ ] Release updates through all channels
- [ ] Evaluate Mac App Store feasibility
- [ ] Consider localization for international markets

---

## Appendix A: Quick Reference Commands

### Code Signing
```bash
# Check if app is signed
codesign -dv --verbose=4 CloudSyncUltra.app

# Sign app with Developer ID
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  CloudSyncUltra.app
```

### Notarization
```bash
# Submit for notarization
xcrun notarytool submit CloudSyncUltra.zip \
  --apple-id "email@example.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Check notarization status
xcrun notarytool info <submission-id> \
  --apple-id "email@example.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password"

# Staple ticket
xcrun stapler staple CloudSyncUltra.app

# Verify stapling
xcrun stapler validate CloudSyncUltra.app
```

### DMG Creation
```bash
# Create DMG
hdiutil create -volname "CloudSync Ultra" \
  -srcfolder CloudSyncUltra.app \
  -ov -format UDZO \
  CloudSyncUltra.dmg
```

### Homebrew Cask
```bash
# Create cask
brew create --cask <download-url> --set-name cloudsync-ultra

# Install locally for testing
brew install --cask ./cloudsync-ultra.rb

# Audit cask
brew audit --cask cloudsync-ultra

# Get SHA-256 of file
shasum -a 256 CloudSyncUltra.dmg
```

---

## Appendix B: Resources

### Apple Documentation
- [Submitting to the App Store](https://developer.apple.com/app-store/submitting/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Developer ID and Gatekeeper](https://developer.apple.com/developer-id/)
- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
- [App Sandbox Documentation](https://developer.apple.com/documentation/security/app-sandbox)
- [Embedding CLI Tools in Sandboxed Apps](https://developer.apple.com/documentation/xcode/embedding-a-helper-tool-in-a-sandboxed-app)
- [Small Business Program](https://developer.apple.com/app-store/small-business-program/)

### Homebrew
- [Acceptable Casks](https://docs.brew.sh/Acceptable-Casks)
- [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [homebrew-cask GitHub](https://github.com/Homebrew/homebrew-cask)

### Setapp
- [Developer Program](https://setapp.com/developers)
- [Setapp Requirements](https://docs.setapp.com/docs/preparing-your-application-for-setapp)
- [Revenue Distribution](https://docs.setapp.com/docs/distributing-revenue)
- [Review Guidelines](https://docs.setapp.com/docs/review-guidelines)

### Tools
- [Sparkle Framework](https://sparkle-project.org) - Auto-update framework
- [create-dmg](https://github.com/create-dmg/create-dmg) - DMG creation tool

---

*Publishing guide by Product-Manager using Opus 4.5*
*Last updated: 2026-01-14*
