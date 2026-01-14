# UI Visual Refresh Task: Match Onboarding Look & Feel

**Issue:** #84
**Sprint:** Next Sprint
**Priority:** High
**Worker:** UI Designer / Dev

---

## Objective

Adjust the main app visuals to match the polished onboarding experience. Create visual consistency across the entire application.

## Reference: Onboarding Style

First, analyze the onboarding views to understand the design language:

```bash
# Review onboarding views
cat CloudSyncApp/OnboardingView.swift
cat CloudSyncApp/WelcomeStepView.swift
```

Key onboarding design elements to identify:
- Color palette (gradients, accent colors)
- Typography (font sizes, weights)
- Spacing and padding patterns
- Button styles
- Card/container styles
- Icon usage
- Animation patterns

## Files to Modify

### Primary Views
- `CloudSyncApp/Views/DashboardView.swift`
- `CloudSyncApp/Views/TransferView.swift`
- `CloudSyncApp/Views/FileBrowserView.swift`
- `CloudSyncApp/Views/TasksView.swift`
- `CloudSyncApp/SettingsView.swift`

### Supporting Files (Create if needed)
- `CloudSyncApp/Styles/AppTheme.swift` - Centralized theme definitions
- `CloudSyncApp/Styles/ButtonStyles.swift` - Consistent button styles
- `CloudSyncApp/Styles/CardStyles.swift` - Card/container styles

## Tasks

### 1. Audit Current Onboarding Style

Extract design tokens from onboarding:

```swift
// Example: Extract these patterns from OnboardingView
struct AppTheme {
    // Colors
    static let primaryGradient = LinearGradient(
        colors: [/* from onboarding */],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let accentColor = Color(/* from onboarding */)
    static let cardBackground = Color(/* from onboarding */)

    // Typography
    static let titleFont = Font.system(size: 28, weight: .bold)
    static let headingFont = Font.system(size: 20, weight: .semibold)
    static let bodyFont = Font.system(size: 14, weight: .regular)

    // Spacing
    static let cardPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 12

    // Corner Radius
    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 12
}
```

### 2. Create Shared Button Styles

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonRadius)
                    .fill(AppTheme.primaryGradient)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AppTheme.accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonRadius)
                    .stroke(AppTheme.accentColor, lineWidth: 1)
            )
    }
}
```

### 3. Create Card Container Style

```swift
struct CardContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            )
    }
}
```

### 4. Update Dashboard View

Apply consistent styling:
- Use CardContainer for stat cards
- Apply PrimaryButtonStyle to main actions
- Match typography hierarchy
- Add subtle animations on hover/interaction

### 5. Update Transfer View

- Style source/destination panes consistently
- Update file row appearance
- Apply consistent button styles
- Match progress indicator style

### 6. Update File Browser View

- Style navigation breadcrumbs
- Update file/folder row appearance
- Match toolbar button styles
- Consistent selection highlighting

### 7. Update Tasks View

- Style task cards with CardContainer
- Update status badges
- Consistent action button styles
- Progress indicator styling

### 8. Update Settings View

- Section header styling
- Form control consistency
- Button styling
- Tab/navigation styling

## Visual Checklist

For each view, verify:
- [ ] Colors match onboarding palette
- [ ] Typography is consistent
- [ ] Spacing/padding follows pattern
- [ ] Buttons use shared styles
- [ ] Cards use consistent styling
- [ ] Icons are consistent size/weight
- [ ] Hover states are consistent
- [ ] Focus states are accessible

## Verification

1. Build and run the app
2. Complete onboarding flow
3. Navigate through all main views
4. Verify visual consistency:
   - Same color palette throughout
   - Same button styles everywhere
   - Same card/container treatment
   - Same typography hierarchy
   - Smooth visual transitions between views

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/UI_VISUAL_REFRESH_COMPLETE.md`

Include:
- Before/after screenshots (if possible)
- List of files modified
- New shared styles created
- Any design decisions made

## Success Criteria

- [ ] AppTheme.swift created with design tokens
- [ ] Shared button styles implemented
- [ ] CardContainer style implemented
- [ ] All 5 main views updated
- [ ] Visual consistency achieved
- [ ] Build succeeds
- [ ] Existing tests pass
- [ ] No accessibility regressions
