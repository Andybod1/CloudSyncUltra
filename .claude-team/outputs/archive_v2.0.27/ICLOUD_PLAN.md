# iCloud Integration Plan (#9)

## Overview

Full iCloud Drive integration for CloudSync Ultra with two phases:
- **Phase 1:** Quick local folder access (1 day)
- **Phase 2:** Full rclone iclouddrive backend (1 week)

---

## Phase 1: Local iCloud Folder (Quick Win)

### Objective
Allow users to sync TO/FROM their local iCloud Drive folder without authentication complexity.

### Implementation

#### 1.1 Fix rclone type mapping (Dev-3)
```swift
// CloudProvider.swift - change:
case .icloud: return "icloud"
// to:
case .icloud: return "iclouddrive"
```

#### 1.2 Add iCloud local folder detection (Dev-3)
```swift
// Add to CloudProvider or new ICloudManager
static let iCloudLocalPath = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")

static var isICloudAvailable: Bool {
    FileManager.default.fileExists(atPath: iCloudLocalPath.path)
}
```

#### 1.3 UI: "Use Local iCloud Folder" option (Dev-1)
- When user selects iCloud, show option: "Use Local Folder (Recommended)" vs "Connect via Apple ID"
- Local folder option creates a local-type remote pointing to iCloud path
- No authentication needed

### Acceptance Criteria Phase 1
- [ ] rclone type fixed to `iclouddrive`
- [ ] Local iCloud folder detected
- [ ] Users can browse/sync local iCloud folder
- [ ] Works on any Mac with iCloud enabled

---

## Phase 2: Full rclone Integration

### Objective
Full Apple ID authentication with 2FA for cloud-based iCloud access.

### Requirements from rclone docs
1. Apple ID (email)
2. Password (regular, NOT app-specific)
3. 2FA code from trusted device
4. Trust token (valid 30 days)
5. NOT compatible with Advanced Data Protection (ADP)

### Implementation

#### 2.1 Setup Flow UI (Dev-1)
```
Step 1: Enter Apple ID
  [apple_id@email.com]
  
Step 2: Enter Password
  [••••••••••]
  ⚠️ Use your regular iCloud password, not an app-specific password
  
Step 3: Two-Factor Authentication
  A code has been sent to your trusted Apple devices.
  Enter the 6-digit code: [______]
  
Step 4: Success!
  ✅ Connected to iCloud Drive
  ℹ️ You'll need to re-authenticate in 30 days
```

#### 2.2 RcloneManager.setupICloud() (Dev-2)
```swift
func setupICloud(remoteName: String, appleId: String, password: String, twoFactorCode: String) async throws {
    // 1. Create config with rclone config create
    // 2. Handle 2FA challenge
    // 3. Store trust token
    // 4. Verify connection
}
```

#### 2.3 Token Refresh Handling (Dev-3)
- Track token creation date
- Show warning 3 days before expiry
- Prompt user to re-authenticate
- Menu bar notification option

#### 2.4 ADP Detection (Dev-2)
- Detect "Advanced Data Protection" error
- Show clear message: "iCloud with ADP is not supported. Disable ADP or use Local Folder option."

#### 2.5 Error Handling (Dev-2)
- Invalid credentials
- 2FA timeout/wrong code
- Token expired
- ADP enabled
- Network issues

### Acceptance Criteria Phase 2
- [ ] Apple ID + password entry
- [ ] 2FA code flow works
- [ ] Trust token stored and tracked
- [ ] Token expiry warning (30 days)
- [ ] Re-authentication flow
- [ ] ADP detection and clear error message
- [ ] All error cases handled gracefully

---

## Worker Assignments

### Phase 1 Sprint (1 day)
| Task | Worker | Size |
|------|--------|------|
| Fix rclone type + local detection | Dev-3 | XS |
| Local folder UI option | Dev-1 | S |
| Test local iCloud sync | QA | S |

### Phase 2 Sprint (3-4 days)
| Task | Worker | Size |
|------|--------|------|
| Setup flow UI (multi-step) | Dev-1 | M |
| setupICloud() + error handling | Dev-2 | L |
| Token tracking + refresh | Dev-3 | M |
| Full integration tests | QA | M |

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| 2FA flow complexity | High | Test thoroughly, clear instructions |
| ADP users frustrated | Medium | Clear messaging, local folder alternative |
| Token expiry surprise | Medium | Proactive notifications |
| Apple changes API | Low | Monitor rclone updates |

---

## Test Plan

### Phase 1 Tests
1. Local iCloud folder detected on Mac with iCloud
2. Local iCloud folder not detected on Mac without iCloud
3. Can browse local iCloud contents
4. Can sync files to/from local iCloud

### Phase 2 Tests
1. Valid Apple ID + password + 2FA → success
2. Invalid password → clear error
3. Wrong 2FA code → retry prompt
4. ADP enabled → helpful error message
5. Token expires → re-auth prompt works
6. Cancel mid-flow → clean state

---

*Plan created: 2026-01-13*
*Ticket: #9*
