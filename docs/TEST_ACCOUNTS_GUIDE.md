# Cloud Provider Test Accounts Guide

## Overview

This guide helps create test accounts for validating CloudSync Ultra's 42 cloud providers.

---

## Using Claude Cowork for Account Creation

### Requirements
- Claude Max plan subscription
- Claude Desktop app for macOS
- Chrome browser connected to Cowork

### Setup
1. Open Claude Desktop → Switch to "Cowork" tab
2. Grant access to a folder for storing credentials
3. Connect Chrome via MCP

### Example Prompt
```
Create a test account for Dropbox:
1. Open https://www.dropbox.com/register
2. Fill in: email: test+dropbox@mydomain.com, name: CloudSync Test
3. Use password from my password manager
4. Save the credentials to ~/CloudSync-Test-Accounts/dropbox.txt
```

### Limitations
- **CAPTCHA:** Many services have CAPTCHA - Cowork cannot solve these
- **Email verification:** You'll need to manually verify emails
- **Phone verification:** Cannot be automated

---

## Provider Categories

### Tier 1: Easy to Automate (No CAPTCHA typically)
| Provider | Signup URL | Notes |
|----------|-----------|-------|
| Backblaze B2 | https://www.backblaze.com/b2/sign-up.html | Free 10GB |
| Wasabi | https://console.wasabisys.com/signup | Free trial |
| DigitalOcean Spaces | https://cloud.digitalocean.com/registrations/new | $200 credit |

### Tier 2: Manual Signup Required (CAPTCHA/Phone)
| Provider | Signup URL | Notes |
|----------|-----------|-------|
| Google Drive | https://accounts.google.com/signup | Phone required |
| Dropbox | https://www.dropbox.com/register | CAPTCHA |
| OneDrive | https://signup.live.com | Phone required |
| Box | https://account.box.com/signup | Business email needed |
| pCloud | https://www.pcloud.com/cloud-storage-pricing-plans.html | - |

### Tier 3: Already Have / Easy Access
| Provider | Notes |
|----------|-------|
| Local filesystem | No account needed |
| SFTP | Use local server |
| WebDAV | Use local server |
| FTP | Use local server |

### Tier 4: Requires Payment/Business
| Provider | Notes |
|----------|-------|
| AWS S3 | Credit card required |
| Azure Blob | Credit card required |
| Google Cloud Storage | Credit card required |

---

## Recommended Test Account Email Pattern

Use email aliases: `yourmail+providername@gmail.com`

Examples:
- `andy+dropbox@gmail.com`
- `andy+gdrive@gmail.com`  
- `andy+onedrive@gmail.com`

---

## Credential Storage

Store test credentials securely:

```
~/CloudSync-Test-Accounts/
├── dropbox.txt
├── gdrive.txt
├── onedrive.txt
└── ...
```

Format for each file:
```
Provider: Dropbox
Email: test+dropbox@example.com
Password: [stored in password manager]
Created: 2026-01-13
OAuth Token: [managed by rclone]
```

---

## Testing Checklist

For each provider, verify:
- [ ] Account created
- [ ] OAuth/login works in CloudSync
- [ ] Can list files
- [ ] Can upload file
- [ ] Can download file
- [ ] Can delete file

---

## Quick Commands

### Add remote to rclone interactively
```bash
rclone config
```

### Test connection
```bash
rclone lsd remotename:
```

### List all configured remotes
```bash
rclone listremotes
```

---

*Last updated: 2026-01-13*
*Ticket: #31*
