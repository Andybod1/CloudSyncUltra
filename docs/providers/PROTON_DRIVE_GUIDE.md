# Proton Drive Integration Guide

## Overview

CloudSync Ultra v2.0 includes full support for Proton Drive, Proton's end-to-end encrypted cloud storage service. This integration uses rclone's `protondrive` backend with secure credential storage in macOS Keychain.

## Prerequisites

Before connecting CloudSync Ultra to Proton Drive, you must:

1. **Have a Proton account** with Proton Drive enabled
2. **Log in via the web browser** at least once to generate encryption keys
3. **Have your authenticator app ready** if you have 2FA enabled

> ⚠️ **Important**: The encryption keys are only generated when you first log in via the web interface. Attempting to connect without this step will fail.

## Authentication Methods

### Basic Authentication (No 2FA)

If your account doesn't have two-factor authentication:
- Enter your Proton email address
- Enter your account password

### Two-Factor Authentication

CloudSync Ultra supports two methods for 2FA:

#### Option 1: Single Code (Temporary)
- Enter the 6-digit code from your authenticator app
- ⚠️ This code expires, and you may need to re-authenticate when the session ends

#### Option 2: TOTP Secret (Recommended)
- Enter your TOTP secret key (the Base32 code you got when setting up 2FA)
- This allows CloudSync Ultra to automatically generate codes
- No need to re-enter codes when the session refreshes

### Two-Password Accounts

If you use Proton's two-password mode (separate login and mailbox passwords):
- Enter both passwords in the Advanced Options section

## Setup Steps

1. Open **Settings** → **Accounts**
2. Select **Proton Drive** from the list
3. Click **Open Setup Wizard**
4. Complete the prerequisites check
5. Enter your credentials
6. Choose your 2FA method (if applicable)
7. Click **Test Connection** to verify
8. Click **Connect** to save

## Credential Storage & Auto-Reconnect

### Secure Keychain Storage

CloudSync Ultra securely stores your Proton Drive credentials in the macOS Keychain:

- **Username**: Stored for display and reconnection
- **Password**: Encrypted in Keychain (never stored in plain text)
- **TOTP Secret**: Stored securely for automatic 2FA code generation
- **Mailbox Password**: Stored for two-password accounts

### Auto-Reconnect Feature

When your session expires or the app restarts:

1. CloudSync detects saved credentials in Keychain
2. Shows "Saved Credentials Found" with your username
3. Click **Reconnect** for one-click authentication
4. If using TOTP Secret, 2FA codes are generated automatically

### Managing Saved Credentials

| Action | What Happens |
|--------|--------------|
| **Reconnect** | Uses saved credentials to re-authenticate |
| **Disconnect** | Removes rclone config AND clears Keychain |
| **Disconnect (Keep Credentials)** | Removes rclone config, keeps Keychain data |

### Keychain Security

- Uses `kSecAttrAccessibleWhenUnlocked` - only accessible when Mac is unlocked
- Stored in app-specific Keychain space
- Protected by macOS Keychain Services (Secure Enclave on Apple Silicon)
- Never transmitted over network - only used locally

## Troubleshooting

### "Encryption keys not found"
- Log in to [Proton Drive Web](https://drive.proton.me) first
- This generates the required encryption keys

### "Invalid password"
- Double-check your password
- If you have a two-password account, try entering the mailbox password

### "Two-factor authentication required"
- Your account has 2FA enabled
- Choose either "Single Code" or "TOTP Secret" mode

### "Session expired"
- Your authentication session has expired
- Click **Reconnect** if you have saved credentials
- Or re-connect using the setup wizard
- Consider using TOTP Secret for persistent authentication

### "No saved credentials found"
- You haven't connected Proton Drive before
- Or credentials were cleared on disconnect
- Use the setup wizard to connect

### "Too many requests"
- Wait a few minutes before trying again
- Proton has rate limiting to protect accounts

## Technical Details

### rclone Configuration

CloudSync Ultra creates an rclone remote with these settings:
- Type: `protondrive`
- Password: Obscured using `rclone obscure`
- `replace_existing_draft`: `true` (handles interrupted uploads)
- `enable_caching`: `true` (improves performance)

### Config File Location

The rclone configuration is stored at:
```
~/Library/Application Support/CloudSyncApp/rclone.conf
```

### Keychain Storage

Credentials are stored in the macOS Keychain with:
- Service: `com.cloudsync.app` (or bundle identifier)
- Account: `proton_drive_credentials`
- Data: JSON-encoded `ProtonDriveCredentials` struct

### Supported Operations

| Operation | Supported |
|-----------|-----------|
| List files | ✅ |
| Upload | ✅ |
| Download | ✅ |
| Delete | ✅ |
| Rename/Move | ✅ |
| Create folder | ✅ |
| Bi-directional sync | ✅ |
| E2E encryption (app-level) | ✅ |
| Keychain credential storage | ✅ |
| Auto-reconnect with TOTP | ✅ |

## Security Notes

1. **Keychain Storage**: Credentials are stored in macOS Keychain, not in files
2. **Password Obscuring**: Passwords are obscured before being written to rclone config
3. **Proton E2E Encryption**: Proton Drive itself provides end-to-end encryption
4. **Additional Encryption**: You can add CloudSync Ultra's encryption layer on top
5. **No Plain Text**: Passwords are never stored in plain text or UserDefaults

## API Reference

### ProtonDriveManager

```swift
// Check connection state
ProtonDriveManager.shared.connectionState  // .connected, .disconnected, etc.

// Check for saved credentials
ProtonDriveManager.shared.hasSavedCredentials  // Bool

// Get saved username (for display)
ProtonDriveManager.shared.getSavedUsername()  // String?

// Reconnect using saved credentials
try await ProtonDriveManager.shared.reconnect()

// Disconnect and optionally clear credentials
await ProtonDriveManager.shared.disconnect(clearCredentials: true)
```

### KeychainManager

```swift
// Save Proton credentials
try KeychainManager.shared.saveProtonCredentials(
    username: "user@proton.me",
    password: "password",
    otpSecretKey: "TOTP_SECRET",      // Optional
    mailboxPassword: "mailbox_pass"    // Optional
)

// Check if credentials exist
KeychainManager.shared.hasProtonCredentials  // Bool

// Get credentials
let creds = try KeychainManager.shared.getProtonCredentials()

// Delete credentials
try KeychainManager.shared.deleteProtonCredentials()
```

## Version Requirements

- rclone: v1.62.0 or later (protondrive backend was added in v1.62.0)
- macOS: 14.0 (Sonoma) or later
- CloudSync Ultra: 2.0.0 or later
