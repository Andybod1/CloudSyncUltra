# {{PROJECT_NAME}} - Project Overview

## What is {{PROJECT_NAME}}?

{{PROJECT_DESCRIPTION}}

## Version {{VERSION}} Highlights

### Evolution from MVP to Production-Ready

| v1.0 (MVP) | {{VERSION}} (Current) |
|------------|-------------------|
| Basic UI | Full-featured interface |
| Single view | Multi-view navigation |
| Limited features | Comprehensive features |
| Manual only | Automated scheduling |
| No shortcuts | Quick Actions (Cmd+Shift+N) |

### User Interface

```
┌─────────────────────────────────────────────────────────────┐
│  {{PROJECT_NAME}}                                   ─ □ ×     │
├─────────────┬───────────────────────────────────────────────┤
│             │                                               │
│  Dashboard  │   Welcome to {{PROJECT_NAME}}                 │
│  Feature 1  │   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐            │
│  Feature 2  │   │Stats│ │Info │ │Data │ │More │            │
│  Tasks      │   └─────┘ └─────┘ └─────┘ └─────┘            │
│  History    │                                               │
│             │   Content Area                                │
│ ─────────── │                                               │
│ ITEMS       │   Recent Activity                             │
│  Item 1 ✓   │   • Activity 1 - 2 min ago                   │
│  Item 2 ✓   │   • Activity 2 - 15 min ago                  │
│  + Add...   │                                               │
│             │  Press Cmd+Shift+N for Quick Actions          │
│ ─────────── │                                               │
│  Settings   │                                               │
│             │                                               │
└─────────────┴───────────────────────────────────────────────┘
```

## Key Features

### 🎯 Dashboard
- **Real-time Stats** — Key metrics at a glance
- **Item Cards** — Visual grid showing status
- **Recent Activity** — Last operations with details
- **Quick Actions Hint** — Discover keyboard productivity features

### 🧙 Setup Wizards
- **Configuration Wizard** — Guided step-by-step setup
- **Schedule Wizard** — Easy configuration of automatic tasks
- **Action Wizard** — Operations with preview option and dry-run support
- **Interactive Onboarding** — Multi-step first-launch wizard

### 🚀 Quick Actions Menu
- **Keyboard Shortcut** — Cmd+Shift+N opens from anywhere
- **Fast Operations** — Common actions accessible instantly
- **Search-driven** — Type to filter available actions
- **Context-aware** — Shows relevant actions based on current view

### ⌨️ Full Keyboard Navigation
- **Global Shortcuts** — Cmd+N (new item), Cmd+Shift+N (quick actions), Cmd+, (settings)
- **Navigation** — Arrow keys, Enter, Space for Quick Look, Cmd+A select all
- **Accessible** — Complete app control without mouse

### 📋 Task Management
- **Live Progress** — Real-time percentage, speed, ETA
- **Task Queue** — Create multiple jobs, execute in order
- **Recently Completed** — Quick view of finished tasks
- **Error Details** — Clear messages with retry options
- **Background Execution** — Tasks continue when minimized

### 🕐 Scheduled Tasks
- **Flexible Scheduling** — Hourly, daily, weekly, or custom
- **Multiple Schedules** — Different tasks on different schedules
- **Run Now** — Manual trigger for any schedule
- **Next Task Display** — Shows countdown in menu bar

### 📜 History
- **Complete Archive** — All operations with metadata
- **Search & Filter** — Find by name, date, status
- **Metrics** — Speed, duration, counts
- **Export Support** — CSV export for reporting

### 🔒 Security
- **Secure Credentials** — Keychain storage
- **Privacy-first** — Local-only data

## Technology Stack

### Languages & Frameworks
- **Swift 5.9+** — Modern, safe, performant
- **SwiftUI** — Declarative UI with latest features
- **Combine** — Reactive state management
- **AppKit** — Menu bar and system integration
- **async/await** — Modern concurrency throughout

### Architecture
- **MVVM** — Clean separation of concerns
- **Dependency Injection** — Via environment objects
- **Singleton Managers** — For global state
- **Protocol-Oriented** — Extensible design

### Quality Assurance
- **{{TEST_COUNT}} Automated Tests** — Comprehensive coverage
- **CI/CD Pipeline** — GitHub Actions integration
- **Pre-commit Hooks** — Quality gates
- **Test Categories** — Unit, Integration, UI

## File Structure

```
{{PROJECT_DIR}}/
├── {{APP_ENTRY_POINT}}              # App entry, scenes
├── Models/
│   ├── DataModel.swift              # Core data definitions
│   ├── ConfigModel.swift            # Configuration model
│   └── ErrorModel.swift             # Error types
├── ViewModels/
│   ├── MainViewModel.swift          # Main data management
│   ├── TasksViewModel.swift         # Task queue management
│   └── OnboardingViewModel.swift    # First-run experience
├── Views/
│   ├── MainWindow.swift             # App structure
│   ├── DashboardView.swift          # Home/overview
│   ├── TasksView.swift              # Active & completed
│   ├── HistoryView.swift            # Operation archive
│   ├── QuickActionsView.swift       # Cmd+Shift+N menu
│   ├── OnboardingView/              # Multi-step wizard
│   └── Wizards/                     # Configuration wizards
├── Managers/
│   ├── ServiceManager.swift         # Core operations
│   ├── NotificationManager.swift    # User notifications
│   └── ScheduleManager.swift        # Task scheduling
├── Components/
│   ├── IconView.swift               # Icon display
│   ├── ErrorBanner.swift            # Error notifications
│   └── TaskCard.swift               # Task display
├── Styles/
│   ├── AppTheme.swift               # Design system
│   └── ButtonStyles.swift           # Consistent buttons
└── StatusBarController.swift        # Menu bar integration
```

**Total Lines**: ~X,000+ Swift code
**Test Coverage**: ~{{COVERAGE}}% across critical paths
**Components**: X+ SwiftUI views

## User Workflows

### First-Time Setup
1. Launch → Onboarding wizard appears
2. Welcome → Configure first item → First action → Tips
3. Skip available for experienced users
4. Dashboard shows with configured item

### Quick Actions (Cmd+Shift+N)
1. Press Cmd+Shift+N from anywhere
2. Type action name or select from list
3. Configure options
4. Execute → Monitor in Tasks view

### Scheduled Tasks
1. Go to Schedules → New Schedule
2. Name it (e.g., "Daily Task")
3. Configure source and destination
4. Choose frequency and time
5. Enable schedule → Auto-executes

## Performance Characteristics

### Resource Usage
| State | Memory | CPU | Network |
|-------|--------|-----|---------|
| Idle | ~50MB | <1% | None |
| Active | ~80MB | 2-5% | Minimal |
| Working | ~150-300MB | 10-30% | As needed |
| Multiple tasks | ~400MB | 20-40% | Throttled if set |

### UI Responsiveness
- **60 FPS** — Smooth SwiftUI animations
- **<100ms** — Button response time
- **<1s** — List loading (1000 items)
- **Real-time** — Progress updates

## Security Model

### Defense in Depth
1. **Authentication** — Secure credential handling
2. **Transport** — HTTPS/TLS for all connections
3. **Storage** — Keychain for sensitive data
4. **Validation** — Input sanitization, limits

### Privacy First
- **No Analytics** — Zero tracking or telemetry
- **Local Only** — All data stays on device
- **Open Source** — Full transparency

## Testing Strategy

### {{TEST_COUNT}} Automated Tests
- **Models** — Data structure tests
- **ViewModels** — State management, business logic
- **Managers** — Core operations
- **Integration** — End-to-end workflows
- **UI Tests** — User interaction flows

### Continuous Integration
- **GitHub Actions** — Build and test on push
- **Pre-commit Hooks** — Local quality gates
- **Test Recording** — Track test count over time
- **Coverage Goals** — {{COVERAGE}}%+ for critical paths

## Roadmap

### Next Minor Version
- [ ] Feature enhancement 1
- [ ] Feature enhancement 2
- [ ] Performance improvements
- [ ] Additional configuration options

### Future Major Version
- [ ] Major feature 1
- [ ] Major feature 2
- [ ] Platform expansion

## Contributing

### Getting Started
1. Fork the repository
2. Clone and build locally
3. Run the {{TEST_COUNT}} test suite
4. Make changes with tests
5. Submit PR with description

### Areas of Focus
- **Feature Testing** — Verify all features
- **Performance** — Optimize for large operations
- **Accessibility** — VoiceOver improvements
- **Documentation** — Guides and tutorials
- **Localization** — Multi-language support

### Code Standards
- SwiftUI for all UI
- Async/await for async operations
- MVVM architecture
- {{COVERAGE}}% test coverage for new code
- Clear commit messages

---

**Project**: {{PROJECT_NAME}}
**Version**: {{VERSION}}
**Released**: {{DATE}}
**Architecture**: MVVM + SwiftUI
**Platform**: macOS {{MIN_OS_VERSION}}+
**License**: MIT
**Tests**: {{TEST_COUNT}} (passing)

*{{PROJECT_TAGLINE}}*
