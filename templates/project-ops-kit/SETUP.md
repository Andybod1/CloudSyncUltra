# {{PROJECT_NAME}} - Setup Guide

Complete setup guide for {{PROJECT_NAME}}.

## Prerequisites

### System Requirements
- **macOS {{MIN_OS_VERSION}}+** or later
- **Xcode {{XCODE_VERSION}}+** (for building from source)
- **8 GB RAM** recommended
- **500 MB disk space**

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Dependencies

```bash
{{DEPENDENCY_INSTALL_COMMAND}}
```

Verify installation:
```bash
# Verify dependencies are installed
# {{DEPENDENCY_VERIFY_COMMAND}}
```

## Building the App

### Method 1: Xcode (Recommended)

1. **Open the project:**
```bash
cd {{PROJECT_PATH}}
open {{PROJECT_FILE}}
```

2. **Configure signing:**
   - Select project in navigator
   - Select "{{PROJECT_NAME}}" target
   - Go to "Signing & Capabilities"
   - Select your Team or "Sign to Run Locally"

3. **Build & Run:**
   - Press `⌘R` or click Play button
   - Main window opens automatically
   - Menu bar icon also appears

### Method 2: Command Line

```bash
cd {{PROJECT_PATH}}

# Debug build
{{BUILD_COMMAND}}

# Run
{{LAUNCH_COMMAND}}
```

### Method 3: Release Build

```bash
# Build release
xcodebuild -project {{PROJECT_FILE}} \
           -scheme {{PROJECT_NAME}} \
           -configuration Release \
           build

# Copy to Applications
cp -r ~/Library/Developer/Xcode/DerivedData/{{PROJECT_DIR}}-*/Build/Products/Release/{{PROJECT_NAME}}.app /Applications/

# Launch
open /Applications/{{PROJECT_NAME}}.app
```

## First-Time Setup (Interactive Onboarding)

{{PROJECT_NAME}} includes an **interactive onboarding wizard** that guides you through setup.

### Step 1: Welcome Screen

On first launch, you'll see the onboarding wizard:
1. **Welcome** - Overview of {{PROJECT_NAME}} features
2. **Configuration** - Set up your first item
3. **First Action** - Try your first workflow
4. **Complete** - Start using the app

### Step 2: Initial Configuration (Wizard)

The **Configuration Wizard** guides you through setup:

1. Click **"Get Started"** button
2. **Select Options** - Choose from available options
3. **Configure Settings** - Customize your preferences
4. **Verify** - Wizard confirms everything works
5. Click **"Finish"** to complete

### Step 3: Try Your First Action

The onboarding offers a **"Try Now"** button:

1. Click the button to start the action wizard
2. **Select Source** - Choose your starting point
3. **Configure Options** - Set up the operation
4. **Execute** - Complete the action
5. Monitor progress in the **Tasks** view

### Step 4: Explore the App

After onboarding, you'll see the main window:
- **Sidebar** - Navigation to all features
- **Dashboard** - Overview of configured items and recent activity
- **Menu bar icon** - Quick access even when window is closed

## Using Wizards

{{PROJECT_NAME}} includes wizards for common tasks:

### Configuration Wizard

Add new configurations:
1. Click **"Add..."** in sidebar, or
2. Use **Cmd+N** keyboard shortcut
3. Follow the guided steps

### Schedule Wizard

Set up automatic tasks:
1. Go to **Tasks** in sidebar
2. Click **"New Scheduled Task"**
3. Configure:
   - Source and destination
   - Frequency (hourly, daily, weekly)
   - Time preferences
4. Enable and save

### Action Wizard

Perform one-time operations:
1. Go to **Actions** in sidebar
2. Click **"New Action"** or use the wizard button
3. Select source, destination, and options
4. Review preview (dry-run option available)
5. Execute

## Keyboard Navigation

{{PROJECT_NAME}} supports comprehensive keyboard navigation:

### Global Shortcuts
| Shortcut | Action |
|----------|--------|
| `⌘N` | Add new item |
| `⌘,` | Open Settings |
| `⌘⇧N` | Quick Actions menu |
| `⌘1-9` | Switch sidebar sections |

### Content Navigation
| Shortcut | Action |
|----------|--------|
| `↑/↓` | Navigate items |
| `⏎` | Open / Select |
| `⌘↑` | Go to parent |
| `Space` | Quick Look preview |
| `⌘A` | Select all |
| `⌘⇧A` | Deselect all |
| `Delete` | Delete selected (with confirmation) |

## Settings Overview

### General Tab
- **Launch at Login** — Start automatically
- **Show in Dock** — Toggle dock icon
- **Notifications** — Enable/disable alerts
- **Sound Effects** — Audio feedback

### Accounts Tab
- List of configured accounts/services
- Add/remove connections via wizard
- Test connection status
- Credential management

### About Tab
- Version information (currently {{VERSION}})
- Links to documentation
- Credits

## Menu Bar Usage

Even with the main window closed, you can:

**Click menu bar icon** to see:
- Current status (Idle/Working/Error)
- Last operation time
- Active tasks count
- **Run Now** — Trigger immediate action
- **Pause/Resume** — Control auto-tasks
- **Open Main Window**
- **Preferences** — Open settings
- **Quit** — Exit app

**Icon states**:
- ☁️ Cloud — Idle, all done
- ↻ Arrows — Working
- ✓ Checkmark — Just completed
- ⚠️ Warning — Error occurred

## Verification

### Test Basic Operation

1. Go to main view
2. Select an item
3. Perform an action
4. Check **Tasks** view for progress
5. Verify operation completed

### Test Automatic Tasks

1. Configure task via **Schedule Wizard** or **Settings**
2. Set short interval (1 minute for testing)
3. Enable auto-run
4. Wait for task to trigger
5. Verify completion

### Test Preview (Dry Run)

1. Go to action view
2. Select items for operation
3. Click **Preview** button
4. Review what would happen without executing
5. Confirm or cancel

## Permissions

### Full Disk Access (if needed)

Some folders require special permissions:

1. **System Settings** → **Privacy & Security**
2. **Full Disk Access**
3. Click **+** button
4. Navigate to {{PROJECT_NAME}}.app
5. Add to list
6. Restart {{PROJECT_NAME}}

### Network Access

First launch may prompt:
> "{{PROJECT_NAME}} would like to access the network"

Click **Allow** — required for network operations.

## Troubleshooting

### "Dependency not found"

```bash
# Install
{{DEPENDENCY_INSTALL_COMMAND}}

# Verify
which <dependency>
```

### "Connection failed"

1. Verify credentials work
2. Check internet connection
3. Re-run the Configuration Wizard
4. Check Console.app for detailed errors

### "Build failed" in Xcode

1. **Clean**: Product → Clean Build Folder (⌘⇧K)
2. **Check target**: macOS {{MIN_OS_VERSION}}+
3. **Check signing**: Select valid team
4. Delete DerivedData and rebuild

### "Operations not running"

1. Check configuration path is correct
2. Verify available resources
3. Check Tasks view for errors
4. Try manual "Run Now" in menu bar
5. Check if schedule is paused

### "Permission denied"

```bash
# Fix script permissions
chmod +x scripts/*.sh
chmod +x .claude-team/scripts/*.sh
```

## Advanced Setup

### Multiple Configurations

1. Use the **Configuration Wizard** for each item
2. Give unique names
3. Each appears in sidebar
4. Operate between any combination

### Import Existing Configuration

If you have an existing setup:

1. Go to **Settings** → **Import**
2. Select your configuration file
3. Items are imported automatically

## Test Checklist

- [ ] Dependencies installed and working
- [ ] App builds without errors
- [ ] Main window opens
- [ ] Onboarding wizard appears on first launch
- [ ] Can add configurations via wizard
- [ ] Can browse content
- [ ] Can perform operations
- [ ] Preview (dry-run) works
- [ ] Auto tasks trigger on schedule
- [ ] Menu bar shows correct status
- [ ] Keyboard shortcuts work
- [ ] Settings save correctly

## Next Steps

After setup:
1. **Configure all items** using the Configuration Wizard
2. **Set up automatic tasks** via the Schedule Wizard
3. **Learn keyboard shortcuts** for power-user efficiency
4. **Configure performance** settings for your needs
5. **Test workflows** to verify everything works
6. **Review history** to monitor operations

---

**Setup Guide Version**: {{VERSION}}
**Last Updated**: {{DATE}}
**Platform**: macOS {{MIN_OS_VERSION}}+
