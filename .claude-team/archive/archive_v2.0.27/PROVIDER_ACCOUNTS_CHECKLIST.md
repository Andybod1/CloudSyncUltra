# Cloud Provider Test Account Checklist (#31)

## Purpose

Document for creating test accounts across CloudSync Ultra's 42 supported providers.

## Automation Option: Claude Cowork

Claude Cowork can assist with account creation via Chrome:
1. Open Claude Desktop (Max plan required)
2. Switch to Cowork mode
3. Give Chrome access
4. Prompt: "Help me create accounts for cloud storage testing. Start with [provider]. Open the signup page and guide me through the process."

**Note:** CAPTCHA-protected services will require manual completion.

---

## Provider Account Checklist

### Tier 1: OAuth Providers (Easy Setup)
| Provider | URL | CAPTCHA | Account Created | Tested |
|----------|-----|---------|-----------------|--------|
| Google Drive | drive.google.com | Yes | ⬜ | ⬜ |
| Dropbox | dropbox.com | Yes | ⬜ | ⬜ |
| OneDrive | onedrive.com | Yes | ⬜ | ⬜ |
| Box | box.com | Yes | ⬜ | ⬜ |
| Zoho WorkDrive | zoho.com/workdrive | Yes | ⬜ | ⬜ |
| pCloud | pcloud.com | No | ⬜ | ⬜ |
| Yandex Disk | disk.yandex.com | Yes | ⬜ | ⬜ |
| Mail.ru Cloud | cloud.mail.ru | Yes | ⬜ | ⬜ |
| Jottacloud | jottacloud.com | No | ⬜ | ⬜ |
| HiDrive | hidrive.com | No | ⬜ | ⬜ |
| OpenDrive | opendrive.com | No | ⬜ | ⬜ |
| put.io | put.io | No | ⬜ | ⬜ |
| Pikpak | pikpak.com | Yes | ⬜ | ⬜ |
| Quatrix | quatrix.it | No | ⬜ | ⬜ |
| Linkbox | linkbox.to | No | ⬜ | ⬜ |
| Gofile | gofile.io | No | ⬜ | ⬜ |
| ImageKit | imagekit.io | No | ⬜ | ⬜ |
| Icedrive | icedrive.net | No | ⬜ | ⬜ |
| Koofr | koofr.eu | No | ⬜ | ⬜ |

### Tier 2: Privacy-Focused (Encryption)
| Provider | URL | CAPTCHA | Account Created | Tested |
|----------|-----|---------|-----------------|--------|
| Proton Drive | proton.me/drive | Yes | ⬜ | ⬜ |

### Tier 3: Enterprise/S3-Compatible
| Provider | URL | Free Tier | Account Created | Tested |
|----------|-----|-----------|-----------------|--------|
| Amazon S3 | aws.amazon.com | Yes (12mo) | ⬜ | ⬜ |
| Backblaze B2 | backblaze.com | Yes (10GB) | ⬜ | ⬜ |
| Wasabi | wasabi.com | Trial | ⬜ | ⬜ |
| DigitalOcean Spaces | digitalocean.com | Trial | ⬜ | ⬜ |
| Cloudflare R2 | cloudflare.com | Yes (10GB) | ⬜ | ⬜ |
| IDrive e2 | idrive.com/e2 | Yes (10GB) | ⬜ | ⬜ |
| Linode Object Storage | linode.com | Trial | ⬜ | ⬜ |
| Scaleway | scaleway.com | Yes (75GB) | ⬜ | ⬜ |
| OVH Object Storage | ovhcloud.com | Trial | ⬜ | ⬜ |
| IBM Cloud Object Storage | ibm.com/cloud | Trial | ⬜ | ⬜ |
| Oracle Cloud Infrastructure | oracle.com/cloud | Yes | ⬜ | ⬜ |
| Alibaba Cloud OSS | alibabacloud.com | Trial | ⬜ | ⬜ |
| Tencent Cloud COS | cloud.tencent.com | Trial | ⬜ | ⬜ |
| Storj | storj.io | Yes (25GB) | ⬜ | ⬜ |
| Filebase | filebase.com | Yes (5GB) | ⬜ | ⬜ |

### Tier 4: Protocol-Based (FTP/SFTP/WebDAV)
| Provider | URL | Notes | Account Created | Tested |
|----------|-----|-------|-----------------|--------|
| SFTP | N/A | Use any Linux server | ⬜ | ⬜ |
| FTP | N/A | Use any FTP server | ⬜ | ⬜ |
| WebDAV | N/A | Various providers | ⬜ | ⬜ |
| Nextcloud | nextcloud.com | Self-hosted or demo | ⬜ | ⬜ |
| ownCloud | owncloud.com | Self-hosted or demo | ⬜ | ⬜ |

### Tier 5: Specialized
| Provider | URL | Notes | Account Created | Tested |
|----------|-----|-------|-----------------|--------|
| Mega | mega.nz | 20GB free | ⬜ | ⬜ |
| Seafile | seafile.com | Self-hosted | ⬜ | ⬜ |
| Crypt | N/A | Built-in encryption | ⬜ | ⬜ |
| Local | N/A | Local filesystem | ✅ | ⬜ |

---

## Cowork Prompts for Account Creation

### Basic Prompt
```
Help me create a test account for [PROVIDER]. 
1. Open [URL] in Chrome
2. Navigate to the signup page
3. Guide me through creating a free account
4. I'll handle any CAPTCHA manually
```

### Batch Prompt
```
I need to create test accounts for cloud storage testing. Here's my list of providers without CAPTCHA:
- pCloud
- Jottacloud  
- OpenDrive

For each one:
1. Open the signup page
2. Use test email: cloudsync.test+[provider]@gmail.com
3. Generate a secure password and save it
4. Complete signup
5. Save credentials to a file

Skip any that require CAPTCHA - I'll do those manually.
```

---

## Progress Tracking

- Total Providers: 42
- Accounts Created: 0
- Accounts Tested: 0
- Coverage: 0%

---

*Created: 2026-01-13*
*Ticket: #31*
