# Sprint v2.0.23 Planning
> "Launch Ready" 🚀
> Target: App Store submission

---

## Sprint Goals

1. **Revenue** - Implement StoreKit 2 subscriptions
2. **Legal** - Privacy policy, ToS, compliance
3. **Marketing** - Launch strategy, landing page, press kit
4. **Security** - Harden before public release
5. **Provider** - Add Dropbox (popular request)
6. **Assets** - App Store screenshots & metadata

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

## Team Assignment

| Worker | Ticket | Task | Size |
|--------|--------|------|------|
| **Revenue-Engineer** | #46 | StoreKit 2 Subscriptions | L |
| **Legal-Advisor** | NEW | Privacy Policy, ToS, Compliance | M |
| **Marketing-Lead** | NEW | Launch Strategy, Landing Page | M |
| **Dev-1** | #96 | Transfer Progress Counter (Quick Win) | S |
| **Dev-2** | #37 | Dropbox Support | M |
| **Dev-3** | #74 | Security Hardening | M |
| **Dev-Ops** | #78 | App Store Screenshots & Metadata | M |
| **QA** | - | IAP + Security Tests | M |

**8 workers in parallel** → Maximum velocity

---

## Detailed Tasks

### Revenue-Engineer: StoreKit 2 Subscriptions (#46)
**Size:** L | **Est:** 2-3 hours

Implement subscription system:
- StoreKitManager.swift with StoreKit 2
- SubscriptionTier model (Free/Pro/Team)
- PaywallView for upgrade prompts
- Feature gating based on tier
- Restore purchases
- Receipt validation
- Sandbox testing

**Reference:** `.claude-team/outputs/PRODUCT_MANAGER_COMPLETE.md`

**Files:**
- `Managers/StoreKitManager.swift` (NEW)
- `Models/SubscriptionTier.swift` (NEW)
- `Views/PaywallView.swift` (NEW)
- `Views/SubscriptionView.swift` (NEW)

---

### Legal-Advisor: Compliance Package
**Size:** M | **Est:** 1-2 hours

Create legal documents for App Store:
- Privacy Policy (required)
- Terms of Service
- App Privacy labels documentation
- GDPR/CCPA compliance notes
- Data handling disclosure

**Output:** `docs/legal/`

---

### Marketing-Lead: Launch Package
**Size:** M | **Est:** 1-2 hours

Create launch materials:
- Positioning & messaging
- Landing page copy
- App Store description
- Press kit
- Product Hunt plan
- Launch checklist

**Output:** `docs/marketing/`

---

### Dev-1: Transfer Progress Counter (#96) ⚡ Quick Win
**Size:** S | **Est:** 30-45 min

Display concurrent transfer count in progress UI:
- Show "X/Y transfers" (active/max parallel)
- Data available in TransferEngine.parallelismConfig
- Add indicator to TransferProgressView or TransferStatusView

**Files:** 
- `CloudSyncApp/Views/TransferView.swift` or `TransferProgressView.swift`
- `CloudSyncApp/ViewModels/TransferViewModel.swift` (if needed)

---

### Dev-2: Dropbox Support (#37)
**Size:** M | **Est:** 1-2 hours

Add Dropbox as provider:
- OAuth flow
- Provider configuration
- Chunk size optimization
- Real account testing

**Files:** `CloudProvider.swift`, `RcloneManager.swift`

---

### Dev-3: Security Hardening (#74)
**Size:** M | **Est:** 1-2 hours

Pre-launch security:
- Log file permissions (600)
- Config file permissions
- Path sanitization
- Secure temp handling

**Files:** `Logger+Extensions.swift`, `RcloneManager.swift`

---

### Dev-Ops: App Store Assets (#78)
**Size:** M | **Est:** 1-2 hours

Submission package:
- Screenshots (all required sizes)
- Keywords research
- Categories selection
- Age rating
- Support URL setup

**Output:** `docs/APP_STORE_SUBMISSION/`

---

### QA: IAP & Security Tests
**Size:** M | **Est:** 1-2 hours

Testing:
- StoreKit sandbox testing
- Subscription state tests
- Security permission tests
- Full regression suite
- TestFlight validation

---

## Dependencies

```
Revenue-Engineer ──→ QA (IAP tests) ──→ TestFlight
Legal-Advisor ──→ App Store Submission
Marketing-Lead ──→ Launch execution
Dev-3 ──→ QA (security tests) ──→ App Store Review
Dev-Ops ──→ App Store Submission
```

---

## Success Criteria

- [ ] StoreKit 2 subscriptions working (Free/Pro tiers)
- [ ] Privacy Policy published
- [ ] Terms of Service published
- [ ] Landing page copy ready
- [ ] Launch strategy documented
- [ ] Transfer progress counter showing X/Y transfers (#96)
- [ ] Dropbox OAuth functional
- [ ] Security hardening complete
- [ ] App Store screenshots ready
- [ ] All metadata written
- [ ] TestFlight build uploaded
- [ ] VERSION → 2.0.23
- [ ] **Ready to click "Submit for Review"**

---

## App Store Checklist

| Requirement | Owner | Status |
|-------------|-------|--------|
| App binary (notarized) | Dev-Ops scripts | 🟡 Ready |
| Screenshots | Dev-Ops | 🔴 TODO |
| App description | Marketing-Lead | 🔴 TODO |
| Privacy policy URL | Legal-Advisor | 🔴 TODO |
| Terms of Service URL | Legal-Advisor | 🔴 TODO |
| IAP configured | Revenue-Engineer | 🔴 TODO |
| Age rating | Dev-Ops | 🔴 TODO |
| Categories | Dev-Ops | 🔴 TODO |
| Keywords | Dev-Ops | 🔴 TODO |
| Support URL | Dev-Ops | 🔴 TODO |

---

## Pricing Tiers (Reference)

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | 2 connections, 5GB/mo, manual sync |
| **Pro** | $9.99/mo or $99/yr | Unlimited, scheduled sync, encryption |
| **Team** | $19.99/user/mo | + Team management, SSO (future) |

---

## Post-Sprint: Launch Sequence

1. ✅ Submit to App Store Review
2. Publish landing page
3. Prepare launch announcement
4. Submit to Product Hunt
5. Social media posts
6. Monitor reviews & feedback
7. Iterate based on feedback

---

*Sprint planned by Strategic Partner*
*Goal: Ready for App Store submission*
