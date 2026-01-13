# Cloud Provider Test Accounts Checklist (#31)

## Overview

This document lists all 42 cloud providers supported by CloudSync Ultra with signup URLs and automation notes for creating test accounts.

---

## Using Claude Cowork for Account Creation

### Requirements
- Claude Desktop app (macOS)
- Max plan subscription
- Chrome browser connected to Cowork

### Steps
1. Open Claude Desktop → Switch to Cowork mode
2. Connect Chrome browser access
3. Prompt: "Create a test account at [URL] using email test+[provider]@yourdomain.com"
4. Monitor Claude's progress
5. Save credentials securely

### Limitations
- CAPTCHA-protected sites require manual intervention
- Some providers need phone verification
- Business/enterprise accounts usually need manual signup

---

## Provider Checklist

### Tier 1: Major Providers (Priority)
| # | Provider | URL | CAPTCHA | Phone | Cowork? | Status |
|---|----------|-----|---------|-------|---------|--------|
| 1 | Google Drive | https://accounts.google.com/signup | Yes | Yes | ❌ Manual | ⬜ |
| 2 | Dropbox | https://www.dropbox.com/register | Yes | No | ⚠️ Maybe | ⬜ |
| 3 | OneDrive | https://signup.live.com | Yes | Yes | ❌ Manual | ⬜ |
| 4 | iCloud | https://appleid.apple.com | Yes | Yes | ❌ Manual | ⬜ |
| 5 | Amazon S3 | https://aws.amazon.com/s3/ | Yes | Yes | ❌ Manual | ⬜ |
| 6 | Proton Drive | https://proton.me/drive | No | No | ✅ Try | ⬜ |

### Tier 2: Popular Services
| # | Provider | URL | CAPTCHA | Phone | Cowork? | Status |
|---|----------|-----|---------|-------|---------|--------|
| 7 | Box | https://account.box.com/signup | Yes | No | ⚠️ Maybe | ⬜ |
| 8 | pCloud | https://www.pcloud.com/sign-up | No | No | ✅ Try | ⬜ |
| 9 | MEGA | https://mega.nz/register | Yes | No | ⚠️ Maybe | ⬜ |
| 10 | Backblaze B2 | https://www.backblaze.com/sign-up | No | No | ✅ Try | ⬜ |
| 11 | Wasabi | https://console.wasabisys.com/signup | No | No | ✅ Try | ⬜ |
| 12 | Cloudflare R2 | https://dash.cloudflare.com/sign-up | Yes | No | ⚠️ Maybe | ⬜ |

### Tier 3: Regional/Specialized
| # | Provider | URL | Cowork? | Status |
|---|----------|-----|---------|--------|
| 13 | Yandex Disk | https://passport.yandex.com/registration | ⚠️ Maybe | ⬜ |
| 14 | Mail.ru | https://account.mail.ru/signup | ⚠️ Maybe | ⬜ |
| 15 | Jottacloud | https://www.jottacloud.com/signup | ✅ Try | ⬜ |
| 16 | Koofr | https://app.koofr.net/register | ✅ Try | ⬜ |
| 17 | HiDrive | https://www.strato.de/cloud-speicher/ | ⚠️ Maybe | ⬜ |
| 18 | 1Fichier | https://1fichier.com/register.pl | ✅ Try | ⬜ |
| 19 | put.io | https://put.io/plans | ❌ Paid | ⬜ |
| 20 | Premiumize | https://www.premiumize.me/register | ❌ Paid | ⬜ |

### Tier 4: Enterprise/Self-Hosted
| # | Provider | URL | Notes | Status |
|---|----------|-----|-------|--------|
| 21 | Nextcloud | Self-hosted | Need server | ⬜ |
| 22 | ownCloud | Self-hosted | Need server | ⬜ |
| 23 | Seafile | Self-hosted | Need server | ⬜ |
| 24 | MinIO | Self-hosted | Need server | ⬜ |

### Tier 5: Protocol-Based (No Account Needed)
| # | Provider | Notes | Status |
|---|----------|-------|--------|
| 25 | WebDAV | Use any WebDAV server | ⬜ |
| 26 | SFTP | Use any SSH server | ⬜ |
| 27 | FTP | Use any FTP server | ⬜ |
| 28 | SMB | Use any Windows share | ⬜ |
| 29 | HTTP | Any web server | ⬜ |

### Tier 6: Additional S3-Compatible
| # | Provider | URL | Cowork? | Status |
|---|----------|-----|---------|--------|
| 30 | DigitalOcean Spaces | https://cloud.digitalocean.com/registrations/new | ⚠️ Maybe | ⬜ |
| 31 | Linode Object Storage | https://login.linode.com/signup | ⚠️ Maybe | ⬜ |
| 32 | Scaleway | https://console.scaleway.com/register | ⚠️ Maybe | ⬜ |
| 33 | OVH Object Storage | https://www.ovhcloud.com/en/lp/sign-up/ | ⚠️ Maybe | ⬜ |
| 34 | IBM Cloud | https://cloud.ibm.com/registration | ⚠️ Maybe | ⬜ |
| 35 | Oracle Cloud | https://signup.cloud.oracle.com | ⚠️ Maybe | ⬜ |

### Tier 7: Other Providers
| # | Provider | URL | Status |
|---|----------|-----|--------|
| 36 | Azure Blob | https://azure.microsoft.com/free/ | ⬜ |
| 37 | Google Cloud Storage | https://cloud.google.com/free | ⬜ |
| 38 | Storj | https://www.storj.io/signup | ⬜ |
| 39 | Tardigrade | https://www.storj.io/signup | ⬜ |
| 40 | Ceph | Self-hosted | ⬜ |
| 41 | Swift | OpenStack service | ⬜ |
| 42 | Hubic | Discontinued | N/A |

---

## Recommended Test Priority

### Must Test (Core Experience)
1. ✅ Proton Drive (already configured)
2. Dropbox
3. Google Drive  
4. OneDrive
5. Amazon S3

### Should Test (Popular)
6. Box
7. pCloud
8. MEGA
9. Backblaze B2

### Nice to Test (Validation)
10. WebDAV (generic)
11. SFTP (generic)
12. One regional provider

---

## Credential Storage

**DO NOT** store real passwords in this file.

Use a password manager:
- 1Password
- Bitwarden
- macOS Keychain

---

*Created: 2026-01-13*
*Ticket: #31*
