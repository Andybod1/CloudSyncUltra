# Bandwidth Throttling Feature

## Overview

CloudSync Ultra now includes bandwidth throttling controls to help you manage your network usage during sync, transfer, download, and upload operations.

## Location

**Settings → Sync → Bandwidth Throttling**

## Features

### Enable/Disable Bandwidth Limits
- Toggle to enable or disable bandwidth throttling
- When disabled, all operations run at maximum speed

### Upload Limit
- Set maximum upload speed in MB/s
- Applies to all upload operations (sync, transfer, upload)
- Set to 0 for unlimited upload speed

### Download Limit
- Set maximum download speed in MB/s
- Applies to all download operations (sync, transfer, download)
- Set to 0 for unlimited download speed

## How It Works

The bandwidth throttling feature integrates with rclone's `--bwlimit` flag to control transfer speeds. When enabled, all file operations will respect the configured limits:

### Affected Operations
- ✅ Cloud-to-cloud transfers
- ✅ Cloud-to-local downloads
- ✅ Local-to-cloud uploads
- ✅ Sync operations (both one-way and bi-directional)

### Technical Details
- Limits are applied per rclone process
- Bandwidth is measured in megabytes per second (MB/s)
- Settings persist across app restarts (stored in UserDefaults)
- Changes take effect immediately for new operations

## Usage Examples

### Example 1: Gentle Background Sync
**Scenario:** You want to sync files in the background without affecting your video calls.
**Settings:**
- Upload Limit: 2 MB/s
- Download Limit: 3 MB/s

### Example 2: Nighttime Batch Upload
**Scenario:** Large file uploads at night when bandwidth is less critical.
**Settings:**
- Upload Limit: 0 (unlimited)
- Download Limit: 0 (unlimited)

### Example 3: Metered Connection
**Scenario:** Using mobile hotspot or limited data connection.
**Settings:**
- Upload Limit: 0.5 MB/s
- Download Limit: 1 MB/s

## Configuration

1. Open CloudSync Ultra
2. Go to **Settings** (⌘,)
3. Navigate to the **Sync** tab
4. Scroll to **Bandwidth Throttling** section
5. Enable the toggle
6. Set your desired limits
7. Click **Save Settings**

## Tips

- **Leave at 0 for unlimited** - If you don't need limits, set both to 0
- **Start conservative** - Begin with lower limits and increase as needed
- **Monitor your connection** - Use Activity Monitor to see actual bandwidth usage
- **Different limits per operation** - Currently uses the more restrictive limit when both are set

## Storage

Settings are stored in macOS UserDefaults at:
- `bandwidthLimitEnabled` - Boolean flag
- `uploadLimit` - Double (MB/s)
- `downloadLimit` - Double (MB/s)

## Future Enhancements

Potential improvements for future versions:
- Per-remote bandwidth limits
- Separate upload/download limits per operation type
- Scheduled bandwidth limits (e.g., slower during business hours)
- Real-time bandwidth usage display
- Bandwidth usage statistics and history
