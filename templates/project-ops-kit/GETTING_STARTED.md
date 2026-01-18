# Getting Started with {{PROJECT_NAME}}

## What is {{PROJECT_NAME}}?

{{PROJECT_DESCRIPTION}}

### Key Features
<!-- Customize features for your project -->
- 🎯 **Feature 1** - Description
- 📁 **Feature 2** - Description
- 🔒 **Feature 3** - Description
- ⚡ **Feature 4** - Description
- 🧙 **Setup Wizards** - Guided configuration
- 🎯 **Quick Actions** - Keyboard-driven productivity (Cmd+Shift+N)
- ⌨️ **Full Keyboard Navigation** - Control the entire app without a mouse
- 🖥️ **Native macOS** - Beautiful SwiftUI interface with dark mode support

## Prerequisites

### System Requirements
- ✅ macOS {{MIN_OS_VERSION}} or later
- ✅ 200 MB free disk space
- ✅ Internet connection

### Required Software
- **Xcode {{XCODE_VERSION}}+** (for building from source) - [Download from Mac App Store](https://apps.apple.com/app/xcode/id497799835)
- **Dependencies** (installed automatically or manually)

### Installing Dependencies
```bash
# Option 1: Using Homebrew (recommended)
{{DEPENDENCY_INSTALL_COMMAND}}

# Verify installation
# {{DEPENDENCY_VERIFY_COMMAND}}
```

## Quick Install

### Option 1: Download Release
Pre-built releases are available on the [releases page]({{GITHUB_URL}}/releases).

### Option 2: Build from Source
```bash
# Clone the repository
git clone {{GITHUB_URL}}.git
cd {{PROJECT_DIR}}

# Build using Xcode
open {{PROJECT_FILE}}
# Press ⌘R to build and run

# Or build from command line
{{BUILD_COMMAND}}

# Launch the app
{{LAUNCH_COMMAND}}
```

## First Launch (Interactive Onboarding)

### 1. Launch the App
- Look for **{{PROJECT_NAME}}** in your Applications folder or build output
- The app opens with a full window interface
- You'll also see an icon in your menu bar

### 2. Interactive Onboarding Wizard
New users are guided through a multi-step interactive onboarding:

#### Step 1: Welcome
Introduction to {{PROJECT_NAME}}'s capabilities and what you can do with it.

#### Step 2: Initial Configuration
- Follow the guided setup
- Configure your first item
- Once complete, you'll see a ✓ checkmark confirming success

#### Step 3: First Action
- Try your first action with guidance
- Complete your first workflow
- A ✓ checkmark confirms completion

#### Step 4: Complete
- Review quick tips for power users
- Click "Get Started" to enter the main app

You can skip onboarding anytime, but the interactive steps help you learn faster.

### 3. Main Interface Overview

```
┌─────────────────────────────────────────────────────────────┐
│  {{PROJECT_NAME}}                                 ─ □ ×     │
├─────────────┬───────────────────────────────────────────────┤
│             │                                               │
│  Dashboard  │   Welcome to {{PROJECT_NAME}}                 │
│  Feature 1  │                                               │
│  Feature 2  │   Ready to get started                        │
│  Tasks      │                                               │
│  History    │   [Get Started Button]                        │
│             │                                               │
│ ─────────── │                                               │
│ ITEMS       │                                               │
│  + Add...   │                                               │
│             │                                               │
│ ─────────── │                                               │
│  Settings   │                                               │
│             │                                               │
└─────────────┴───────────────────────────────────────────────┘
```

## Key Features to Try

### 🧙 Setup Wizards
Wizards make complex tasks simple:
- **Configuration Wizard** - Guided step-by-step setup
- **Schedule Wizard** - Set up automatic tasks easily
- **Action Wizard** - Execute operations with preview option

### 🎯 Quick Actions (Cmd+Shift+N)
Access common operations instantly:
- Action 1
- Action 2
- Action 3
- Action 4

### ⌨️ Keyboard Navigation
Full keyboard support throughout the app:

| Shortcut | Action |
|----------|--------|
| `⌘N` | Add new item |
| `⌘,` | Open Settings |
| `⌘⇧N` | Quick Actions menu |
| `↑/↓` | Navigate items |
| `⏎` | Open / Select |
| `Space` | Quick Look preview |
| `⌘A` | Select all |
| `Delete` | Delete selected |

### 📊 Dashboard
Your command center showing:
- Connected services
- Usage statistics
- Recent activity
- Quick stats

## Tips for Success

### Start Small
- Test with small operations first
- Verify completion successfully
- Then move to larger operations

### Use Wizards
- Wizards prevent mistakes
- They validate each step
- Great for learning the app

### Use Preview Mode
- Always preview large operations
- Check the operation summary
- Avoid surprises with dry-run

## Common Tasks

### Basic Operations
1. Navigate to your content
2. Select items
3. Perform actions
4. Monitor progress

### Automated Tasks
1. Use the Schedule Wizard
2. Configure frequency
3. Enable the schedule
4. Tasks run automatically

## Menu Bar Features

Click the menu bar icon to:
- See status
- View next scheduled task
- Active operations count
- Quick action now
- Open main window
- Access preferences

Status Icons:
- ☁️ - Idle, no active operations
- 🔄 - Working
- ✓ - Last operation successful
- ⚠️ - Error occurred (click for details)

## Troubleshooting

### "Dependency not found"
```bash
# Install via Homebrew
{{DEPENDENCY_INSTALL_COMMAND}}

# Verify installation
which <dependency>
```

### "Connection failed"
1. Check your internet connection
2. Verify credentials are correct
3. Try re-authenticating
4. Re-run the Configuration Wizard

### "Operation failed"
1. Check available resources
2. Verify configuration
3. Try Preview mode first
4. Check error details in Tasks view

## Getting Help

### Documentation
- **README.md** - Complete feature list
- **QUICKSTART.md** - Quick reference guide
- **SETUP.md** - Detailed installation guide
- **CHANGELOG.md** - Latest updates

### Support
- GitHub Issues: [Report bugs or request features]({{GITHUB_URL}}/issues)
- Documentation: Check docs/ folder

## Next Steps

Now that you're up and running:

1. **Configure all settings** - Use the Configuration Wizard
2. **Set up schedules** - Use the Schedule Wizard for automation
3. **Learn keyboard shortcuts** - Boost your productivity
4. **Try Quick Actions** - Press Cmd+Shift+N

## Quick Reference

### Essential Shortcuts
| Shortcut | Action |
|----------|--------|
| **Cmd+Shift+N** | Quick Actions menu |
| **Cmd+N** | Add new item |
| **Cmd+,** | Preferences |
| **Cmd+R** | Refresh |
| **Space** | Preview |
| **Delete** | Delete selected |

### Operations
- **Drag & Drop** - Between panes or from Finder
- **Right-Click** - Context menu with all options
- **Multi-Select** - Cmd+Click or Shift+Click
- **Select All** - Cmd+A

### Performance Tips
- Use wizards for guided setup
- Preview before large operations
- Use scheduled tasks for regular operations

---

**Getting Started Guide Version**: {{VERSION}}
**Last Updated**: {{DATE}}

Welcome to {{PROJECT_NAME}}! 🚀
