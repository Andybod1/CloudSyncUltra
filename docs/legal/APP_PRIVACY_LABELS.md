# App Privacy Labels for CloudSync Ultra

**Last Updated:** January 15, 2026

**Purpose**: This document provides the privacy information required for App Store Connect submission.

---

## Privacy Label Summary

CloudSync Ultra is designed with privacy as a core principle. We operate entirely locally on the user's device with no cloud backend or data collection infrastructure.

### Quick Reference for App Store Connect

| Category | CloudSync Ultra Status |
|----------|----------------------|
| **Data Used to Track You** | ❌ None |
| **Data Linked to You** | ❌ None |
| **Data Not Linked to You** | ✅ Diagnostics (Optional) |

---

## Detailed Privacy Labels

### 1. Data Used to Track You
**Status**: None

CloudSync Ultra does not track users across apps and websites owned by other companies.

### 2. Data Linked to You
**Status**: None

CloudSync Ultra does not collect any data that is linked to the user's identity.

### 3. Data Not Linked to You
**Status**: Diagnostics (Optional)

#### Crash Data
- **Collection**: Yes (Optional)
- **Purpose**: App Functionality (improving app reliability)
- **Storage**: Local only
- **Sharing**: Only if user explicitly chooses to share
- **Details**: Crash reports contain technical information about app failures, stored locally in the system crash reporter

---

## App Store Connect Privacy Questions

### Contact Information
**Do you collect Contact Info?** No
- Name: No
- Email Address: No
- Phone Number: No
- Physical Address: No
- Other User Contact Info: No

### Health and Fitness
**Do you collect Health & Fitness data?** No

### Financial Information
**Do you collect Financial Info?** No
- Payment Info: No (handled by App Store)
- Credit Info: No
- Other Financial Info: No

### Location
**Do you collect Location data?** No
- Precise Location: No
- Coarse Location: No

### Sensitive Information
**Do you collect Sensitive Info?** No

### Contacts
**Do you collect Contacts?** No

### User Content
**Do you collect User Content?** No
- Photos or Videos: No
- Audio Data: No
- Gameplay Content: No
- Customer Support: No
- Other User Content: No

### Browsing History
**Do you collect Browsing History?** No

### Search History
**Do you collect Search History?** No

### Identifiers
**Do you collect Identifiers?** No
- User ID: No
- Device ID: No

### Purchases
**Do you collect Purchase History?** No

### Usage Data
**Do you collect Usage Data?** No
- Product Interaction: No
- Advertising Data: No
- Other Usage Data: No

### Diagnostics
**Do you collect Diagnostics?** Yes (Optional)
- Crash Data: Yes (Local storage only, optional sharing)
- Performance Data: No
- Other Diagnostic Data: No

### Other Data
**Do you collect Other Data Types?** No

---

## Data Practices by Feature

### Core Sync Functionality
- **Data Collected**: None
- **Data Stored**: Cloud credentials (local Keychain only)
- **Data Transmitted**: None to our servers (only to user's chosen cloud providers)

### Settings and Preferences
- **Data Collected**: User preferences
- **Data Stored**: Locally in app sandbox
- **Data Transmitted**: None

### Crash Reporting
- **Data Collected**: Technical crash information
- **Data Stored**: macOS crash reporter (local)
- **Data Transmitted**: Only if user chooses to share with Apple

---

## Third-Party SDKs and Services

### rclone
- **Purpose**: File synchronization engine
- **Data Collection**: None (operates locally)
- **Privacy Policy**: Open source, no data collection

### Cloud Provider SDKs
- **Purpose**: Authentication with cloud services
- **Data Collection**: Per provider's privacy policy
- **Note**: OAuth tokens stored locally in Keychain

---

## Encryption and Security

### Encryption Declaration
CloudSync Ultra uses encryption for:
- Optional file encryption during sync (rclone crypt)
- HTTPS for cloud provider communications
- macOS Keychain for credential storage

**Export Compliance**: May require export compliance documentation due to encryption features.

---

## Data Retention and Deletion

### User Control
Users have complete control over their data:
- Can delete cloud connections at any time
- Can clear all app data via app removal
- Crash reports managed by macOS system

### Automatic Deletion
- No automatic data collection or retention
- All data remains under user control

---

## Required URLs for App Store Connect

### Privacy Policy URL
`https://[yourdomain.com]/privacy`

### Terms of Service URL
`https://[yourdomain.com]/terms`

---

## App Store Connect Submission Checklist

- [ ] Set "Data Used to Track You" to None
- [ ] Set "Data Linked to You" to None
- [ ] Add "Crash Data" under "Data Not Linked to You"
- [ ] Set purpose for Crash Data to "App Functionality"
- [ ] Provide Privacy Policy URL
- [ ] Provide Terms of Service URL
- [ ] Complete encryption export compliance
- [ ] Review all answers match app functionality

---

## Notes for Submission

1. **Be Conservative**: If uncertain, declare data collection
2. **Match Reality**: Ensure labels match actual app behavior
3. **Update Regularly**: Review labels with each app update
4. **Test Thoroughly**: Verify no unexpected data collection

---

## Contact for Privacy Questions

For App Store review questions about privacy:
- Primary Contact: [Your Name]
- Email: [privacy@yourdomain.com]
- Response Time: Within 24 hours

---

*This document is for internal use to guide App Store Connect submission. The actual privacy labels must be entered directly in App Store Connect.*