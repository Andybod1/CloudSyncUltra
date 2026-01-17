# Integration Study: Backblaze B2 Cloud Storage

**GitHub Issue:** #127
**Architect:** Architect-2
**Date:** 2026-01-17
**Status:** COMPLETE

---

## Executive Summary

Backblaze B2 is **fully implemented** in CloudSync Ultra with native rclone backend support. The integration is rated **EASY** - no code changes required. Users can connect to B2 immediately using the existing `setupBackblazeB2()` function.

---

## 1. Overview & rclone Backend Details

### Backend Type
CloudSync Ultra uses the **native B2 backend** (`b2`), NOT the S3-compatible interface.

```swift
// From CloudProvider.swift, line 273
case .backblazeB2: return "b2"
```

This is the correct choice because:
- Native B2 API is optimized for rclone
- Lower cost (fewer API transactions)
- Better large file handling
- Full feature support (versioning, lifecycle)

### Configuration Parameters

The rclone B2 backend requires:
| Parameter | Description | Required |
|-----------|-------------|----------|
| `account` | Application Key ID (not Account ID) | Yes |
| `key` | Application Key (secret) | Yes |

Sample rclone config:
```ini
[b2]
type = b2
account = 004XXXXXXXXX000000000XX
key = K004XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Current Implementation Status

**FULLY IMPLEMENTED** in `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`:

```swift
// Lines 1382-1391
func setupBackblazeB2(remoteName: String, accountId: String, applicationKey: String) async throws {
    try await createRemote(
        name: remoteName,
        type: "b2",
        parameters: [
            "account": accountId,
            "key": applicationKey
        ]
    )
}
```

### Performance Optimizations Already Configured

1. **Fast-list support** (CloudProvider.swift line 636):
   ```swift
   case .backblazeB2: return true  // supportsFastList
   ```

2. **Parallelism** (CloudProvider.swift lines 653-654):
   ```swift
   case .backblazeB2:
       return (transfers: 16, checkers: 32)  // High parallelism
   ```

3. **Chunk size** (TransferOptimizer.swift lines 29-32):
   ```swift
   case .backblazeB2:
       return 16 * 1024 * 1024  // 16MB chunks
   ```

---

## 2. Authentication Requirements

### Application Keys vs Master Keys

| Key Type | S3 API Support | Recommended | Use Case |
|----------|---------------|-------------|----------|
| **Master Key** | NO | Never for apps | Account recovery only |
| **Application Key** | YES | YES | All app connections |

**IMPORTANT:** CloudSync Ultra MUST use Application Keys, not Master Keys.

### Key Capabilities

When creating an Application Key for CloudSync Ultra, recommend these capabilities:

| Capability | Required | Purpose |
|------------|----------|---------|
| `listBuckets` | Yes | List available buckets |
| `listFiles` | Yes | Browse files |
| `readFiles` | Yes | Download files |
| `writeFiles` | Yes | Upload files |
| `deleteFiles` | Yes | Delete files |
| `listAllBucketNames` | Yes* | Required if bucket-restricted |

*Required for bucket-specific keys to work with SDKs.

### Bucket-Specific Keys

Users can create keys restricted to:
- **Single bucket** - Recommended for security
- **Multiple buckets** - Using `bucketIds` array
- **File prefix** - e.g., only access `backups/` folder

**Recommendation for CloudSync Ultra wizard:** Prompt users to create a bucket-specific key with all file capabilities for maximum security.

---

## 3. B2 Native vs S3 API Comparison

### Recommendation: Use Native B2 API

CloudSync Ultra correctly uses the native B2 API. Here's why:

| Feature | Native B2 | S3 Compatible |
|---------|-----------|---------------|
| **Cost** | Lower (optimized calls) | Higher (S3 overhead) |
| **Large files** | Optimized chunking | Standard S3 |
| **Key management** | Full support | No support |
| **Master key** | Works | NOT supported |
| **Object tagging** | Full | Empty set returned |
| **ACL granularity** | Full | Bucket-level only |
| **rclone backend** | `b2` (native) | `s3` (generic) |

### When S3 API Might Be Preferred

Only if:
- Migrating from existing S3 code
- Using S3-only tools
- Need exact S3 compatibility

**For CloudSync Ultra:** Native B2 is correct.

---

## 4. Known Limitations & Workarounds

### File Size Limits

| Limit | Value | Notes |
|-------|-------|-------|
| Single upload max | 5 GB | Use large file API above this |
| Large file max | 10 TB | Chunked uploads |
| Chunk size range | 5 MB - 5 GB | Configurable |
| Max parts | 10,000 | Per large file |
| Max file with 96MB chunks | ~937.5 GB | 10,000 x 96MB |

### Large File Handling (Chunked Uploads)

rclone handles this automatically:
- Files > `--b2-upload-cutoff` (default 200MB) use chunked upload
- CloudSync Ultra configured for 16MB chunks (optimal balance)
- SHA-1 checksums verified per chunk

**Workaround for >937.5GB files:**
Increase chunk size: `--b2-chunk-size=1G` allows up to ~10TB files.

### File Versioning Considerations

**Default behavior:** B2 keeps ALL versions forever.

| When you... | What happens |
|-------------|--------------|
| Upload new version | Old version hidden, still stored |
| Delete file | "Hide marker" added, file retained |
| Use `--b2-hard-delete` | Permanently removes files |

**Recommendations for CloudSync Ultra:**

1. **Sync operations:** Consider `--b2-hard-delete` to avoid version buildup
2. **Backup operations:** Keep versioning (data protection)
3. **Cost control:** Set lifecycle rules

### Hidden Files (Lifecycle Rules)

B2 lifecycle rules can automatically:
- Hide files after N days
- Delete hidden files after N days
- Clean up incomplete uploads

**Timing:**
- Rules apply every 24 hours
- Initial activation takes 24-48 hours

**rclone cleanup commands:**
```bash
# Remove old hidden versions
rclone backend cleanup-hidden b2:bucket

# Remove incomplete uploads older than 1 hour
rclone backend cleanup b2:bucket -o max-age=1h
```

---

## 5. Step-by-Step Connection Flow

### For CloudSync Ultra Users

#### Step 1: Create Backblaze Account
1. Visit [backblaze.com](https://www.backblaze.com)
2. Sign up for B2 Cloud Storage
3. First 10GB free

#### Step 2: Create a Bucket
1. Log into Backblaze console
2. Go to B2 Cloud Storage > Buckets
3. Click "Create a Bucket"
4. Choose:
   - **Bucket name:** Globally unique (e.g., `myname-cloudsync-backup`)
   - **Privacy:** Private (recommended)
   - **Default Encryption:** Server-Side (recommended)
   - **Object Lock:** Optional (prevents deletion)

#### Step 3: Create Application Key
1. Go to B2 Cloud Storage > Application Keys
2. Click "Add a New Application Key"
3. Configure:
   - **Name:** `cloudsync-ultra` (descriptive)
   - **Bucket:** Select your bucket (recommended) or "All"
   - **Type of Access:** Read and Write
   - **File name prefix:** Leave empty (or restrict to folder)
   - **Duration:** Leave blank (no expiration) or set as needed
   - **Allow List All Bucket Names:** YES (required for bucket-specific keys)

4. **SAVE IMMEDIATELY:**
   - Copy `keyID` (this is the "account" in rclone)
   - Copy `applicationKey` (this is the "key" in rclone)
   - This key is shown ONCE only!

#### Step 4: Connect in CloudSync Ultra
1. Open CloudSync Ultra
2. Add new connection > Backblaze B2
3. Enter:
   - **Key ID:** (from step 3)
   - **Application Key:** (from step 3)
4. Test connection
5. Browse buckets and files

### Permission Requirements Summary

| Permission | Purpose |
|------------|---------|
| Read and Write access | Full file operations |
| List All Bucket Names | Required for bucket-restricted keys |
| Bucket-specific (optional) | Enhanced security |

---

## 6. Cost Considerations

### Storage Pricing

| Tier | Price | Notes |
|------|-------|-------|
| First 10 GB | FREE | Forever |
| Storage | $6/TB/month | Simple, no tiers |
| B2 Reserve | $5/TB/month | Committed contracts |

### Egress (Download) Pricing

| Scenario | Price |
|----------|-------|
| First 3x storage | FREE | e.g., 1TB stored = 3TB egress free |
| Beyond 3x | $0.01/GB | Very low |
| To CDN partners | FREE UNLIMITED | Cloudflare, Fastly, etc. |

**CDN Partners with Free Egress:**
- Cloudflare
- Fastly
- bunny.net
- CacheFly
- Vultr
- CoreWeave
- Equinix Metal
- phoenixNAP

### API Transaction Pricing

| Operation | Free Tier | Beyond Free |
|-----------|-----------|-------------|
| Class A (list, write) | 2,500/day | $0.004/1,000 |
| Class B (read, download) | 2,500/day | $0.004/1,000 |
| Class C (other) | Free | Free |

### Cost Optimization Tips

1. **Use `--fast-list`** - Fewer API calls (already enabled in CloudSync Ultra)
2. **Batch operations** - Reduce transaction count
3. **Use lifecycle rules** - Auto-delete old versions
4. **Consider CDN partner** - Zero egress fees

### Cost Comparison

| Provider | Storage/TB | Egress/GB |
|----------|------------|-----------|
| **Backblaze B2** | $6 | $0.01 (free to partners) |
| AWS S3 Standard | $23 | $0.09 |
| Google Cloud | $20 | $0.12 |
| Azure Blob | $18 | $0.087 |

**B2 is 75% cheaper than major cloud providers.**

---

## 7. Implementation Recommendation

### Difficulty Rating: EASY

| Aspect | Status | Notes |
|--------|--------|-------|
| Backend support | COMPLETE | Native `b2` type |
| Setup function | COMPLETE | `setupBackblazeB2()` |
| Fast-list | COMPLETE | Enabled |
| Parallelism | COMPLETE | 16 transfers, 32 checkers |
| Chunk sizing | COMPLETE | 16MB optimized |

### Code Changes Needed: NONE

The existing implementation in CloudSync Ultra fully supports Backblaze B2.

### UI/UX Recommendations (Optional Enhancements)

1. **Connection Wizard Enhancement:**
   - Add link to Backblaze key creation page
   - Explain that Application Key (not Master Key) is required
   - Validate key format before testing

2. **Transfer Settings:**
   - Consider exposing `--b2-hard-delete` option for sync
   - Add lifecycle rule helper (display estimated costs)

3. **Help Text:**
   - Mention 10GB free tier
   - Link to CDN partner program

### Testing Checklist

- [x] Backend type correctly configured as `b2`
- [x] Setup function accepts account ID and key
- [x] Fast-list enabled
- [x] Parallelism optimized (16/32)
- [x] Chunk size optimized (16MB)
- [ ] Test large file upload (>5GB)
- [ ] Test bucket-specific key connection
- [ ] Verify versioning behavior

---

## References

- [rclone B2 Documentation](https://rclone.org/b2/)
- [Backblaze B2 + rclone Integration Guide](https://www.backblaze.com/docs/cloud-storage-integrate-rclone-with-backblaze-b2)
- [B2 vs S3 API Comparison](https://www.backblaze.com/blog/whats-the-diff-backblaze-s3-compatible-api-vs-b2-native-api/)
- [B2 Pricing](https://www.backblaze.com/cloud-storage/pricing)
- [Application Key Capabilities](https://www.backblaze.com/docs/cloud-storage-application-key-capabilities)
- [Large Files Documentation](https://www.backblaze.com/docs/cloud-storage-large-files)
- [Lifecycle Rules](https://www.backblaze.com/docs/cloud-storage-lifecycle-rules)

---

## Conclusion

Backblaze B2 integration in CloudSync Ultra is **production-ready**. The native B2 backend is correctly implemented with optimal performance settings. Users can connect immediately - no development work required.

**Recommendation:** Proceed with B2 as a supported provider. Consider minor UX enhancements in the connection wizard to guide users through Application Key creation.
