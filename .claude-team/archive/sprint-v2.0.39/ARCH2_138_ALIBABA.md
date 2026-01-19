# Integration Study #138: Alibaba Cloud OSS

**Architect:** Architect-2
**Date:** 2026-01-18
**Status:** COMPLETE

---

## Executive Summary

Alibaba Cloud Object Storage Service (OSS) is already partially implemented in CloudSync Ultra. The provider is registered in `CloudProviderType` and has a basic setup function in `RcloneManager`. However, the wizard flow is **not complete** - the `TestConnectionStep` does not handle `alibabaOSS`, and the `ConfigureSettingsStep` lacks region/endpoint selection UI.

---

## 1. Current Implementation Status

### CloudProviderType.swift
- **Registered:** Yes, as `.alibabaOSS = "oss"`
- **Display Name:** "Alibaba Cloud OSS"
- **Icon:** `building.fill`
- **Brand Color:** `#FF6A00` (Alibaba Orange)
- **rclone Type:** `"oss"` (dedicated backend, NOT s3 with provider)

### RcloneManager.swift
- **Setup Function Exists:** Yes
```swift
func setupAlibabaOSS(remoteName: String, accessKey: String, secretKey: String,
                     endpoint: String, region: String = "oss-cn-hangzhou") async throws {
    let params: [String: String] = [
        "access_key_id": accessKey,
        "access_key_secret": secretKey,
        "endpoint": endpoint,
        "region": region
    ]
    try await createRemote(name: remoteName, type: "oss", parameters: params)
}
```

### TestConnectionStep.swift
- **Handler:** MISSING - Falls through to default case, throwing "Provider not yet supported"
- **Impact:** Users cannot complete the wizard for Alibaba OSS

### ConfigureSettingsStep.swift
- **Region Selection UI:** MISSING
- **Endpoint Selection UI:** MISSING
- **Impact:** No way to select region/endpoint in the wizard

---

## 2. rclone Backend Configuration

### Backend Type
Alibaba OSS uses a **dedicated rclone backend** named `oss`, NOT the S3 backend with Alibaba provider.

Reference: https://rclone.org/s3/#alibaba-oss

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `access_key_id` | Alibaba Cloud Access Key ID | `LTAI5t...` |
| `access_key_secret` | Alibaba Cloud Access Key Secret | `bZ9L2X...` |
| `endpoint` | Region endpoint URL | `oss-cn-hangzhou.aliyuncs.com` |
| `region` | Region ID (optional for some ops) | `oss-cn-hangzhou` |

### Optional Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `acl` | Canned ACL for objects | `private` |
| `storage_class` | Storage class for new objects | `STANDARD` |
| `env_auth` | Get credentials from environment | `false` |

### Storage Classes

| Class | Description | Use Case |
|-------|-------------|----------|
| `STANDARD` | Default, frequently accessed | Active data |
| `STANDARD_IA` | Infrequent Access | Backups, archives accessed monthly |
| `GLACIER` | Cold storage, retrieval time required | Long-term archives |

### ACL Options

| ACL | Description |
|-----|-------------|
| `private` | Owner-only access (default, recommended) |
| `public-read` | Public read, owner write |
| `public-read-write` | Public read and write (not recommended) |

---

## 3. Region and Endpoint Mapping

### China Mainland Regions

| Region Name | Region ID | Internet Endpoint |
|-------------|-----------|-------------------|
| Hangzhou | `cn-hangzhou` | `oss-cn-hangzhou.aliyuncs.com` |
| Shanghai | `cn-shanghai` | `oss-cn-shanghai.aliyuncs.com` |
| Nanjing | `cn-nanjing` | `oss-cn-nanjing.aliyuncs.com` |
| Qingdao | `cn-qingdao` | `oss-cn-qingdao.aliyuncs.com` |
| Beijing | `cn-beijing` | `oss-cn-beijing.aliyuncs.com` |
| Zhangjiakou | `cn-zhangjiakou` | `oss-cn-zhangjiakou.aliyuncs.com` |
| Hohhot | `cn-huhehaote` | `oss-cn-huhehaote.aliyuncs.com` |
| Ulanqab | `cn-wulanchabu` | `oss-cn-wulanchabu.aliyuncs.com` |
| Shenzhen | `cn-shenzhen` | `oss-cn-shenzhen.aliyuncs.com` |
| Heyuan | `cn-heyuan` | `oss-cn-heyuan.aliyuncs.com` |
| Guangzhou | `cn-guangzhou` | `oss-cn-guangzhou.aliyuncs.com` |
| Chengdu | `cn-chengdu` | `oss-cn-chengdu.aliyuncs.com` |
| Hong Kong | `cn-hongkong` | `oss-cn-hongkong.aliyuncs.com` |

### International Regions

| Region Name | Region ID | Internet Endpoint |
|-------------|-----------|-------------------|
| Singapore | `ap-southeast-1` | `oss-ap-southeast-1.aliyuncs.com` |
| Tokyo | `ap-northeast-1` | `oss-ap-northeast-1.aliyuncs.com` |
| Seoul | `ap-northeast-2` | `oss-ap-northeast-2.aliyuncs.com` |
| Kuala Lumpur | `ap-southeast-3` | `oss-ap-southeast-3.aliyuncs.com` |
| Jakarta | `ap-southeast-5` | `oss-ap-southeast-5.aliyuncs.com` |
| Manila | `ap-southeast-6` | `oss-ap-southeast-6.aliyuncs.com` |
| Bangkok | `ap-southeast-7` | `oss-ap-southeast-7.aliyuncs.com` |
| Frankfurt | `eu-central-1` | `oss-eu-central-1.aliyuncs.com` |
| London | `eu-west-1` | `oss-eu-west-1.aliyuncs.com` |
| Silicon Valley | `us-west-1` | `oss-us-west-1.aliyuncs.com` |
| Virginia | `us-east-1` | `oss-us-east-1.aliyuncs.com` |
| Dubai | `me-east-1` | `oss-me-east-1.aliyuncs.com` |
| Riyadh | `me-central-1` | `oss-me-central-1.aliyuncs.com` |

### Endpoint Pattern
- **Internet:** `oss-{region-id}.aliyuncs.com`
- **Internal (VPC):** `oss-{region-id}-internal.aliyuncs.com`

---

## 4. China Region Considerations

### March 2025 Policy Change

**IMPORTANT:** Starting March 20, 2025, new OSS users must use a **custom domain name (CNAME)** to perform data API operations on buckets in Chinese mainland regions via default public endpoints.

**Impact on CloudSync Ultra:**
- Chinese mainland users may need to configure custom domains
- This does NOT affect international region users
- Existing users with buckets created before March 20, 2025 are unaffected

### Recommendations for China Support

1. **Add CNAME field** to wizard for China mainland regions (optional advanced setting)
2. **Display warning** when China mainland region selected about potential CNAME requirement
3. **Prioritize international regions** in the picker for non-China users

---

## 5. Authentication

### RAM User Credentials

Alibaba OSS uses Access Key ID + Secret for authentication:

1. Log in to Alibaba Cloud Console
2. Create a RAM (Resource Access Management) user
3. Grant `AliyunOSSFullAccess` or custom OSS permissions
4. Generate Access Key ID + Secret for the RAM user

### STS Tokens (Future Enhancement)

For temporary credentials, Alibaba supports STS (Security Token Service):
- Short-lived access (15 minutes to 1 hour)
- Useful for federated access patterns
- **Not recommended for initial implementation** - adds complexity

### Required Permissions

Minimum permissions for full CloudSync functionality:
- `oss:ListBuckets`
- `oss:GetBucketInfo`
- `oss:PutObject`
- `oss:GetObject`
- `oss:DeleteObject`
- `oss:ListObjects`

---

## 6. Recommended Wizard Flow

### Step 1: Choose Provider
- Already implemented (Alibaba Cloud OSS in provider list)

### Step 2: Configure Settings (NEEDS IMPLEMENTATION)

```
+--------------------------------------------------+
|  Configure Alibaba Cloud OSS                      |
|                                                  |
|  [i] Create Access Keys at Alibaba Cloud Console |
|                                                  |
|  Access Key ID:  [___________________________]   |
|  Secret Key:     [___________________________]   |
|                                                  |
|  Region:         [v] Asia Pacific - Singapore    |
|                      Asia Pacific - Tokyo        |
|                      Asia Pacific - Seoul        |
|                      Europe - Frankfurt          |
|                      ... (all regions)           |
|                      China - Hangzhou            |
|                      ... (China regions)         |
|                                                  |
|  [Advanced Settings]                             |
|  Storage Class:  [v] Standard                    |
|  ACL:           [v] Private (Recommended)        |
|                                                  |
+--------------------------------------------------+
```

**Wizard State Fields to Add:**
```swift
// In ProviderConnectionWizardState
@Published var alibabaRegion: String = "ap-southeast-1"  // Default: Singapore
@Published var alibabaStorageClass: String = "STANDARD"
@Published var alibabaACL: String = "private"
```

### Step 3: Test Connection (NEEDS IMPLEMENTATION)

Add case in `TestConnectionStep.configureRemoteWithRclone()`:
```swift
case .alibabaOSS:
    let endpoint = "oss-\(alibabaRegion).aliyuncs.com"
    try await rclone.setupAlibabaOSS(
        remoteName: rcloneName,
        accessKey: username,
        secretKey: password,
        endpoint: endpoint,
        region: alibabaRegion
    )
```

### Step 4: Success
- Already implemented (generic success step)

---

## 7. Feature Support Matrix

| Feature | Support | Notes |
|---------|---------|-------|
| Bucket operations | Yes | List, create, delete |
| Storage classes | Yes | Standard, IA, Glacier |
| Region selection | Yes | 25+ regions |
| ACL handling | Yes | private, public-read, public-read-write |
| Fast-list | No | Not currently in supportsFastList |
| Server-side encryption | Partial | Supported by OSS, not exposed in wizard |
| Versioning | Partial | Supported by OSS, not exposed in wizard |

---

## 8. Implementation Tasks

### Priority 1: Complete Wizard Flow
1. Add `alibabaOSS` case to `TestConnectionStep.configureRemoteWithRclone()`
2. Add region picker to `ConfigureSettingsStep` for OSS providers
3. Add wizard state fields for region, storage class, ACL

### Priority 2: Enhance Features
4. Add Alibaba OSS to `supportsFastList` in CloudProviderType extension
5. Add storage class selection in advanced settings
6. Add provider-specific instructions for obtaining credentials

### Priority 3: China Support
7. Add CNAME field for China mainland regions
8. Display March 2025 policy warning for China regions
9. Consider region grouping (International vs China Mainland)

---

## 9. Sample rclone Configuration

```ini
[alibaba]
type = oss
access_key_id = LTAI5tExample
access_key_secret = bZ9L2XExampleSecret
endpoint = oss-ap-southeast-1.aliyuncs.com
acl = private
storage_class = STANDARD
```

---

## 10. References

- [rclone Alibaba OSS Documentation](https://rclone.org/s3/#alibaba-oss)
- [Alibaba Cloud OSS Regions and Endpoints](https://www.alibabacloud.com/help/en/oss/user-guide/regions-and-endpoints)
- [Alibaba Cloud RAM Console](https://ram.console.aliyun.com/)
- [OSS Storage Classes](https://www.alibabacloud.com/help/en/oss/user-guide/storage-classes)

---

## Appendix: Region Data Structure (Swift)

```swift
struct AlibabaOSSRegion: Identifiable, Hashable {
    let id: String          // e.g., "ap-southeast-1"
    let name: String        // e.g., "Singapore"
    let group: RegionGroup

    enum RegionGroup: String, CaseIterable {
        case asiaPacific = "Asia Pacific"
        case europe = "Europe"
        case americas = "Americas"
        case middleEast = "Middle East"
        case chinaMainland = "China Mainland"
    }

    var endpoint: String {
        "oss-\(id).aliyuncs.com"
    }

    static let allRegions: [AlibabaOSSRegion] = [
        // Asia Pacific
        AlibabaOSSRegion(id: "ap-southeast-1", name: "Singapore", group: .asiaPacific),
        AlibabaOSSRegion(id: "ap-northeast-1", name: "Tokyo", group: .asiaPacific),
        AlibabaOSSRegion(id: "ap-northeast-2", name: "Seoul", group: .asiaPacific),
        AlibabaOSSRegion(id: "ap-southeast-3", name: "Kuala Lumpur", group: .asiaPacific),
        AlibabaOSSRegion(id: "ap-southeast-5", name: "Jakarta", group: .asiaPacific),
        AlibabaOSSRegion(id: "ap-southeast-6", name: "Manila", group: .asiaPacific),
        AlibabaOSSRegion(id: "ap-southeast-7", name: "Bangkok", group: .asiaPacific),
        AlibabaOSSRegion(id: "cn-hongkong", name: "Hong Kong", group: .asiaPacific),

        // Europe
        AlibabaOSSRegion(id: "eu-central-1", name: "Frankfurt", group: .europe),
        AlibabaOSSRegion(id: "eu-west-1", name: "London", group: .europe),

        // Americas
        AlibabaOSSRegion(id: "us-west-1", name: "Silicon Valley", group: .americas),
        AlibabaOSSRegion(id: "us-east-1", name: "Virginia", group: .americas),

        // Middle East
        AlibabaOSSRegion(id: "me-east-1", name: "Dubai", group: .middleEast),
        AlibabaOSSRegion(id: "me-central-1", name: "Riyadh", group: .middleEast),

        // China Mainland
        AlibabaOSSRegion(id: "cn-hangzhou", name: "Hangzhou", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-shanghai", name: "Shanghai", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-beijing", name: "Beijing", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-shenzhen", name: "Shenzhen", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-qingdao", name: "Qingdao", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-chengdu", name: "Chengdu", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-zhangjiakou", name: "Zhangjiakou", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-huhehaote", name: "Hohhot", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-wulanchabu", name: "Ulanqab", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-nanjing", name: "Nanjing", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-heyuan", name: "Heyuan", group: .chinaMainland),
        AlibabaOSSRegion(id: "cn-guangzhou", name: "Guangzhou", group: .chinaMainland),
    ]
}
```

---

**Study Complete.** The Alibaba OSS integration is partially implemented but requires wizard flow completion and region selection UI to be fully functional.
