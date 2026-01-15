# CloudSync Ultra - App Store Metadata

## App Information

| Field | Value | Character Limit | Notes |
|-------|-------|----------------|-------|
| **App Name** | CloudSync Ultra | 30 chars | 16 characters used |
| **Subtitle** | Multi-Cloud File Sync | 30 chars | 22 characters used |
| **Primary Category** | Utilities | - | Most appropriate for file management tools |
| **Secondary Category** | Productivity | - | Enhances workflow efficiency |
| **Age Rating** | 4+ | - | No objectionable content |

## Version Information

| Field | Value |
|-------|-------|
| **Version Number** | 2.0.23 |
| **Copyright** | © 2026 CloudSync Ultra Team |
| **SKU** | CLOUDSYNCULTRAMAC |

## Support URLs

| URL Type | Status | Value |
|----------|--------|-------|
| **Support URL** | ❌ TBD | Needs landing page with support docs |
| **Marketing URL** | ❌ TBD | Optional - product website |
| **Privacy Policy URL** | ⏳ In Progress | Being created by Legal-Advisor |

### Support URL Requirements
- FAQ section
- Contact information
- Basic troubleshooting guide
- Link to documentation
- System requirements

### Marketing URL Content (If Created)
- Product features
- Screenshots/videos
- Pricing information
- Download link to App Store
- Press kit

## Pricing & Availability

| Field | Value |
|-------|-------|
| **Price Tier** | TBD - Awaiting Revenue-Engineer's StoreKit implementation |
| **Available Territories** | All territories where App Store is available |
| **Release Method** | Manual Release After Approval |

### Subscription Tiers (Pending Implementation #46)
- **Free Tier**: Basic features, 2 cloud connections
- **Pro Monthly**: $9.99/month - Unlimited clouds
- **Pro Annual**: $79.99/year - Save 33%
- **Lifetime**: $199.99 - One-time purchase

## Age Rating Questionnaire Responses

| Question | Response |
|----------|----------|
| **Made for Kids** | No |
| **Violence** | None |
| **Sexual Content** | None |
| **Profanity or Crude Humor** | None |
| **Horror/Fear Themes** | None |
| **Mature/Suggestive** | None |
| **Gambling** | No |
| **Unrestricted Web Access** | No |
| **User-Generated Content** | No |
| **Location Services** | No |
| **Account Creation** | No (uses existing cloud accounts) |

**Result**: Age Rating 4+ (Suitable for all ages)

## App Review Information

| Field | Value |
|-------|-------|
| **Demo Account Required** | No - Users connect their own cloud accounts |
| **Notes for Reviewer** | See section below |

### App Review Notes

```
Thank you for reviewing CloudSync Ultra!

IMPORTANT SETUP NOTES:
1. The app requires rclone to be installed (via Homebrew: brew install rclone)
2. Users connect their own cloud storage accounts - no demo account needed
3. To test, you can add any cloud provider (even just local storage)

KEY FEATURES TO TEST:
- Add a cloud provider via Settings > Add Remote
- Try the dual-pane file browser
- Test drag & drop between panels
- Check the Quick Actions menu (Cmd+Shift+N)
- View transfer progress indicators

The app is designed for users who need to manage multiple cloud storage services from one native Mac interface. All authentication happens directly with cloud providers - we never see user credentials.

Please let us know if you need any clarification during your review.
```

## Export Compliance

| Field | Value |
|-------|-------|
| **Uses Encryption** | Yes - HTTPS and optional file encryption |
| **Exempt from Export** | Yes - Uses standard encryption protocols |
| **ECCN** | 5D992 |
| **Contains Proprietary Encryption** | No |

### Encryption Details
- HTTPS for all cloud API communications
- Optional AES-256 client-side file encryption
- No custom cryptographic implementations
- Uses system-provided encryption libraries

## In-App Purchases (If Applicable)

Pending implementation by Revenue-Engineer (#46). Will include:
- Pro Monthly Subscription
- Pro Annual Subscription
- Lifetime License

## Localization

| Language | Status |
|----------|--------|
| **English (US)** | ✅ Primary |
| **Other Languages** | 🔮 Future consideration |

## App Store Optimization Notes

1. **App Name Strategy**: "CloudSync Ultra" is memorable, descriptive, and not taken
2. **Subtitle Strategy**: "Multi-Cloud File Sync" immediately communicates the value proposition
3. **Category Placement**: Utilities is less competitive than Productivity for rankings
4. **Icon**: Ensures visual consistency with macOS design language

## Pre-Submission Checklist Reference

Before submission, complete all items in:
- `/docs/APP_STORE_CHECKLIST.md` (comprehensive list)
- `/docs/APP_STORE_SUBMISSION/CHECKLIST.md` (task-specific tracking)

## Coordination Notes

- **Legal-Advisor**: Creating Privacy Policy and Terms of Service
- **Marketing-Lead**: May provide marketing URL and refined messaging
- **Revenue-Engineer**: Implementing StoreKit 2 for subscriptions (#46)

---

*Last Updated: 2026-01-15*
*Task: #78 - App Store Screenshots & Metadata*