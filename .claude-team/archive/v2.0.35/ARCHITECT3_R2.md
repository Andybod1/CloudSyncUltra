# Integration Study: Cloudflare R2

**GitHub Issue:** #130
**Study Date:** 2026-01-17
**Author:** Architect-3
**Status:** COMPLETE

---

## 1. Overview and rclone Backend Details

### What is Cloudflare R2?

Cloudflare R2 is an S3-compatible object storage service that provides zero egress fees, making it an attractive option for applications with high data transfer requirements. It integrates natively with Cloudflare's global network and Workers platform.

### S3-Compatible API

Cloudflare R2 uses an **S3-compatible API**, which means rclone connects to it using the standard S3 backend (`type = s3`) with Cloudflare-specific configuration.

**rclone Backend Type:** `s3`
**rclone Provider:** `Cloudflare`

### Endpoint URL Format

```
https://<ACCOUNT_ID>.r2.cloudflarestorage.com
```

**Jurisdictional Endpoints (for compliance requirements):**
- EU: `https://<ACCOUNT_ID>.eu.r2.cloudflarestorage.com`
- FedRAMP: `https://<ACCOUNT_ID>.fedramp.r2.cloudflarestorage.com`

### Configuration Parameters

**Sample rclone.conf:**
```ini
[cloudflare_r2]
type = s3
provider = Cloudflare
access_key_id = YOUR_ACCESS_KEY_ID
secret_access_key = YOUR_SECRET_ACCESS_KEY
endpoint = https://<ACCOUNT_ID>.r2.cloudflarestorage.com
acl = private
region = auto
```

**Key Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `type` | Yes | Must be `s3` |
| `provider` | Yes | Set to `Cloudflare` |
| `access_key_id` | Yes | R2 API token Access Key ID |
| `secret_access_key` | Yes | R2 API token Secret Access Key |
| `endpoint` | Yes | Account-specific R2 endpoint URL |
| `region` | Yes | Set to `auto` |
| `acl` | Optional | Default: `private` |
| `no_check_bucket` | Optional | Set to `true` for object-level permission tokens |

---

## 2. Authentication Requirements

### R2 API Tokens

R2 uses S3-compatible authentication via API tokens that generate Access Key ID and Secret Access Key pairs.

### Creating API Tokens

1. Navigate to **Storage & databases > R2 Object storage > Overview** in the Cloudflare dashboard
2. Click **Manage** next to "API Tokens" in the Account Details section
3. Click **Create API Token**
4. Choose between:
   - **Account API token** - Scoped to the account
   - **User API token** - Scoped to the user
5. Set permissions to **Admin Read & Write** for full access
6. **CRITICAL:** Copy and save both the **Access Key ID** and **Secret Access Key** immediately - the secret is only shown once

### Account ID Requirements

The Account ID is required to construct the endpoint URL. Find it in:
- Cloudflare Dashboard > R2 > Overview page
- It's a 32-character hexadecimal string

### Token Permission Levels

| Permission | Access Level |
|------------|--------------|
| Admin Read & Write | Full bucket and object access |
| Object Read & Write | Object operations only (requires `no_check_bucket = true`) |
| Object Read Only | Read-only object access |

---

## 3. Key Features

### Zero Egress Fees (Major Selling Point)

This is R2's primary differentiator:

- **No egress charges** for data transferred out via:
  - S3 API
  - Workers API
  - r2.dev domains
  - Custom domains
- **Significant cost savings** compared to AWS S3, Google Cloud Storage, or Azure Blob

**Cost Comparison Example:**
- 10TB storage + 50TB egress/month
  - **R2:** ~$150 (storage only)
  - **AWS S3:** ~$4,730 (storage + egress)
  - **Google Cloud:** ~$5,200 (storage + egress)

### Storage Pricing

| Storage Class | Price | Notes |
|---------------|-------|-------|
| Standard | $0.015/GB-month | Frequently accessed data |
| Infrequent Access | Lower | 30-day minimum, retrieval fees |

### S3 Compatibility Level

R2 supports most S3 operations including:
- PUT/GET/DELETE objects
- Multipart uploads (up to 5TB objects)
- Presigned URLs
- Bucket lifecycle rules (as of 2025)
- Event notifications (beta)

### Cloudflare Workers Integration

R2 natively integrates with Cloudflare Workers:
- Bind R2 buckets directly to Workers
- Build custom authentication and access control
- Add caching with Cloudflare CDN
- Use custom domains for public bucket access
- Apply WAF rules and bot management

---

## 4. Known Limitations and Workarounds

### Object Size Limits

| Operation | Limit |
|-----------|-------|
| Maximum object size | ~5TB (5 TiB - 5 GiB) |
| Single PUT request | ~5GB (5 GiB - 5 MiB) |
| Workers upload (Free/Pro) | 100MB |
| Workers upload (Enterprise) | 500MB |

**Workaround:** Use multipart uploads via rclone for files > 5GB. rclone handles this automatically with `--s3-chunk-size` flag.

### Rate Limits

| Operation | Limit |
|-----------|-------|
| Bucket operations | 50/second |
| Concurrent writes per object | 1/second |
| r2.dev subdomain | "Hundreds per second" (not for production) |
| Cloudflare API (dashboard/management) | 1,200 requests/5 minutes |

**Note:** Object read/write operations via S3 API are not subject to the Cloudflare API rate limit.

### Missing S3 Features

| Feature | Status | Workaround |
|---------|--------|------------|
| S3 Object Lock | Not supported | Use application-level immutability |
| Complex lifecycle policies (Glacier tiers) | Limited | Use standard/IA tiers only |
| Cross-region replication | Not supported | Use Workers for custom replication |
| Server-side encryption with customer keys (SSE-C) | Not supported | Use client-side encryption (rclone crypt) |
| Bucket versioning | Limited support | - |
| S3 Select | Not supported | Process data client-side |

### Billing Quirks

Cloudflare rounds up usage:
- 1,000,001 operations billed as 2,000,000
- 1.1 GB-month billed as 2 GB-month

### rclone Version Requirement

**Minimum version:** rclone v1.59+

Earlier versions may return `HTTP 401: Unauthorized` errors due to S3 specification alignment issues.

---

## 5. Step-by-Step Connection Flow

### Step 1: Create R2 Bucket

1. Log in to Cloudflare Dashboard
2. Navigate to **R2 Object Storage**
3. Click **Create bucket**
4. Enter bucket name (must be unique within your account)
5. Select location hint (optional)
6. Click **Create bucket**

### Step 2: Generate API Token

1. Go to **R2 > Overview**
2. Copy your **Account ID** from the right sidebar
3. Click **Manage R2 API Tokens**
4. Click **Create API Token**
5. Name the token (e.g., "CloudSync Ultra")
6. Set permissions to **Admin Read & Write**
7. Click **Create**
8. **SAVE IMMEDIATELY:**
   - Access Key ID: `a1b2c3d4e5f6g7h8...`
   - Secret Access Key: `xYz789AbC...`

### Step 3: Configure rclone

**Interactive Setup:**
```bash
rclone config
# n) New remote
# Name: r2
# Storage: s3
# Provider: Cloudflare
# Access Key ID: <paste from step 2>
# Secret Access Key: <paste from step 2>
# Region: auto
# Endpoint: https://<ACCOUNT_ID>.r2.cloudflarestorage.com
```

**Manual Config (rclone.conf):**
```ini
[r2]
type = s3
provider = Cloudflare
access_key_id = YOUR_ACCESS_KEY_ID
secret_access_key = YOUR_SECRET_ACCESS_KEY
endpoint = https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com
region = auto
```

### Step 4: Test Connection

```bash
# List buckets
rclone lsd r2:

# List contents of a bucket
rclone ls r2:your-bucket-name

# Upload a test file
rclone copy test.txt r2:your-bucket-name/
```

---

## 6. Implementation Recommendation

### Difficulty Rating: EASY

R2 requires **no code changes** to CloudSync Ultra. The existing S3 backend support fully covers R2.

### Current Implementation Status

**CloudProvider.swift already includes R2:**
```swift
case .cloudflareR2: return "s3"  // Uses S3 backend
case .cloudflareR2: return "r2"  // Default rclone name
```

The codebase already:
- Defines `cloudflareR2` as a provider type
- Maps it to the S3 rclone backend
- Sets appropriate brand color (Cloudflare Orange: `#F87D1E`)
- Includes icon (`flame.fill`)
- Supports fast-list and multi-thread downloads

### Optimization Already Implemented

From `CloudProvider.swift`:
```swift
// Fast-list support for R2
case .cloudflareR2: return true  // supportsFastList

// Default parallelism (optimized for S3-compatible)
case .cloudflareR2:
    return (transfers: 16, checkers: 32)

// Multi-thread download support (full capability)
// R2 is listed in fullSupportProviders array
```

### Configuration UI Requirements

For the connection wizard, R2 requires three fields:

1. **Account ID** - Required for endpoint construction
2. **Access Key ID** - From R2 API token
3. **Secret Access Key** - From R2 API token

**Endpoint Auto-Construction:**
```swift
let endpoint = "https://\(accountId).r2.cloudflarestorage.com"
```

### Code Changes Needed

**None required for basic functionality.**

**Optional enhancements:**
1. Add dedicated R2 setup UI in `ProviderConnectionWizardView` to collect Account ID separately
2. Auto-construct endpoint URL from Account ID
3. Add jurisdiction selector (standard/EU/FedRAMP) for compliance-focused users

### rclone Configuration Generation

When configuring R2, generate this config:
```swift
let params: [String: String] = [
    "provider": "Cloudflare",
    "access_key_id": accessKeyId,
    "secret_access_key": secretAccessKey,
    "endpoint": "https://\(accountId).r2.cloudflarestorage.com",
    "region": "auto"
]

try await rcloneManager.createRemote(
    name: remoteName,
    type: "s3",
    parameters: params
)
```

---

## 7. Summary

| Aspect | Assessment |
|--------|------------|
| **Integration Difficulty** | EASY - Uses existing S3 backend |
| **Code Changes Required** | None (optional UI enhancements) |
| **rclone Support** | Full (v1.59+) |
| **Authentication** | S3-compatible API tokens |
| **Key Benefit** | Zero egress fees |
| **Primary Limitation** | Limited lifecycle policies |
| **Recommended For** | High-egress workloads, cost-conscious users |

### References

- [Rclone R2 Configuration - Cloudflare Docs](https://developers.cloudflare.com/r2/examples/rclone/)
- [R2 Authentication - Cloudflare Docs](https://developers.cloudflare.com/r2/api/tokens/)
- [R2 Pricing - Cloudflare Docs](https://developers.cloudflare.com/r2/pricing/)
- [R2 Limits - Cloudflare Docs](https://developers.cloudflare.com/r2/platform/limits/)
- [rclone S3 Documentation](https://rclone.org/s3/)

---

*Study completed by Architect-3 for CloudSync Ultra GitHub Issue #130*
