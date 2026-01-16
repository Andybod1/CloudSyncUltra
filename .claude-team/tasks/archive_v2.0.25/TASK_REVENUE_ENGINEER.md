# TASK: StoreKit 2 Subscriptions (#46)

## Ticket
**GitHub:** #46
**Type:** Feature - Revenue/IAP
**Size:** L (2-3 hours)
**Priority:** Critical (revenue enablement)

---

## Objective

Implement StoreKit 2 subscription system with Free/Pro/Team tiers enabling monetization of CloudSync Ultra.

---

## Pricing Tiers

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | 2 connections, 5GB/mo transfer, manual sync |
| **Pro** | $9.99/mo or $99/yr | Unlimited connections, scheduled sync, encryption |
| **Team** | $19.99/user/mo | + Team management (future), SSO (future) |

**Reference:** `.claude-team/outputs/PRODUCT_MANAGER_COMPLETE.md`

---

## Implementation

### 1. SubscriptionTier Model

Create `CloudSyncApp/Models/SubscriptionTier.swift`:

```swift
enum SubscriptionTier: String, Codable {
    case free
    case pro
    case team
    
    var connectionLimit: Int? {
        switch self {
        case .free: return 2
        case .pro, .team: return nil // unlimited
        }
    }
    
    var transferLimitGB: Int? {
        switch self {
        case .free: return 5
        case .pro, .team: return nil
        }
    }
    
    var hasScheduledSync: Bool {
        self != .free
    }
    
    var hasEncryption: Bool {
        self != .free
    }
}
```

### 2. StoreKitManager

Create `CloudSyncApp/Managers/StoreKitManager.swift`:

```swift
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var currentTier: SubscriptionTier = .free
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    // Product IDs (configure in App Store Connect)
    private let productIDs = [
        "com.cloudsync.pro.monthly",
        "com.cloudsync.pro.yearly",
        "com.cloudsync.team.monthly"
    ]
    
    func loadProducts() async
    func purchase(_ product: Product) async throws
    func restorePurchases() async
    func updateSubscriptionStatus() async
}
```

### 3. PaywallView

Create `CloudSyncApp/Views/PaywallView.swift`:

- Show tier comparison
- Price display
- Purchase buttons
- Restore purchases link
- Terms of Service link

### 4. Feature Gating

Add checks throughout app:

```swift
// In RemotesViewModel
func addRemote() {
    guard StoreKitManager.shared.canAddRemote else {
        showPaywall = true
        return
    }
    // ... proceed
}

// Extension on StoreKitManager
var canAddRemote: Bool {
    guard let limit = currentTier.connectionLimit else { return true }
    return remoteCount < limit
}
```

### 5. StoreKit Configuration (Testing)

Create `CloudSyncApp/Configuration.storekit` for Xcode testing:
- Define product IDs
- Set prices
- Configure subscription groups

---

## Files to Create

| File | Purpose |
|------|---------|
| `Models/SubscriptionTier.swift` | Tier definitions and limits |
| `Managers/StoreKitManager.swift` | StoreKit 2 implementation |
| `Views/PaywallView.swift` | Upgrade/purchase UI |
| `Views/SubscriptionView.swift` | Manage subscription |
| `Configuration.storekit` | Xcode testing config |

---

## Files to Modify

| File | Changes |
|------|---------|
| `CloudSyncAppApp.swift` | Initialize StoreKitManager |
| `SettingsView.swift` | Add subscription section |
| `RemotesViewModel.swift` | Feature gating |
| `SyncManager.swift` | Schedule gating |
| `EncryptionManager.swift` | Encryption gating |

---

## StoreKit 2 Key APIs

```swift
// Load products
let products = try await Product.products(for: productIDs)

// Purchase
let result = try await product.purchase()

// Check entitlements
for await result in Transaction.currentEntitlements {
    // Handle active subscriptions
}

// Listen for updates
for await update in Transaction.updates {
    // Handle subscription changes
}
```

---

## App Store Connect Setup (Reference)

1. Create subscription group "CloudSync Ultra"
2. Add products:
   - `com.cloudsync.pro.monthly` - $9.99
   - `com.cloudsync.pro.yearly` - $99.00
   - `com.cloudsync.team.monthly` - $19.99
3. Configure subscription durations
4. Set up offer codes (optional)

---

## Testing Checklist

- [ ] Products load correctly
- [ ] Purchase flow works (sandbox)
- [ ] Subscription status updates
- [ ] Feature gating enforced
- [ ] Restore purchases works
- [ ] Expiration handling correct
- [ ] Receipt validation (if server-side)

---

## Acceptance Criteria

- [ ] SubscriptionTier model complete
- [ ] StoreKitManager handles all IAP
- [ ] PaywallView displays tiers
- [ ] Purchase flow works in sandbox
- [ ] Restore purchases functional
- [ ] Feature gating in place
- [ ] Tests written (coordinate with QA)
- [ ] Xcode StoreKit config for testing

---

## Notes

- Use /think hard for architecture decisions
- StoreKit 2 is async/await based
- No server required for basic validation
- Consider App Store Server API for advanced features

---

*Task created: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready"*
