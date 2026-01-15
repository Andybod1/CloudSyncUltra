# Sprint v2.0.23 Planning
> "Launch Ready" 🚀
> Target: App Store submission

---

## Sprint Goals

1. **In-App Purchase** - Implement pricing/subscription logic
2. **App Store Assets** - Screenshots, metadata, description
3. **Brand Identity** - Marketing assets for launch
4. **Security** - Harden before public release
5. **Provider** - Add Dropbox (popular request)

---

## Why Launch Now?

```
✅ 42 providers working
✅ 841 tests passing  
✅ 90% health score
✅ Pricing strategy defined ($9.99/mo Pro)
✅ Ops excellence ~88%
❌ $0 revenue while we polish

Every week NOT in App Store = $0 revenue
Time to market is the biggest lever.
```

---

## Proposed Tickets

### Dev-1: Pricing & IAP Logic (#46)
**Size:** L | **Est:** 2-3 hours

Implement StoreKit 2 for subscriptions:
- Free tier (2 connections, 5GB/mo)
- Pro tier ($9.99/mo or $99/yr)
- Subscription management UI
- Restore purchases
- Receipt validation

**Files:** 
- Managers/StoreKitManager.swift (NEW)
- Models/SubscriptionTier.swift (NEW)
- Views/SubscriptionView.swift (NEW)
- Views/SettingsView.swift (update)

**Reference:** `.claude-team/outputs/PRODUCT_MANAGER_COMPLETE.md`

---

### Dev-2: Dropbox Support (#37)
**Size:** M | **Est:** 1-2 hours

Add Dropbox as supported provider:
- OAuth flow implementation
- Provider configuration
- Dropbox-specific chunk sizes
- Real account testing

**Files:** Models/CloudProvider.swift, RcloneManager.swift

---

### Dev-3: Secure File Handling (#74)
**Size:** M | **Est:** 1-2 hours

Security hardening before public release:
- Restrict log file permissions (600)
- Secure config file permissions
- Sanitize file paths in logs
- Secure temp file handling

**Files:** Logger+Extensions.swift, RcloneManager.swift

---

### QA: IAP & Security Tests
**Size:** M | **Est:** 1-2 hours

- StoreKit testing with sandbox
- Subscription state tests
- Security permission tests
- Full regression suite
- TestFlight build validation

---

### Dev-Ops: App Store Screenshots & Metadata (#78)
**Size:** M | **Est:** 1-2 hours

Create App Store submission package:
- Screenshots for all required sizes
- App description (short + long)
- Keywords research
- Privacy policy URL
- Support URL
- Categories selection
- Age rating questionnaire

**Output:** `docs/APP_STORE_SUBMISSION/`

---

### UX-Designer: Brand Identity (#79)
**Size:** M | **Est:** 1-2 hours

Marketing assets for launch:
- App icon variations (if needed)
- Feature graphics
- Social media assets
- Press kit basics
- Landing page mockup

**Output:** `assets/marketing/`

---

## Capacity Planning

| Worker | Ticket | Size | Priority |
|--------|--------|------|----------|
| Dev-1 | #46 Pricing/IAP | L | 🔴 Critical |
| Dev-2 | #37 Dropbox | M | 🟡 High |
| Dev-3 | #74 Security | M | 🔴 Critical |
| QA | IAP + Security Tests | M | 🔴 Critical |
| Dev-Ops | #78 App Store Assets | M | 🔴 Critical |
| UX-Designer | #79 Brand Identity | M | 🟡 High |

**Total:** 1L + 5M = ~8-10 hours parallel work
**Workers:** 6 (full team + UX-Designer)

---

## Dependencies

```
#46 (IAP) ──→ QA Testing ──→ TestFlight
#74 (Security) ──→ QA Testing ──→ App Store Review
#78 (Screenshots) ──→ App Store Submission
#79 (Brand) ──→ Marketing Launch
```

---

## Success Criteria

- [ ] StoreKit 2 subscriptions working
- [ ] Free/Pro tier enforcement
- [ ] Dropbox OAuth functional
- [ ] Security hardening complete
- [ ] App Store screenshots ready
- [ ] Metadata & description written
- [ ] Brand assets created
- [ ] TestFlight build uploaded
- [ ] VERSION → 2.0.23
- [ ] Ready for App Store submission

---

## App Store Checklist

| Requirement | Owner | Status |
|-------------|-------|--------|
| App binary (notarized) | Dev-Ops scripts | 🟡 Ready |
| Screenshots (6.7", 6.5", etc.) | Dev-Ops | 🔴 TODO |
| App description | Dev-Ops | 🔴 TODO |
| Privacy policy | Dev-Ops | 🔴 TODO |
| IAP configured | Dev-1 | 🔴 TODO |
| Age rating | Dev-Ops | 🔴 TODO |
| Categories | Dev-Ops | 🔴 TODO |
| Keywords | Dev-Ops | 🔴 TODO |
| Support URL | Dev-Ops | 🔴 TODO |

---

## Post-Sprint: Launch Sequence

1. Submit to App Store Review
2. Prepare launch announcement
3. Submit to Product Hunt
4. Social media posts
5. Monitor reviews & feedback

---

*Sprint planned by Strategic Partner*
*Goal: Ready for App Store submission*
