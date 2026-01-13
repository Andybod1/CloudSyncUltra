# iCloud Integration Plan (#9)

## Overview

Full iCloud Drive integration for CloudSync Ultra with two phases:
1. **Phase 1:** Quick local folder access (1 day)
2. **Phase 2:** Full rclone `iclouddrive` backend (1 week)

---

## Phase 1: Local iCloud Folder (Quick Win)

### Objective
Allow users to sync to/from their local iCloud Drive folder without authentication complexity.

### Implementation

#### 1.1 Fix rclone Type Mapping
```swift
// CloudProvider.swift - Fix rcloneType
case .icloud: return "iclouddrive"  // Was "icloud"
```

#### 1.2 Add Local iCloud Detection
```swift
// ICloudManager.swift (new file)
class ICloudManager {
    static let localPath = "~/Library/Mobile Documents/com~apple~CloudDocs/"
    
    static var isAvailable: Bool {
        let expandedPath = NSString(string: localPath).expandingTildeInPath
        return FileManager.default.fileExists(atPath: expandedPath)
    }
    
    static var expandedPath: String {
        NSString(string: localPath).expandingTildeInPath
    }
}
```

#### 1.3 Add "iCloud Drive (Local)" Provider Option
- Show only on macOS when iCloud folder exists
- Treat as local filesystem remote in rclone
- No authentication required

### Worker Assignment
| Task | Worker | Size |
|------|--------|------|
| Fix rclone type | Dev-3 | XS |
| ICloudManager | Dev-3 | XS |
| UI integration | Dev-1 | S |

### Acceptance Criteria
- [ ] rclone type fixed to `iclouddrive`
- [ ] Local iCloud folder detected automatically
- [ ] Users can browse/sync local iCloud Drive
- [ ] Works without any authentication

---

## Phase 2: Full rclone Integration

### Objective
Implement full `iclouddrive` rclone backend with Apple ID authentication and 2FA.

### Technical Requirements

#### 2.1 Authentication Flow
```
1. User enters Apple ID email
2. User enters password (NOT app-specific password)
3. rclone sends auth request to Apple
4. Apple sends 2FA code to user's trusted device
5. User enters 2FA code in CloudSync
6. rclone receives trust token (valid 30 days)
7. Store token securely in rclone config
```

#### 2.2 RcloneManager Changes
```swift
// RcloneManager.swift additions

func setupICloudDrive(remoteName: String, appleId: String, password: String) async throws {
    // Step 1: Initial config
    let configArgs = [
        "config", "create", remoteName, "iclouddrive",
        "apple_id", appleId,
        "password", password
    ]
    
    // This will prompt for 2FA - need interactive handling
    // ...
}

func handleICloud2FA(remoteName: String, code: String) async throws {
    // Send 2FA code to complete authentication
    // ...
}

func reconnectICloud(remoteName: String) async throws {
    // Re-authenticate when token expires
    let args = ["config", "reconnect", remoteName]
    // ...
}
```

#### 2.3 UI Components Needed

**ICloudSetupView.swift** (new)
```swift
struct ICloudSetupView: View {
    @State private var appleId: String = ""
    @State private var password: String = ""
    @State private var twoFactorCode: String = ""
    @State private var step: SetupStep = .credentials
    
    enum SetupStep {
        case credentials    // Enter Apple ID + password
        case twoFactor      // Enter 2FA code
        case complete       // Setup done
    }
    
    var body: some View {
        // Step-by-step wizard UI
    }
}
```

**ICloudStatusView.swift** (new)
- Show token expiry countdown
- "Re-authenticate" button
- ADP warning if detected

#### 2.4 Token Management
```swift
// ICloudTokenManager.swift (new)
class ICloudTokenManager {
    static let tokenValidityDays = 30
    
    func getTokenExpiry(for remoteName: String) -> Date? {
        // Read from rclone config
    }
    
    func shouldWarnAboutExpiry(for remoteName: String) -> Bool {
        // Warn 3 days before expiry
    }
    
    func scheduleExpiryNotification(for remoteName: String) {
        // Local notification when token about to expire
    }
}
```

#### 2.5 Error Handling
| Error | User Message |
|-------|--------------|
| Invalid credentials | "Apple ID or password incorrect" |
| 2FA timeout | "Verification code expired. Please try again." |
| ADP enabled | "Advanced Data Protection is enabled. Please disable it in iCloud settings to use iCloud Drive with CloudSync." |
| Token expired | "Your iCloud session has expired. Please re-authenticate." |
| Rate limited | "Too many attempts. Please wait and try again." |

### Worker Assignment
| Task | Worker | Size | Priority |
|------|--------|------|----------|
| RcloneManager iCloud methods | Dev-2 | M | 1 |
| ICloudSetupView UI | Dev-1 | M | 2 |
| ICloudTokenManager | Dev-3 | S | 3 |
| ICloudStatusView | Dev-1 | S | 4 |
| Error handling | Dev-2 | S | 5 |
| Unit tests | QA | M | 6 |
| Integration tests | QA | M | 7 |

### Acceptance Criteria
- [ ] Apple ID + password authentication works
- [ ] 2FA flow completes successfully
- [ ] Trust token stored and reused
- [ ] Token expiry warning shown
- [ ] Re-authentication flow works
- [ ] ADP detected and warning shown
- [ ] All error cases handled gracefully
- [ ] Tests pass

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Apple API changes | Medium | High | Monitor rclone issues, version lock |
| 2FA UX complexity | High | Medium | Clear step-by-step wizard |
| Token expiry confusion | Medium | Medium | Proactive notifications |
| ADP prevalence | Low | Medium | Clear messaging, local fallback |

---

## Timeline

### Phase 1 (1 day)
- Morning: Fix rclone type, create ICloudManager
- Afternoon: UI integration, testing

### Phase 2 (5-7 days)
- Day 1-2: RcloneManager iCloud methods + 2FA handling
- Day 3-4: ICloudSetupView wizard UI
- Day 5: Token management + notifications
- Day 6: Error handling + ADP detection
- Day 7: Testing + polish

---

## Sprint Recommendation

**Start Phase 1 immediately** - delivers value in 1 day.

**Phase 2 as separate sprint** - needs focused attention.

---

*Created: 2026-01-13*
*Ticket: #9*
