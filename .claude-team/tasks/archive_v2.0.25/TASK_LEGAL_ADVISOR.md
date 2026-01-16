# TASK: Compliance Package (Privacy Policy, ToS)

## Ticket
**Type:** Legal / Compliance
**Size:** M (1-2 hours)
**Priority:** Critical (required for App Store)

---

## Objective

Create comprehensive legal documents required for App Store submission and user trust.

---

## Deliverables

### 1. Privacy Policy

**Required for App Store submission.**

**Content to Include:**
- What data we collect
- How we use the data
- Data storage and security
- Third-party services (rclone, cloud providers)
- User rights (access, deletion)
- Contact information
- Last updated date

**CloudSync Ultra Data Practices:**
- ✅ Local-only processing (no cloud backend)
- ✅ Credentials stored in macOS Keychain
- ✅ No analytics/tracking (currently)
- ✅ No personal data sent to our servers
- ⚠️ Cloud provider OAuth tokens stored locally
- ⚠️ Crash reports stored locally (optional sharing)

### 2. Terms of Service

**Content to Include:**
- Acceptance of terms
- Service description
- User responsibilities
- Intellectual property
- Disclaimers and limitations
- Termination
- Governing law
- Changes to terms

**Key Points:**
- User responsible for cloud provider compliance
- No guarantee of data integrity (use at own risk)
- Subscription terms and billing
- Refund policy (follows Apple's policy)

### 3. App Privacy Labels

**For App Store Connect submission:**

| Category | CloudSync Ultra |
|----------|-----------------|
| Data Used to Track You | None |
| Data Linked to You | None |
| Data Not Linked to You | Crash Data (optional) |

### 4. GDPR/CCPA Notes

Document compliance:
- GDPR: EU user rights
- CCPA: California user rights
- Data portability
- Right to deletion
- Processing legal basis

---

## Output Directory

Create: `docs/legal/`

```
docs/legal/
├── PRIVACY_POLICY.md
├── TERMS_OF_SERVICE.md
├── APP_PRIVACY_LABELS.md
├── GDPR_COMPLIANCE.md
└── CCPA_COMPLIANCE.md
```

---

## Privacy Policy Template Structure

```markdown
# Privacy Policy

**Last Updated:** [Date]

## Introduction
CloudSync Ultra ("we", "our", "us") respects your privacy...

## Information We Collect
### Information You Provide
- Cloud provider credentials (stored locally)
- App preferences and settings

### Information Collected Automatically
- Crash reports (optional, local storage)

## How We Use Information
- To provide sync functionality
- To store your preferences
- To improve app stability (crash reports)

## Data Storage and Security
- All data stored locally on your device
- Credentials secured via macOS Keychain
- No data transmitted to our servers

## Third-Party Services
- Cloud providers (Google, Dropbox, etc.)
- rclone (open-source sync engine)

## Your Rights
- Access your data
- Delete your data
- Export your data

## Contact Us
[Contact information]

## Changes to This Policy
[Update policy]
```

---

## Terms of Service Template Structure

```markdown
# Terms of Service

**Last Updated:** [Date]

## 1. Acceptance of Terms
By using CloudSync Ultra...

## 2. Description of Service
CloudSync Ultra is a file synchronization application...

## 3. User Responsibilities
- Maintain valid cloud provider accounts
- Comply with cloud provider terms
- Backup important data

## 4. Subscriptions and Billing
- Subscription tiers: Free, Pro, Team
- Billing through Apple App Store
- Refunds per Apple's policy

## 5. Intellectual Property
- App ownership
- User content ownership

## 6. Disclaimers
- Provided "as is"
- No guarantee of data integrity
- Not liable for data loss

## 7. Limitation of Liability
[Standard limitation clause]

## 8. Termination
[Termination conditions]

## 9. Governing Law
[Jurisdiction]

## 10. Changes to Terms
[Update policy]

## 11. Contact
[Contact information]
```

---

## Hosting Considerations

**Options for hosting legal docs:**
1. GitHub Pages (free, version controlled)
2. Landing page (coordinate with Marketing-Lead)
3. Notion public page
4. Simple HTML page

**URLs needed for App Store Connect:**
- Privacy Policy URL
- Terms of Service URL
- Support URL

---

## Acceptance Criteria

- [ ] Privacy Policy complete and comprehensive
- [ ] Terms of Service complete
- [ ] App Privacy Labels documented
- [ ] GDPR compliance notes
- [ ] CCPA compliance notes
- [ ] All docs in `docs/legal/`
- [ ] URLs ready for App Store Connect (coordinate hosting)

---

## Notes

- Use /think hard for legal accuracy
- Keep language clear and user-friendly
- Reference similar apps for standard clauses
- Consider legal review for production use

---

*Task created: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready"*
