# ADR-003: SwiftUI with MVVM Architecture

## Status

Accepted

## Context

CloudSync Ultra targets macOS 13+ and needs:
- Modern, native look and feel
- Responsive UI during long operations
- Menu bar integration
- Dark mode support
- Accessibility features

## Decision

Use SwiftUI with MVVM (Model-View-ViewModel) architecture:

```
Views/           → SwiftUI Views (presentation)
ViewModels/      → ObservableObject classes (state + logic)
Models/          → Data structures (pure data)
Managers/        → Singleton services (RcloneManager, etc.)
```

Key patterns:
- ViewModels are `@ObservableObject` with `@Published` properties
- Views observe ViewModels with `@ObservedObject` or `@StateObject`
- Managers are singletons accessed via `.shared`
- Async operations use Swift Concurrency (async/await)

## Consequences

### Positive

- Native macOS look and feel
- Declarative UI reduces boilerplate
- Automatic dark mode support
- Built-in accessibility
- Reactive updates via Combine
- Modern Swift Concurrency integration

### Negative

- macOS 13+ requirement limits older Mac support
- SwiftUI still maturing, some rough edges
- Complex animations can be challenging
- AppKit interop sometimes needed

### Neutral

- Learning curve for developers new to SwiftUI
- Different from UIKit/AppKit mental model

## Alternatives Considered

1. **AppKit (traditional)**
   - Rejected: More boilerplate, less modern

2. **Electron/Web**
   - Rejected: Not native, larger bundle, worse performance

3. **Catalyst (iOS UIKit on Mac)**
   - Rejected: Feels like iOS app, not native Mac

## References

- Apple SwiftUI documentation
- WWDC sessions on SwiftUI for macOS
