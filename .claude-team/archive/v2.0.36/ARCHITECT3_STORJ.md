# Integration Study: Storj

**GitHub Issue:** #133
**Date:** 2026-01-17
**Author:** Architect-3
**Status:** COMPLETE

---

## 1. Overview & rclone Backend Details

### Backend Type
Storj uses a **native rclone backend** with the type identifier `storj`. Rclone provides two integration methods:
1. **Native Storj Backend** - Direct connection using Storj's native RPC protocol
2. **S3-Compatible Gateway** - Via the standard `s3` backend with Storj's hosted gateway

**Current Implementation in CloudSyncApp:**
```swift
// CloudProvider.swift line 41
case storj = "storj"

// rcloneType property (line 279)
case .storj: return "storj"

// defaultRcloneName property (line 337)
case .storj: return "storj"
```

### Configuration Parameters
The rclone `storj` backend accepts the following key parameters:

| Parameter | Description | Required |
|-----------|-------------|----------|
| `access_grant` | Serialized access grant (preferred) | Yes (if not using satellite method) |
| `satellite_address` | Satellite server address | Yes (if generating new grant) |
| `api_key` | API key from Storj console | Yes (if generating new grant) |
| `passphrase` | Encryption passphrase | Yes (if generating new grant) |

**Available Satellites:**
- **US1:** `us1.storj.io` (default)
- **EU1:** `eu1.storj.io`
- **AP1:** `ap1.storj.io`

### Current Implementation Status

**Fully Implemented:**
- Provider enum case defined (`CloudProviderType.storj`)
- Display name: "Storj"
- Icon: `lock.shield.fill` (reflects security focus)
- Brand color: `#0078FF` (Storj Blue)
- rclone type mapping (`"storj"`)
- Multi-thread download support (full capability)
- Chunk size optimization (16MB for object storage)
- Fast-list NOT enabled (Storj has different listing behavior)
- Default parallelism: 16 transfers, 32 checkers (CloudProvider.swift line 653)

**Current Setup Function (RcloneManager.swift lines 1467-1475):**
```swift
func setupStorj(remoteName: String, accessGrant: String) async throws {
    try await createRemote(
        name: remoteName,
        type: "storj",
        parameters: [
            "access_grant": accessGrant
        ]
    )
}
```

---

## 2. Authentication Requirements

### 2.1 Access Grant (Recommended)
The **Access Grant** is Storj's primary authentication method - a serialized security envelope containing:
- Satellite address
- Restricted API key
- Path-based encryption key

**Flow:**
1. Log into Storj Console (https://storj.io)
2. Navigate to Access > Create Access Grant
3. Name the access grant
4. Set permissions (read/write/list/delete)
5. Enter or generate encryption passphrase
6. Copy the generated access grant string

**rclone Config:**
```
[storj]
type = storj
access_grant = 1dfoobar...long-access-grant-string...xyz
```

### 2.2 API Key + Satellite + Passphrase (Alternative)
For more granular control, configure components separately:

**Flow:**
1. Create API key in Storj Console
2. Note the satellite address
3. Choose encryption passphrase

**rclone Config:**
```
[storj]
type = storj
satellite_address = 12EayRS2V1k...@us1.storj.io:7777
api_key = your-api-key-for-your-storj-project
passphrase = your-human-readable-encryption-passphrase
access_grant = generated-from-above
```

### 2.3 Encryption Passphrase Critical Notes

**Security:**
- Passphrase is NEVER stored by Storj services
- Loss of passphrase = permanent loss of data access
- All data is encrypted client-side before upload
- Access grants from the same project MUST use the same passphrase to access the same data

**Passphrase Options:**
1. **User-provided:** Any string chosen by user
2. **Generated mnemonic:** 12-word BIP39-style recovery phrase

**Satellite-Managed Encryption (New Option):**
As of late 2025, Storj offers satellite-managed encryption where the passphrase is stored encrypted on Storj's KMS. This simplifies UX but trades some privacy for convenience.

### Recommendation for CloudSync Ultra
**Primary:** Access Grant method (current implementation)
**Enhancement Needed:** UI wizard should guide users to generate access grants with proper scope

---

## 3. Storj-Specific Features

### 3.1 Decentralized Architecture

**How It Works:**
- Files are encrypted client-side using AES-256-GCM
- Files are split into 64MB segments
- Each segment is erasure-coded into 80 pieces (using Reed-Solomon)
- Only 29 pieces are needed for reconstruction
- Pieces are distributed across thousands of independent storage nodes globally

**Benefits:**
- No single point of failure
- 11 nines of durability (99.999999999%)
- 99.95% availability
- 60%+ of nodes can fail without data loss

### 3.2 Client-Side Encryption

**Features:**
- End-to-end encryption by default
- Storj cannot access user data or metadata
- Encryption key derived from passphrase
- Path-based encryption for bucket/folder structures

**rclone Native Backend:**
- Encryption handled automatically
- Private key never leaves local machine

**S3 Gateway:**
- Encryption/decryption handled server-side on gateway
- Key shared with gateway (slightly less secure)

### 3.3 Edge Services

**Linksharing Service:**
- Create public HTTP URLs for objects
- No sharing of full credentials required
- Can be permanent or time-limited
- Supports custom domain hosting
- Read-only access only

**Presigned URLs (S3 Gateway):**
- Time-limited upload/download URLs
- Standard S3 presigned URL format
- Works with AWS SDK and tools

**Static Website Hosting:**
- Upload static site to bucket
- Configure via `--dns` flag in uplink
- Use custom domain with CNAME

### 3.4 Storage Tiers

**Currently Available:**
- **Standard:** General purpose storage
- **Active Archive:** Lower cost, $0.02/GB egress, 30-day minimum

---

## 4. Known Limitations & Workarounds

### 4.1 Segment and Size Limits

| Limit | Value | Notes |
|-------|-------|-------|
| Default segment size | 64 MB | Configurable |
| Minimum object size (billable) | 50-100 kB | Varies by tier |
| Maximum object size | Unlimited | Constrained by segment count |

**Segment Billing (Legacy Pricing):**
- Small files (<64MB) = 1 segment each
- Many small files can increase costs due to segment overhead
- Per-segment fee offsets metadata overhead

**New Tiered Pricing (Nov 2025+):**
- Segment fees eliminated
- Egress included in global tier
- Simpler, more predictable costs

### 4.2 Connection and Resource Requirements

**Native Protocol Requirements:**
| Resource | Upload | Download |
|----------|--------|----------|
| TCP Connections | ~110 per segment | ~35 per segment |
| Bandwidth overhead | ~2.68x (erasure coding) | ~1.2x max |
| CPU usage | Higher (local encryption) | Higher (local decryption) |

**Common Issue:** `too many open files` error

**Workaround:**
```bash
ulimit -n 65536  # Before running rclone
```

**CloudSyncApp Note:** May need to document this for advanced users or detect/warn about ulimit.

### 4.3 Performance Considerations

**Upload Bandwidth:**
- Native: ~2.7x raw file size due to erasure coding
- S3 Gateway: 1x (encoding on gateway)

**Download Speed:**
- Native: Can be 2x faster than gateway (direct node connections)
- S3 Gateway: Single connection, gateway bottleneck possible

**Recommendation from rclone:**
- Use `--disable-http2` for increased transfer speeds

### 4.4 Pricing Considerations

**Current Pricing (as of Jan 2026):**

| Component | Price |
|-----------|-------|
| Storage | Varies by tier |
| Download egress | $0.01-0.02/GB |
| Minimum monthly | $5 |

**Egress Pricing:**
- Global Collaboration: 1X included, $0.02/GB additional
- Regional Workflows: 1X included, $0.01/GB additional
- Active Archive: $0.02/GB (no free egress)

---

## 5. Step-by-Step Connection Flow

### Step 1: Create Storj Account
1. Go to https://storj.io
2. Click "Sign Up" or "Start for Free"
3. Complete registration with email verification
4. Add payment method ($5 minimum monthly)

### Step 2: Create a Project
1. In Storj Console, click "Create New Project"
2. Name your project (e.g., "CloudSync Backup")
3. Note your Project ID

### Step 3: Create a Bucket
1. Navigate to Buckets in your project
2. Click "Create Bucket"
3. Enter bucket name (lowercase, no spaces)
4. Bucket is created with default settings

### Step 4: Generate Access Grant
1. Go to Access > Create Access Grant
2. Select permissions:
   - Read, Write, List, Delete (as needed)
3. Select buckets to grant access to
4. Enter encryption passphrase:
   - Option A: Use satellite-managed passphrase
   - Option B: Enter your own passphrase (SAVE IT SECURELY!)
   - Option C: Generate 12-word mnemonic
5. Click "Generate Access Grant"
6. **Copy and save the access grant string**

### Step 5: Configure in CloudSync Ultra
1. Open CloudSync Ultra
2. Add new cloud connection
3. Select "Storj"
4. Enter remote name (e.g., "storj-backup")
5. Paste the access grant
6. Test connection
7. Browse your bucket contents

---

## 6. Native vs S3 Gateway Comparison

### Native Storj Backend (`storj`)

| Aspect | Details |
|--------|---------|
| **Security** | Strong - encryption key never leaves local machine |
| **Privacy** | Full - Storj cannot access data or metadata |
| **Upload overhead** | ~2.7x (erasure coding locally) |
| **Download speed** | Faster (direct node connections) |
| **Connections** | High (110 upload, 35 download per 64MB) |
| **CPU usage** | Higher (local encryption) |

**Best For:**
- Desktop/server with good resources
- Privacy-focused users
- Maximum security requirements
- High-bandwidth connections

### S3 Gateway (`s3` with Storj endpoint)

| Aspect | Details |
|--------|---------|
| **Security** | Weaker - encryption key shared with gateway |
| **Privacy** | Reduced - Storj gateway has temporary access |
| **Upload overhead** | 1x (gateway handles erasure coding) |
| **Download speed** | Standard (single gateway connection) |
| **Connections** | Low (1 per transfer) |
| **CPU usage** | Lower (offloaded to gateway) |

**S3 Gateway Configuration:**
```
[storj-s3]
type = s3
provider = Storj
access_key_id = your-s3-access-key
secret_access_key = your-s3-secret-key
endpoint = gateway.storjshare.io
```

**Best For:**
- Edge devices with limited resources
- Limited bandwidth connections
- S3-compatible tool requirements
- Simpler deployment

### Recommendation

| Scenario | Recommendation |
|----------|----------------|
| Desktop app (CloudSync Ultra) | **Native backend** |
| Privacy-conscious users | **Native backend** |
| Constrained devices | S3 Gateway |
| Maximum upload speed | S3 Gateway |
| Maximum download speed | Native backend |
| Maximum security | Native backend |

**CloudSyncApp Decision:** The current implementation correctly uses the native `storj` backend, which is the recommended approach for a desktop application.

---

## 7. Implementation Recommendation

### Difficulty Rating: **EASY**

**Rationale:**
- Storj is already fully defined in CloudProvider.swift
- Setup function exists in RcloneManager.swift (simple, working)
- Performance optimizations configured (parallelism, chunk size)
- Multi-thread download support implemented (full capability)
- OAuth NOT required (access grant is text-based)

### Current Implementation Gaps

| Gap | Priority | Effort |
|-----|----------|--------|
| UI wizard for access grant input | High | 2 hours |
| Satellite selection dropdown | Low | 1 hour |
| Passphrase warning dialog | Medium | 1 hour |
| Link to Storj console for grant generation | Medium | 30 min |
| Help documentation | Medium | 1 hour |
| ulimit warning detection | Low | 2 hours |

### Code Changes Needed

**No core changes required.** The existing implementation is functional.

**Optional Enhancements:**

1. **Enhanced setup function with satellite selection:**
```swift
func setupStorj(
    remoteName: String,
    accessGrant: String? = nil,
    satellite: String? = nil,
    apiKey: String? = nil,
    passphrase: String? = nil
) async throws {
    var params: [String: String] = [:]

    if let accessGrant = accessGrant {
        // Preferred method: use serialized access grant
        params["access_grant"] = accessGrant
    } else if let satellite = satellite,
              let apiKey = apiKey,
              let passphrase = passphrase {
        // Alternative: generate access grant from components
        params["satellite_address"] = satellite
        params["api_key"] = apiKey
        params["passphrase"] = passphrase
    }

    try await createRemote(name: remoteName, type: "storj", parameters: params)
}
```

2. **Add Storj-specific wizard guidance:**
```swift
// In wizard configuration step
VStack(alignment: .leading, spacing: 8) {
    Text("Access Grant")
        .font(.headline)

    Text("Generate an access grant from the Storj Console. This includes your API key, satellite, and encryption settings.")
        .font(.caption)
        .foregroundColor(.secondary)

    Link("Open Storj Console",
         destination: URL(string: "https://storj.io/login")!)

    SecureField("Paste Access Grant", text: $accessGrant)

    // Warning about passphrase
    HStack {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.yellow)
        Text("Save your encryption passphrase securely. It cannot be recovered!")
            .font(.caption)
    }
}
```

3. **Chunk size flag is already NOT configured (correct):**
Storj does not have a provider-specific chunk size flag in rclone. The default 64MB segment size is handled automatically. This is correctly implemented - TransferOptimizer.swift does not return a chunk flag for Storj.

### Testing Checklist

- [ ] Access grant authentication
- [ ] Upload files to Storj bucket
- [ ] Download files from Storj bucket
- [ ] List bucket contents
- [ ] Multi-thread large file download
- [ ] Test with different satellites (US1, EU1, AP1)
- [ ] Verify encryption (files unreadable on Storj console)
- [ ] Test connection resilience
- [ ] Verify parallelism settings work correctly

---

## 8. Summary

| Aspect | Status | Notes |
|--------|--------|-------|
| Backend Support | Complete | Native `storj` backend |
| Authentication | Complete | Access grant method |
| Performance Optimization | Complete | Parallelism configured (16 transfers, 32 checkers) |
| Multi-thread Downloads | Complete | Full support |
| Client-side Encryption | Complete | Handled by native backend |
| UI Integration | Partial | Setup function exists, wizard enhancement needed |
| Documentation | Needed | Passphrase warnings, access grant generation guide |

**Overall Assessment:** Storj integration is **production-ready** with the current implementation. The native backend provides excellent security and performance for CloudSync Ultra users. Optional UI enhancements should focus on guiding users through access grant generation and emphasizing the critical importance of securely storing their encryption passphrase.

### Key Differentiators

1. **Security First:** Client-side encryption by default
2. **Decentralized:** No single point of failure, exceptional durability
3. **Privacy:** Storj cannot access user data
4. **Performance:** Direct node connections can outperform traditional cloud storage
5. **Cost:** Competitive pricing with simpler structure (especially with Nov 2025+ tiers)

---

## References

- [rclone Storj Backend Documentation](https://rclone.org/storj/)
- [Storj Native Integration Guide](https://storj.dev/dcs/third-party-tools/rclone/rclone-native)
- [Storj Access Grant Management](https://storj.dev/dcs/access)
- [Storj Encryption Keys Documentation](https://storj.dev/learn/concepts/access/encryption-and-keys)
- [Storj S3 Gateway Documentation](https://storj.dev/dcs/api/s3/s3-compatible-gateway)
- [Storj Linksharing Service](https://storj.dev/learn/concepts/linksharing-service)
- [Storj Pricing Overview](https://storj.dev/dcs/pricing)

---

*End of Integration Study*
