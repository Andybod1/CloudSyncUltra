# Integration Study #132: Oracle Cloud Object Storage

**Architect:** Architect-3
**Date:** 2026-01-18
**Status:** Complete

## Executive Summary

Oracle Cloud Infrastructure (OCI) Object Storage is well-supported in CloudSync Ultra. The current implementation uses the S3-compatible backend, which is functional for basic operations. However, rclone also provides a native `oracleobjectstorage` backend with more advanced features including multiple authentication methods and better integration with OCI-specific features.

## Current Implementation Status

### CloudSync Ultra Integration

**Location:** `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`

Oracle Cloud is already integrated as a provider:

```swift
case oracleCloud = "oraclecloud"  // Line 40

// Display name
case .oracleCloud: return "Oracle Cloud"  // Line 99

// Icon
case .oracleCloud: return "building.2.fill"  // Line 159

// Brand color
case .oracleCloud: return Color(hex: "F80000")  // Oracle Red, Line 219

// rclone type (currently S3)
case .oracleCloud: return "s3"  // Line 278
```

**RcloneManager Setup Function:** `/Users/antti/claude/CloudSyncApp/RcloneManager.swift` (Lines 1496-1507)

```swift
func setupOracleCloud(remoteName: String, namespace: String, compartment: String,
                      region: String, accessKey: String, secretKey: String) async throws {
    let params: [String: String] = [
        "type": "s3",
        "provider": "Other",
        "access_key_id": accessKey,
        "secret_access_key": secretKey,
        "region": region,
        "endpoint": "https://\(namespace).compat.objectstorage.\(region).oraclecloud.com"
    ]

    try await createRemote(name: remoteName, type: "s3", parameters: params)
}
```

**Note:** The `compartment` parameter is accepted but not currently used in the S3-compatible configuration.

### Optimization Settings

Oracle Cloud is included in:
- **Fast-list support:** Yes (Line 639)
- **Default parallelism:** 16 transfers, 32 checkers (Line 653)
- **Chunk size:** 16MB (TransferOptimizer.swift, Line 30)

## rclone Backend Options

### Option 1: S3-Compatible Backend (Current Implementation)

Uses rclone's S3 backend with Oracle-specific endpoint.

**Configuration:**
```ini
[oracle]
type = s3
provider = Other
access_key_id = YOUR_ACCESS_KEY
secret_access_key = YOUR_SECRET_KEY
region = us-ashburn-1
endpoint = https://NAMESPACE.compat.objectstorage.REGION.oraclecloud.com
```

**Pros:**
- Simple setup with Access Key/Secret Key
- Familiar S3 API
- Works with existing S3-related optimizations in CloudSync

**Cons:**
- Requires S3-compatible API keys (separate from OCI API keys)
- Limited to S3 API capabilities
- No access to OCI-specific features

### Option 2: Native OCI Backend (Recommended Upgrade)

Uses rclone's dedicated `oracleobjectstorage` backend.

**Configuration:**
```ini
[oracle]
type = oracleobjectstorage
provider = user_principal_auth
namespace = YOUR_NAMESPACE
compartment = ocid1.compartment.oc1..xxxxx
region = us-ashburn-1
config_file = ~/.oci/config
config_profile = DEFAULT
```

**Pros:**
- Multiple authentication methods (6 options)
- Access to OCI-specific features (storage tiers, lifecycle policies)
- Better integration with OCI IAM
- Supports compartment-based organization
- Instance principal auth for OCI compute instances

**Cons:**
- More complex initial setup
- Requires OCI SDK configuration for some auth methods

## Authentication Methods

### 1. S3-Compatible Access (Current)

**Required Credentials:**
- Access Key ID
- Secret Access Key
- Namespace (part of endpoint)
- Region

**How to obtain:**
1. OCI Console > Identity & Security > Users
2. Select user > Customer Secret Keys
3. Generate new secret key

### 2. User Principal Auth (Native Backend)

**Required:**
- Tenancy OCID
- User OCID
- API Key fingerprint
- Private key file path
- Region

**Configuration file:** `~/.oci/config`

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaxxxxxx
fingerprint=xx:xx:xx:xx:xx:xx:xx:xx
key_file=/path/to/private-key.pem
tenancy=ocid1.tenancy.oc1..aaaaaaaxxxxxx
region=us-ashburn-1
```

### 3. Instance Principal Auth

For workloads running on OCI compute instances.

**Required:**
- Instance must be in a dynamic group
- Policies granting object storage access

**rclone config:**
```ini
[oracle]
type = oracleobjectstorage
provider = instance_principal_auth
namespace = YOUR_NAMESPACE
region = us-ashburn-1
```

### 4. Resource Principal Auth

For OCI Functions and serverless workloads.

### 5. Workload Identity

For Kubernetes pods on OKE (Container Engine for Kubernetes).

### 6. No Authentication

For public buckets only.

## OCI Regions

Oracle Cloud has 45+ regions globally. Major regions include:

| Region Name | Region Identifier | Notes |
|-------------|-------------------|-------|
| US East (Ashburn) | us-ashburn-1 | 3 ADs |
| US West (Phoenix) | us-phoenix-1 | 3 ADs |
| Germany (Frankfurt) | eu-frankfurt-1 | 3 ADs |
| UK South (London) | uk-london-1 | 3 ADs |
| Japan East (Tokyo) | ap-tokyo-1 | 1 AD |
| Australia East (Sydney) | ap-sydney-1 | 1 AD |
| Brazil East (Sao Paulo) | sa-saopaulo-1 | 1 AD |
| Canada Southeast (Toronto) | ca-toronto-1 | 1 AD |
| Singapore | ap-singapore-1 | 1 AD |

**Region selection in endpoint:** `https://{namespace}.compat.objectstorage.{region}.oraclecloud.com`

## Namespace and Compartment Handling

### Namespace

- **Definition:** Unique identifier for your tenancy's Object Storage
- **Format:** Alphanumeric string (e.g., `axw0ghxu42yq`)
- **How to find:** OCI Console > Tenancy Details > Object Storage Namespace
- **Required for:** Endpoint construction in S3 mode, all operations in native mode

### Compartment

- **Definition:** Logical container for organizing resources
- **Format:** OCID (e.g., `ocid1.compartment.oc1..aaaaaaaxxxxxx`)
- **Required for:** Bucket listing operations
- **Note:** Individual object operations can work without compartment OCID

## Storage Tiers

OCI Object Storage supports three tiers:

| Tier | Use Case | Availability |
|------|----------|--------------|
| Standard | Frequently accessed data | Immediate |
| InfrequentAccess | Accessed less than once per month | Immediate |
| Archive | Long-term retention | Restore required (hours) |

**rclone parameter:** `--oos-storage-tier`

## Recommended Wizard Flow

### Step 1: Choose Connection Method

```
Oracle Cloud Object Storage
---------------------------
How would you like to connect?

( ) S3-Compatible API (Simple)
    Use Access Key and Secret Key

( ) OCI API Key (Advanced)
    Use OCI configuration file

[ Learn more about Oracle Cloud authentication ]
```

### Step 2a: S3-Compatible Setup

```
S3-Compatible Connection
------------------------

Namespace: [____________]
  Found in OCI Console > Tenancy Details

Region: [us-ashburn-1      v]
  Select your bucket's region

Access Key ID: [____________]
Secret Access Key: [************]
  Generate at: Identity > Users > Customer Secret Keys

[ Test Connection ]
```

### Step 2b: OCI API Key Setup (Future Enhancement)

```
OCI API Key Connection
----------------------

Namespace: [____________]
Compartment OCID: [ocid1.compartment.oc1..____]
  Optional - required for bucket listing

OCI Config File: [~/.oci/config        ] [Browse]
Config Profile: [DEFAULT               ]

[ Test Connection ]
```

### Step 3: Test Connection

```
Testing Connection...
---------------------

[✓] Credentials validated
[✓] Namespace confirmed: axw0ghxu42yq
[✓] Region accessible: us-ashburn-1
[✓] Buckets accessible: 3 found

[ Continue ]
```

### Step 4: Success

```
Oracle Cloud Connected!
-----------------------

You can now browse and sync files with Oracle Cloud Object Storage.

[ Browse Files ] [ Start Syncing ] [ Add Another ]
```

## Implementation Recommendations

### Phase 1: Enhance Current S3 Implementation (Low Effort)

1. **Add namespace validation:** Check namespace format before constructing endpoint
2. **Add region picker:** Dropdown with OCI regions
3. **Improve error messages:** Handle OCI-specific error codes

### Phase 2: Native Backend Support (Medium Effort)

1. **Add `oracleobjectstorage` backend option:**
   ```swift
   case .oracleCloud: return "oracleobjectstorage"  // Native backend
   ```

2. **Update RcloneManager:**
   ```swift
   func setupOracleCloudNative(remoteName: String,
                               namespace: String,
                               compartment: String?,
                               region: String,
                               configFile: String = "~/.oci/config",
                               configProfile: String = "DEFAULT") async throws {
       var params: [String: String] = [
           "type": "oracleobjectstorage",
           "provider": "user_principal_auth",
           "namespace": namespace,
           "region": region,
           "config_file": configFile,
           "config_profile": configProfile
       ]

       if let compartment = compartment {
           params["compartment"] = compartment
       }

       try await createRemote(name: remoteName, type: "oracleobjectstorage", parameters: params)
   }
   ```

3. **Add storage tier support in transfer options**

### Phase 3: Advanced Features (Higher Effort)

1. **Instance principal detection:** Auto-detect when running on OCI compute
2. **Compartment browser:** List available compartments for selection
3. **Lifecycle policy integration:** Expose tier transitions in UI

## Wizard Configuration Fields

### S3-Compatible Mode (Minimum Required)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Namespace | Text | Yes | Object Storage namespace |
| Region | Picker | Yes | OCI region identifier |
| Access Key ID | Text | Yes | S3-compatible access key |
| Secret Access Key | SecureField | Yes | S3-compatible secret key |

### Native Mode (Full)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Namespace | Text | Yes | Object Storage namespace |
| Region | Picker | Yes | OCI region identifier |
| Compartment | Text | No* | Compartment OCID (*required for bucket listing) |
| Config File | FilePicker | Yes | Path to OCI config file |
| Config Profile | Text | No | Profile name in config (default: DEFAULT) |
| Auth Provider | Picker | Yes | Authentication method |

## Testing Checklist

- [ ] S3-compatible connection with valid credentials
- [ ] Endpoint construction with various region codes
- [ ] Namespace validation
- [ ] Bucket listing with/without compartment
- [ ] File upload/download operations
- [ ] Large file multipart upload (>5GB)
- [ ] Storage tier selection (Standard, InfrequentAccess, Archive)
- [ ] Error handling for invalid namespace/region combinations

## References

- [rclone S3 Oracle OCI Documentation](https://rclone.org/s3/#oracle-cloud-infrastructure-object-storage)
- [rclone Oracle Object Storage (Native)](https://rclone.org/oracleobjectstorage/)
- [OCI Regions and Availability Domains](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)
- [OCI Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)

## Conclusion

Oracle Cloud Object Storage is already functional in CloudSync Ultra via the S3-compatible backend. The current implementation handles the core use case of Access Key/Secret Key authentication well. For enhanced functionality, consider adding support for the native `oracleobjectstorage` backend which enables:

1. OCI API key authentication (more secure, standard OCI practice)
2. Instance principal auth (keyless auth for OCI workloads)
3. Proper compartment organization
4. Storage tier management

The S3-compatible mode should remain as the default "simple" option, with native mode as an "advanced" option for users who need OCI-specific features.
