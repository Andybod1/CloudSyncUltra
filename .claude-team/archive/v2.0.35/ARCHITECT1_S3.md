# Amazon S3 Integration Study for CloudSync Ultra

**GitHub Issue:** #126
**Date:** 2026-01-17
**Author:** Architect-1
**Sprint:** v2.0.35

---

## Executive Summary

Amazon S3 integration for CloudSync Ultra is **already fully implemented** in the codebase. The `CloudProviderType.s3` case exists with comprehensive configuration, including optimized parallelism settings, chunk size configuration, and multi-thread download support. S3 also serves as the foundation for multiple S3-compatible services (Wasabi, DigitalOcean Spaces, Cloudflare R2, Scaleway, Oracle Cloud, Filebase).

**Recommendation: EASY difficulty** - Full implementation exists. The wizard supports basic credential entry; only minor UI enhancements would improve the experience for advanced configurations (region selection, endpoint URLs).

---

## 1. Overview & Rclone Backend Details

### Backend Type

Amazon S3 uses the **`s3`** backend in rclone. This is one of the most mature and feature-rich backends, supporting AWS S3 and over 30 S3-compatible services.

**Current CloudSync Implementation:**
```swift
// CloudSyncApp/Models/CloudProvider.swift:16
case .s3 = "s3"

// CloudSyncApp/Models/CloudProvider.swift:75
case .s3: return "Amazon S3"

// CloudSyncApp/Models/CloudProvider.swift:135
case .s3: return "cube.fill"  // SF Symbol

// CloudSyncApp/Models/CloudProvider.swift:195
case .s3: return Color(hex: "FF9900")  // AWS Orange

// CloudSyncApp/Models/CloudProvider.swift:254
case .s3: return "s3"  // rclone type
```

### Setup Method

```swift
// CloudSyncApp/RcloneManager.swift:1242-1252
func setupS3(remoteName: String, accessKey: String, secretKey: String, region: String = "us-east-1", endpoint: String = "") async throws {
    var params: [String: String] = [
        "access_key_id": accessKey,
        "secret_access_key": secretKey,
        "region": region
    ]
    if !endpoint.isEmpty {
        params["endpoint"] = endpoint
    }
    try await createRemote(name: remoteName, type: "s3", parameters: params)
}
```

### Rclone Configuration Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `type` | `s3` | Yes |
| `provider` | `AWS` (or specific provider name) | Recommended |
| `access_key_id` | AWS Access Key ID | Yes |
| `secret_access_key` | AWS Secret Access Key | Yes |
| `region` | AWS region (e.g., `us-east-1`) | Yes |
| `endpoint` | Custom endpoint URL | Optional |
| `location_constraint` | Region for new buckets | Optional |
| `acl` | Access control (private, public-read, etc.) | Optional |
| `server_side_encryption` | AES256 or aws:kms | Optional |
| `sse_kms_key_id` | KMS key for encryption | Optional |
| `storage_class` | STANDARD, REDUCED_REDUNDANCY, GLACIER, etc. | Optional |

### Path Format

```
remotename:bucket
remotename:bucket/path/to/folder
remotename:bucket/path/to/file.txt
```

---

## 2. Authentication Requirements

### Authentication Methods

#### Method 1: Access Keys (Current Implementation)

The current CloudSync implementation uses AWS Access Keys:

- **Access Key ID**: 20-character alphanumeric identifier
- **Secret Access Key**: 40-character secret key
- **Best for:** Programmatic access, personal use, development

**Current Wizard Support:**
```swift
// CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift:340-341
case .s3:
    return "Enter your AWS Access Key ID as username and Secret Access Key as password."
```

#### Method 2: IAM Instance Roles (Not Implemented)

For EC2 instances or ECS tasks:
- No credentials needed if running on AWS infrastructure
- Rclone auto-detects IAM role credentials
- **Best for:** AWS-hosted applications

```ini
[s3-iam]
type = s3
provider = AWS
env_auth = true
region = us-east-1
```

#### Method 3: Session Tokens (Not Implemented)

For temporary credentials via AWS STS:
- Requires `session_token` parameter
- Tokens expire (typically 1-12 hours)
- **Best for:** Federated access, cross-account access

```ini
[s3-temp]
type = s3
provider = AWS
access_key_id = ASIAXXXXXXXXXXXXXXXX
secret_access_key = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
session_token = FwoGZX...
region = us-east-1
```

### Region Configuration

AWS S3 regions follow the format: `{geo}-{location}-{number}`

| Region Code | Location |
|-------------|----------|
| us-east-1 | N. Virginia (default) |
| us-east-2 | Ohio |
| us-west-1 | N. California |
| us-west-2 | Oregon |
| eu-west-1 | Ireland |
| eu-west-2 | London |
| eu-central-1 | Frankfurt |
| ap-southeast-1 | Singapore |
| ap-northeast-1 | Tokyo |
| ap-south-1 | Mumbai |
| sa-east-1 | Sao Paulo |

### Endpoint URLs

For AWS S3, endpoints are automatically determined by region:
```
https://s3.{region}.amazonaws.com
```

For S3-compatible services, custom endpoints are required (see Section 3).

---

## 3. S3-Compatible Services

CloudSync Ultra already supports several S3-compatible services through the S3 backend:

### Implemented Services

| Service | Provider Value | Endpoint Format | Implementation |
|---------|---------------|-----------------|----------------|
| **Wasabi** | `Wasabi` | `https://s3.{region}.wasabisys.com` | `RcloneManager.swift:1387-1401` |
| **DigitalOcean Spaces** | `DigitalOcean` | `https://{region}.digitaloceanspaces.com` | `RcloneManager.swift:1403-1417` |
| **Cloudflare R2** | `Cloudflare` | `https://{account_id}.r2.cloudflarestorage.com` | `RcloneManager.swift:1419-1430` |
| **Scaleway** | `Scaleway` | `https://s3.{region}.scw.cloud` | `RcloneManager.swift:1432-1446` |
| **Oracle Cloud** | `Other` | `https://{namespace}.compat.objectstorage.{region}.oraclecloud.com` | `RcloneManager.swift:1448-1459` |
| **Filebase** | `Other` | `https://s3.filebase.com` | `RcloneManager.swift:1471-1482` |

### Additional S3-Compatible Services (Not Yet Implemented)

| Service | Endpoint Pattern |
|---------|-----------------|
| MinIO | Custom (self-hosted) |
| Linode Object Storage | `{cluster}.linodeobjects.com` |
| Vultr Object Storage | `{region}.vultrobjects.com` |
| Backblaze B2 (S3 API) | `s3.{region}.backblazeb2.com` |
| IBM Cloud Object Storage | `s3.{region}.cloud-object-storage.appdomain.cloud` |
| Alibaba Cloud OSS | `oss-{region}.aliyuncs.com` |
| Tencent COS | `cos.{region}.myqcloud.com` |
| Yandex Object Storage | `storage.yandexcloud.net` |

### Configuration Differences

Each S3-compatible service requires specific configuration:

```ini
# AWS S3 (standard)
[aws]
type = s3
provider = AWS
access_key_id = xxx
secret_access_key = xxx
region = us-east-1

# Wasabi
[wasabi]
type = s3
provider = Wasabi
access_key_id = xxx
secret_access_key = xxx
region = us-east-1
endpoint = https://s3.us-east-1.wasabisys.com

# MinIO (self-hosted)
[minio]
type = s3
provider = Minio
access_key_id = xxx
secret_access_key = xxx
endpoint = http://localhost:9000
```

---

## 4. Known Limitations & Workarounds

### File Size Limits

| Limit Type | Value | Notes |
|------------|-------|-------|
| Maximum object size | 5 TB | Via multipart upload |
| Maximum single PUT | 5 GB | For non-multipart |
| Multipart minimum | 5 MB | Per part (except last) |
| Multipart maximum | 10,000 parts | 50GB with 5MB parts |
| Recommended chunk | 16 MB | CloudSync default |

**CloudSync Configuration:**
```swift
// CloudSyncApp/Models/TransferOptimizer.swift:29-31
case .s3, .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
     .scaleway, .oracleCloud, .storj, .filebase, .googleCloudStorage,
     .azureBlob, .alibabaOSS:
    return 16 * 1024 * 1024  // 16MB - object storage optimized
```

### Rate Limits

| Operation | Limit | Notes |
|-----------|-------|-------|
| PUT/COPY/POST/DELETE | 3,500 requests/sec/prefix | Per prefix partition |
| GET/HEAD | 5,500 requests/sec/prefix | Per prefix partition |
| LIST | 5,500 requests/sec | Global bucket limit |

**Workaround:** CloudSync uses optimized parallelism:
```swift
// CloudSyncApp/Models/CloudProvider.swift:653-654
case .s3, .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2, .scaleway, .oracleCloud, .filebase, .storj:
    return (transfers: 16, checkers: 32)
```

### Path-Style vs Virtual-Hosted Style

AWS deprecated path-style access (September 2020) for new buckets:

| Style | URL Format | Status |
|-------|------------|--------|
| Virtual-hosted (default) | `https://bucket.s3.region.amazonaws.com/key` | Current |
| Path-style | `https://s3.region.amazonaws.com/bucket/key` | Legacy |

Rclone uses virtual-hosted style by default. For S3-compatible services that require path-style:
```ini
force_path_style = true
```

### Eventual Consistency

AWS S3 is now strongly consistent for all operations (as of December 2020):
- Read-after-write consistency for PUTs
- Strong consistency for overwrites and deletes
- List operations are consistent

**No workarounds needed** for modern AWS S3.

### Bucket Naming Rules

- 3-63 characters
- Lowercase letters, numbers, hyphens only
- Cannot start/end with hyphen
- Cannot be formatted as IP address
- Globally unique across all AWS accounts

### Object Key Limitations

| Limitation | Value |
|------------|-------|
| Maximum key length | 1,024 bytes |
| Safe characters | `a-z`, `0-9`, `-`, `_`, `.`, `/` |
| Requires encoding | `!`, `*`, `'`, `(`, `)`, etc. |

---

## 5. Step-by-Step Connection Flow

### Prerequisites

1. AWS Account (or S3-compatible service account)
2. IAM user with S3 permissions
3. Access Key ID and Secret Access Key

### Getting AWS Access Keys

1. Sign in to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to IAM > Users
3. Select or create a user
4. Go to "Security credentials" tab
5. Click "Create access key"
6. Select "Application running outside AWS"
7. Save both Access Key ID and Secret Access Key

### IAM Policy Requirements

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
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        }
    ]
}
```

### Connection Flow in CloudSync

1. User selects "Amazon S3" provider in CloudSync Ultra
2. User enters Access Key ID in username field
3. User enters Secret Access Key in password field
4. Click "Next" to configure and test connection
5. CloudSync calls `setupS3()` with default `us-east-1` region
6. Rclone creates the remote configuration
7. Connection test verifies bucket access
8. User can browse S3 buckets and objects

---

## 6. Current Implementation Status

### Already Implemented

| Component | Status | Location |
|-----------|--------|----------|
| Provider enum case | Done | `CloudProvider.swift:16` |
| Display name | Done | `CloudProvider.swift:75` |
| Icon (cube.fill) | Done | `CloudProvider.swift:135` |
| Brand color (AWS Orange) | Done | `CloudProvider.swift:195` |
| Rclone type mapping | Done | `CloudProvider.swift:254` |
| Default rclone name | Done | `CloudProvider.swift:315` |
| Setup method | Done | `RcloneManager.swift:1242-1252` |
| Wizard instructions | Done | `ConfigureSettingsStep.swift:340-341` |
| Help URL (IAM) | Done | `ConfigureSettingsStep.swift:355-356` |
| Fast-list support | Done | `CloudProvider.swift:636` |
| Parallelism config | Done | `CloudProvider.swift:653-654` |
| Multi-thread support | Done | `RcloneManager.swift:86-90` |
| Chunk size config | Done | `TransferOptimizer.swift:29-31, 92-94` |
| Error patterns | Done | `TransferError.swift:293-297` |

### Performance Optimizations

| Feature | Value | Reference |
|---------|-------|-----------|
| Default transfers | 16 | `CloudProvider.swift:654` |
| Default checkers | 32 | `CloudProvider.swift:654` |
| Chunk size | 16MB | `TransferOptimizer.swift:32` |
| Multi-thread capability | Full | `RcloneManager.swift:86-90` |
| Fast-list | Enabled | `RcloneManager.swift:291` |

---

## 7. Recommended UI Improvements

### Current Limitations

The wizard currently uses username/password fields for S3 credentials:
- Access Key ID goes in "Username" field
- Secret Access Key goes in "Password" field
- No region selector (defaults to `us-east-1`)
- No endpoint URL field for custom endpoints

### Suggested Enhancements (Optional)

1. **Dedicated S3 Configuration Fields**
   ```swift
   struct S3ConfigurationView: View {
       @State var accessKeyId: String = ""
       @State var secretAccessKey: String = ""
       @State var region: String = "us-east-1"
       @State var endpoint: String = ""
       @State var bucket: String = ""  // Optional default bucket
   }
   ```

2. **Region Picker Dropdown**
   - Pre-populated list of AWS regions
   - Auto-complete for quick selection

3. **S3-Compatible Service Selector**
   - Quick presets for Wasabi, MinIO, etc.
   - Auto-fills endpoint and region

4. **Bucket Browser**
   - List available buckets after authentication
   - Allow selecting default bucket

---

## 8. Implementation Difficulty Assessment

| Aspect | Difficulty | Notes |
|--------|------------|-------|
| Basic connection | Easy | Already fully working |
| Region configuration | Easy | Parameter exists, needs UI |
| Custom endpoint | Easy | Parameter exists, needs UI |
| S3-compatible services | Easy | Already implemented |
| IAM roles | Medium | Requires `env_auth` support |
| Session tokens | Medium | Requires additional field |
| KMS encryption | Medium | Advanced feature |
| Bucket creation | Hard | Requires additional permissions |

### Overall Rating: EASY

**Rationale:**
- Core S3 functionality is fully implemented and working
- All necessary rclone parameters are supported
- Performance optimizations are already in place
- Wizard provides basic credential entry
- Only minor UI improvements would enhance the experience
- No architectural changes needed

---

## 9. Testing Recommendations

1. **Basic Connection Test**
   - Create test AWS account or use existing
   - Test with minimal IAM permissions
   - Verify bucket listing works

2. **Region Testing**
   - Test with different AWS regions
   - Verify region-specific endpoints work

3. **S3-Compatible Testing**
   - Test with Wasabi (free tier available)
   - Test with MinIO (local Docker container)

4. **Performance Testing**
   - Upload large files (>100MB) to test chunking
   - Upload many small files to test parallelism
   - Download large files to test multi-threading

5. **Error Handling Testing**
   - Invalid credentials
   - Non-existent bucket
   - Permission denied scenarios
   - Rate limit simulation

---

## 10. References

### Official Documentation
- [rclone S3 Backend](https://rclone.org/s3/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [S3 API Reference](https://docs.aws.amazon.com/AmazonS3/latest/API/)
- [S3 Service Quotas](https://docs.aws.amazon.com/general/latest/gr/s3.html)

### S3-Compatible Services
- [Wasabi Documentation](https://wasabi-support.zendesk.com/hc/en-us)
- [DigitalOcean Spaces](https://docs.digitalocean.com/products/spaces/)
- [Cloudflare R2](https://developers.cloudflare.com/r2/)
- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)

---

## Appendix A: Sample Rclone Configurations

### AWS S3 (Standard)
```ini
[s3]
type = s3
provider = AWS
access_key_id = AKIAIOSFODNN7EXAMPLE
secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region = us-east-1
```

### AWS S3 with Server-Side Encryption
```ini
[s3-encrypted]
type = s3
provider = AWS
access_key_id = AKIAIOSFODNN7EXAMPLE
secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region = us-east-1
server_side_encryption = AES256
```

### AWS S3 with KMS Encryption
```ini
[s3-kms]
type = s3
provider = AWS
access_key_id = AKIAIOSFODNN7EXAMPLE
secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region = us-east-1
server_side_encryption = aws:kms
sse_kms_key_id = arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012
```

### MinIO (Self-Hosted)
```ini
[minio]
type = s3
provider = Minio
access_key_id = minioadmin
secret_access_key = minioadmin
endpoint = http://localhost:9000
```

---

*End of Integration Study*
