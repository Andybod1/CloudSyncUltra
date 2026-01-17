# Getting Started

Set up CloudSync Ultra and connect your first cloud provider.

## Overview

CloudSync Ultra requires rclone as its backend for cloud storage operations. This guide walks you through the initial setup process.

### Requirements

- macOS 14.0 (Sonoma) or later
- [rclone](https://rclone.org/) installed via Homebrew
- Xcode 15.0+ (for building from source)

### Installation

1. Install rclone:

```bash
brew install rclone
```

2. Clone and build the project:

```bash
git clone https://github.com/andybod1-lang/CloudSyncUltra.git
cd CloudSyncUltra
open CloudSyncApp.xcodeproj
```

3. Build and run with ⌘R

### First Launch

On first launch, the Interactive Onboarding Wizard guides you through:

1. **Welcome** - Overview of features
2. **Add Provider** - Connect your first cloud service
3. **First Sync** - Test a transfer
4. **Complete** - Start using the app

### Adding a Cloud Provider

Use the Provider Connection Wizard to add cloud services:

1. Click the **+** button in the sidebar
2. Select your provider from the list
3. Follow the authentication steps (OAuth or credentials)
4. Your provider appears in the sidebar

### Creating a Scheduled Sync

Set up automated backups with the Schedule Wizard:

1. Go to **Tasks** → **New Schedule**
2. Select source and destination
3. Choose frequency (hourly, daily, weekly)
4. Enable encryption if desired
5. Save and activate

## See Also

- <doc:Architecture>
- ``RcloneManager``
- ``CloudProvider``
