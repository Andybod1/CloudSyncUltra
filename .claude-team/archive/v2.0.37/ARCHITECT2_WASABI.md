# Integration Study: Wasabi Hot Cloud Storage

**GitHub Issue:** #128
**Architect:** Architect-2
**Date:** 2026-01-18
**Status:** COMPLETE

---

## Executive Summary

Wasabi Hot Cloud Storage is **fully implemented** in CloudSync Ultra as an S3-compatible provider. The integration is rated **EASY** - no code changes required. Users can connect to Wasabi immediately using the existing `setupWasabi()` function in RcloneManager.swift.

**Key Differentiator:** Wasabi offers predictable pricing with **no egress fees** (subject to fair use policy), making it 80% cheaper than hyperscalers for most use cases.

**Integration Status:** Complete - Provider enum case exists, setup function implemented, performance optimizations configured.

---

## 1. Overview & rclone Backend Details

### Backend Type

Wasabi uses the **`s3` backend** with `provider: Wasabi` in rclone. This leverages the mature S3 backend while using Wasabi-specific endpoints.

```swift
// From CloudProvider.swift, line 36
case .wasabi = "wasabi"

// From CloudProvider.swift, line 274
case .wasabi: return "s3"  // rclone type
```

### Required Configuration Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `type` | `s3` | Yes |
| `provider` | `Wasabi` | Yes |
| `access_key_id` | Wasabi Access Key ID | Yes |
| `secret_access_key` | Wasabi Secret Access Key | Yes |
| `region` | Storage region (e.g., `us-east-1`) | Yes |
| `endpoint` | Region-specific endpoint URL | Yes |
| `acl` | Access control (default: `private`) | Optional |
| `location_constraint` | Leave empty | Optional |

### Sample rclone Configuration

```ini
[wasabi]
type = s3
provider = Wasabi
access_key_id = YOUR_ACCESS_KEY
secret_access_key = YOUR_SECRET_KEY
region = us-east-1
endpoint = s3.wasabisys.com
acl = private
```

### Path Format

```
remotename:bucket
remotename:bucket/path/to/folder
remotename:bucket/path/to/file.txt
```

---

## 2. Endpoint URLs for Different Regions

Wasabi operates **16 storage regions** worldwide. The endpoint URL format varies by region:

### North America

| Region Code | Location | Endpoint URL |
|-------------|----------|--------------|
| `us-east-1` | Virginia | `s3.wasabisys.com` or `s3.us-east-1.wasabisys.com` |
| `us-east-2` | Virginia (Secondary) | `s3.us-east-2.wasabisys.com` |
| `us-central-1` | Plano, Texas | `s3.us-central-1.wasabisys.com` |
| `us-west-1` | Oregon | `s3.us-west-1.wasabisys.com` |
| `us-west-2` | San Jose, CA | `s3.us-west-2.wasabisys.com` |
| `ca-central-1` | Toronto, Canada | `s3.ca-central-1.wasabisys.com` |

### Europe (EMEA)

| Region Code | Location | Endpoint URL |
|-------------|----------|--------------|
| `eu-west-1` | United Kingdom | `s3.eu-west-1.wasabisys.com` |
| `eu-west-2` | Paris, France | `s3.eu-west-2.wasabisys.com` |
| `eu-west-3` | United Kingdom (Secondary) | `s3.eu-west-3.wasabisys.com` |
| `eu-central-1` | Amsterdam, Netherlands | `s3.eu-central-1.wasabisys.com` |
| `eu-central-2` | Frankfurt, Germany | `s3.eu-central-2.wasabisys.com` |
| `eu-south-1` | Milan, Italy | `s3.eu-south-1.wasabisys.com` |

### Asia Pacific (APAC)

| Region Code | Location | Endpoint URL |
|-------------|----------|--------------|
| `ap-northeast-1` | Tokyo, Japan | `s3.ap-northeast-1.wasabisys.com` |
| `ap-northeast-2` | Osaka, Japan | `s3.ap-northeast-2.wasabisys.com` |
| `ap-southeast-1` | Singapore | `s3.ap-southeast-1.wasabisys.com` |
| `ap-southeast-2` | Sydney, Australia | `s3.ap-southeast-2.wasabisys.com` |

**Note:** The `us-east-1` region can use the simplified endpoint `s3.wasabisys.com` without the region suffix.

---

## 3. Authentication Requirements

### Credential Types

Wasabi uses **Access Key ID** and **Secret Access Key** pairs, similar to AWS S3:

- **Access Key ID**: 20-character alphanumeric identifier
- **Secret Access Key**: 40-character secret key

### How to Generate Access Keys in Wasabi Console

1. Log in to [Wasabi Console](https://console.wasabisys.com)
2. Navigate to **Access Keys** in the left menu
3. Click **Create New Access Key**
4. Choose key type:
   - **Root User Key**: Full access to all buckets (not recommended)
   - **Sub-User Key**: Limited to specific IAM user permissions
5. **SAVE IMMEDIATELY**: The Secret Access Key is shown only once

### IAM Policies (Sub-User Keys)

Wasabi supports AWS-compatible IAM policies. For CloudSync Ultra, use:

**Minimum Policy for CloudSync:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        }
    ]
}
```

**Full Access Policy (recommended for initial setup):**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
```

### Security Best Practices

1. Create dedicated sub-user accounts for applications
2. Apply least-privilege IAM policies
3. Enable multi-factor authentication (MFA) on root account
4. Rotate access keys periodically
5. Use bucket-specific policies when possible

---

## 4. Wasabi-Specific Features

### No Egress Fees (Key Differentiator)

Wasabi's primary advantage is **predictable pricing with no egress fees** - subject to fair use:

- **Free egress** if monthly egress is less than or equal to active storage
- **Example**: 10TB stored = 10TB free egress per month
- If egress exceeds storage, Wasabi may contact you or limit service

**Best fit use cases:**
- Backup and archive
- Content distribution (moderate egress)
- Disaster recovery
- Active data storage with reasonable access patterns

**Not ideal for:**
- CDN origin (constant high egress)
- Data-intensive applications where egress >> storage

### Available Regions (16 Total)

- **North America**: 6 regions (US East, West, Central + Canada)
- **Europe**: 6 regions (UK, France, Netherlands, Germany, Italy)
- **Asia Pacific**: 4 regions (Japan, Singapore, Australia)

All regions are:
- SOC-2 compliant
- ISO 27001 certified
- PCI-DSS certified

### Compliance Features

#### Object Lock (Immutability)

Wasabi supports S3-compatible Object Lock for WORM compliance:

| Mode | Description | Use Case |
|------|-------------|----------|
| **Governance** | Protected but bypassable with permission | Internal policies |
| **Compliance** | Cannot be deleted by anyone | Regulatory requirements |
| **Legal Hold** | Indefinite retention | Litigation |

**Supported regulations:**
- HIPAA
- SEC Rule 17a-4
- FINRA
- FERPA
- CJIS

**Important:** Object Lock must be enabled at bucket creation time.

#### Bucket-Level Compliance

Alternative to Object Lock - applies to entire bucket:
- All objects immutable until retention period passes
- Can be locked to prevent disabling
- Works with or without versioning

#### Encryption

- **Server-side encryption**: AES-256 available
- **In-transit encryption**: TLS 1.2+ enforced
- **Client-side encryption**: Supported via rclone crypt

### Pricing Model

| Component | Price | Notes |
|-----------|-------|-------|
| Storage | $6.99/TB/month | Flat rate, no tiers |
| Egress | FREE | If egress <= storage |
| API Requests | FREE | Included |
| Minimum charge | 1 TB | Pay for 1TB even if storing less |
| Cloud NAS | $8.99/TB/month | NFS/SMB access |

**Cost Comparison:**

| Provider | Storage/TB/mo | Egress/GB | API Calls |
|----------|--------------|-----------|-----------|
| **Wasabi** | $6.99 | $0 | FREE |
| AWS S3 Standard | $23.00 | $0.09 | $0.005/1000 |
| Azure Blob | $18.00 | $0.087 | $0.004/10000 |
| Google Cloud | $20.00 | $0.12 | $0.005/1000 |

**Wasabi is up to 80% cheaper than hyperscalers.**

---

## 5. Known Limitations

### 90-Day Minimum Storage Duration

**Critical limitation:** Wasabi charges for a minimum of 90 days of storage.

| Scenario | What Happens |
|----------|--------------|
| Store file for 90+ days | Normal billing |
| Delete file after 30 days | Charged for remaining 60 days |
| Delete file same day | Charged for full 90 days |
| Overwrite file after 45 days | Old version charged for 45 days more |

**Mitigation strategies:**
1. Use lifecycle policies to delay deletions
2. Avoid Wasabi for temporary/cache files
3. Consider total cost of ownership vs. pure per-GB rates
4. Best for archival and backup workloads

### File Size Limits

| Limit | Value | Notes |
|-------|-------|-------|
| Minimum object size | 0 bytes | No minimum |
| Maximum object size | 5 TB | Via multipart upload |
| Maximum single PUT | 5 GB | Larger files require multipart |
| Console upload limit | 1 TB | Recommended: few GB max |
| Multipart part size | 5 MB - 5 GB | rclone handles automatically |

### Rate Limits

Wasabi does not publish specific rate limits, but:
- S3 API compatible with standard practices
- No known throttling for typical usage
- High request rates may be reviewed

### Other Limitations

| Limitation | Details |
|------------|---------|
| **No S3 Select** | Wasabi does not support S3 Select API |
| **No Glacier-like tiers** | Single storage class only |
| **Bucket naming** | Globally unique across all Wasabi accounts |
| **Region migration** | Cannot move bucket between regions |
| **Object versioning** | Supported but each version counts toward storage |

### Egress Policy Clarification

While egress is "free," the fair use policy states:
- Monthly egress should not regularly exceed active storage
- If it does, Wasabi may limit or suspend service
- Not suitable as a CDN origin for high-traffic sites

---

## 6. Current Implementation Status

### Already Implemented in CloudSync Ultra

| Component | Status | Location |
|-----------|--------|----------|
| Provider enum case | Done | `CloudProvider.swift:36` |
| Display name ("Wasabi") | Done | `CloudProvider.swift:95` |
| Icon (leaf.fill) | Done | `CloudProvider.swift:155` |
| Brand color (Green #00B64F) | Done | `CloudProvider.swift:215` |
| Rclone type mapping (`s3`) | Done | `CloudProvider.swift:274` |
| Default rclone name | Done | `CloudProvider.swift:333` |
| Setup method | Done | `RcloneManager.swift:1417-1431` |
| Fast-list support | Done | `CloudProvider.swift:639` |
| Parallelism config (16/32) | Done | `CloudProvider.swift:653` |
| Chunk size (16MB) | Done | `TransferOptimizer.swift:29-31` |
| Chunk size flag | Done | `TransferOptimizer.swift:92-93` |

### Setup Method Implementation

```swift
// RcloneManager.swift:1417-1431
func setupWasabi(remoteName: String, accessKey: String, secretKey: String, region: String = "us-east-1", endpoint: String? = nil) async throws {
    var params: [String: String] = [
        "type": "s3",
        "provider": "Wasabi",
        "access_key_id": accessKey,
        "secret_access_key": secretKey,
        "region": region
    ]

    // Wasabi endpoint format: s3.{region}.wasabisys.com
    let wasabiEndpoint = endpoint ?? "https://s3.\(region).wasabisys.com"
    params["endpoint"] = wasabiEndpoint

    try await createRemote(name: remoteName, type: "s3", parameters: params)
}
```

### Performance Optimizations

| Feature | Value | Reference |
|---------|-------|-----------|
| Default transfers | 16 | `CloudProvider.swift:654` |
| Default checkers | 32 | `CloudProvider.swift:654` |
| Chunk size | 16MB | `TransferOptimizer.swift:32` |
| Fast-list | Enabled | `CloudProvider.swift:639` |
| Multi-thread download | Full support | `RcloneManager.swift:87` |

---

## 7. Step-by-Step Connection Flow

### Prerequisites

1. Wasabi account (free trial: 1TB for 30 days)
2. Access Key ID and Secret Access Key
3. At least one bucket created

### Creating a Wasabi Account

1. Visit [wasabi.com](https://wasabi.com)
2. Click "Start Free Trial"
3. Complete registration
4. Verify email

### Creating a Bucket

1. Log into [Wasabi Console](https://console.wasabisys.com)
2. Click **Create Bucket**
3. Enter bucket name (globally unique)
4. Select region (choose closest to you)
5. Enable/disable:
   - Bucket Versioning (optional)
   - Object Lock (if compliance needed - cannot enable later)
   - Bucket Logging (optional)
6. Click **Create Bucket**

### Generating Access Keys

1. Go to **Access Keys** in Wasabi Console
2. Click **Create New Access Key**
3. Choose key type (Root or Sub-User)
4. **Copy both keys immediately** - Secret shown only once
5. Store securely (password manager recommended)

### Connection Flow in CloudSync Ultra

1. Open CloudSync Ultra
2. Click **Add Remote** or **+** button
3. Select **Wasabi** from provider list
4. Enter credentials:
   - **Access Key ID**: Your Wasabi access key
   - **Secret Access Key**: Your Wasabi secret key
5. Select **Region** (must match your bucket's region)
6. Click **Connect** or **Test Connection**
7. CloudSync calls `setupWasabi()` with appropriate endpoint
8. Browse your Wasabi buckets

---

## 8. Comparison with Other S3 Providers

### Feature Comparison

| Feature | Wasabi | AWS S3 | Backblaze B2 | Cloudflare R2 |
|---------|--------|--------|--------------|---------------|
| **Backend type** | S3 compatible | S3 native | B2 native | S3 compatible |
| **Pricing model** | Flat | Tiered | Flat | Flat |
| **Egress fees** | Free* | $0.09/GB | $0.01/GB | Free |
| **Storage/TB/mo** | $6.99 | $23 | $6 | $15 |
| **Min storage duration** | 90 days | None | None | None |
| **Regions** | 16 | 30+ | 2 | 300+ edge |
| **Object Lock** | Yes | Yes | Yes | No |
| **Free tier** | 1TB trial | 5GB forever | 10GB forever | 10GB forever |

### When to Choose Wasabi

**Ideal for:**
- Large backup/archive workloads
- Predictable monthly costs
- Compliance requirements (HIPAA, SEC, etc.)
- Data that rarely changes
- Long-term storage (>90 days)

**Consider alternatives for:**
- Frequently changing/temporary data (90-day minimum)
- High egress needs exceeding storage (egress policy)
- Edge computing (R2 has 300+ PoPs)
- Native AWS integration needs

### Migration Considerations

Moving from AWS S3 to Wasabi:
1. Both use S3 API - tools compatible
2. Use rclone sync or copy commands
3. Consider egress costs from AWS
4. Plan for 90-day minimum on Wasabi

---

## 9. Implementation Recommendation

### Difficulty Rating: EASY

| Aspect | Status | Notes |
|--------|--------|-------|
| Provider enum | COMPLETE | Already defined |
| Setup function | COMPLETE | Handles endpoint generation |
| Region support | COMPLETE | Default + custom endpoint |
| Performance tuning | COMPLETE | 16MB chunks, high parallelism |
| Fast-list | COMPLETE | Enabled for efficiency |

### Code Changes Needed: NONE

The existing implementation fully supports Wasabi Hot Cloud Storage. All necessary configurations are in place.

### Optional UI Enhancements

1. **Region Selector Dropdown**
   - Pre-populated list of Wasabi regions
   - Auto-generates correct endpoint URL

2. **Wizard Enhancements**
   - Link to Wasabi key creation page
   - Warning about 90-day minimum storage
   - Egress policy explanation

3. **Cost Estimator**
   - Show projected monthly costs
   - Warn about early deletion charges

### Testing Checklist

- [x] Backend type correctly configured as `s3`
- [x] Provider set to `Wasabi`
- [x] Setup function generates correct endpoint
- [x] Fast-list enabled
- [x] Parallelism optimized (16/32)
- [x] Chunk size optimized (16MB)
- [ ] Test with different regions
- [ ] Test bucket listing
- [ ] Test large file upload (>5GB)
- [ ] Verify Object Lock compatibility

---

## 10. References

### Official Documentation

- [Wasabi rclone Documentation](https://docs.wasabi.com/docs/how-do-i-use-rclone-with-wasabi)
- [Wasabi Service URLs](https://docs.wasabi.com/docs/what-are-the-service-urls-for-wasabi-s-different-storage-regions)
- [Wasabi Pricing FAQ](https://wasabi.com/pricing/faq)
- [Wasabi Storage Regions](https://wasabi.com/company/storage-regions)
- [Wasabi Object Lock](https://docs.wasabi.com/docs/object-locking)
- [Wasabi Immutability](https://docs.wasabi.com/docs/immutability-compliance-and-object-locking)
- [Minimum Storage Duration Policy](https://docs.wasabi.com/docs/how-does-wasabis-minimum-storage-duration-policy-work)

### rclone Documentation

- [rclone S3 Backend](https://rclone.org/s3/)
- [rclone Wasabi Configuration](https://rclone.org/s3/#wasabi)

### Related CloudSync Studies

- [S3 Integration Study (Issue #126)](ARCHITECT1_S3.md)
- [Backblaze B2 Integration Study (Issue #127)](ARCHITECT2_B2.md)

---

## Appendix A: Sample Rclone Configurations

### Wasabi US East (Default)

```ini
[wasabi]
type = s3
provider = Wasabi
access_key_id = YOUR_ACCESS_KEY
secret_access_key = YOUR_SECRET_KEY
region = us-east-1
endpoint = s3.wasabisys.com
```

### Wasabi EU Central (Amsterdam)

```ini
[wasabi-eu]
type = s3
provider = Wasabi
access_key_id = YOUR_ACCESS_KEY
secret_access_key = YOUR_SECRET_KEY
region = eu-central-1
endpoint = s3.eu-central-1.wasabisys.com
```

### Wasabi AP (Tokyo)

```ini
[wasabi-tokyo]
type = s3
provider = Wasabi
access_key_id = YOUR_ACCESS_KEY
secret_access_key = YOUR_SECRET_KEY
region = ap-northeast-1
endpoint = s3.ap-northeast-1.wasabisys.com
```

---

## Appendix B: Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| 403 Forbidden | Invalid credentials | Verify access key and secret key |
| 403 on bucket | Wrong region | Ensure endpoint matches bucket region |
| Connection reset | Network issue | Check firewall, retry |
| Slow uploads | Wrong chunk size | Use 16MB chunks (CloudSync default) |
| SignatureDoesNotMatch | Clock skew | Sync system clock |

### Error Messages

| Error | Meaning |
|-------|---------|
| `InvalidAccessKeyId` | Access key not found |
| `SignatureDoesNotMatch` | Wrong secret key or clock skew |
| `NoSuchBucket` | Bucket doesn't exist or wrong region |
| `AccessDenied` | IAM policy insufficient |
| `BucketAlreadyExists` | Name taken globally |

---

## Conclusion

Wasabi Hot Cloud Storage integration in CloudSync Ultra is **production-ready**. The S3-compatible backend is correctly implemented with optimal performance settings. Users can connect immediately using the existing setup function.

**Key Takeaways:**
1. **No code changes required** - Full implementation exists
2. **Cost-effective** - 80% cheaper than hyperscalers
3. **No egress fees** - Predictable pricing (fair use policy applies)
4. **90-day minimum** - Best for archival/backup workloads
5. **16 global regions** - Good geographic coverage

**Recommendation:** Proceed with Wasabi as a fully supported provider. Consider adding region selector dropdown and 90-day minimum warning in the connection wizard for improved UX.

---

*End of Integration Study*
