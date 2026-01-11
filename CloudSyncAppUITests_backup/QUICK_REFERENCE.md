# UI Testing Quick Reference

## Run Tests

```bash
# All UI tests
⌘U (in Xcode with CloudSyncAppUITests scheme)

# Specific suite
⌘⌥U (click test diamond in code)

# Command line
xcodebuild test -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp -destination 'platform=macOS' \
  -only-testing:CloudSyncAppUITests
```

## Common Test Patterns

### Basic Test Structure
```swift
func testFeatureName() {
    // Given: Setup
    let button = app.buttons["MyButton"]
    
    // When: Action
    button.tap()
    
    // Then: Verify
    XCTAssertTrue(condition)
}
```

### Wait for Element
```swift
let element = app.buttons["Submit"]
XCTAssertTrue(waitForElement(element, timeout: 5))
```

### Take Screenshot
```swift
takeScreenshot(named: "AfterClick")
```

### Navigate to Tab
```swift
let tab = app.buttons["Dashboard"]
tab.tap()
```

## Element Selectors

```swift
app.buttons["ButtonName"]           # Button
app.textFields["FieldName"]         # Text field
app.tables.firstMatch               # Table
app.popUpButtons.firstMatch         # Dropdown
app.menuItems["MenuItem"]           # Menu item
app.searchFields.firstMatch         # Search
app.staticTexts["Text"]             # Labels
```

## Test Suites

1. **DashboardUITests** - Dashboard view
2. **FileBrowserUITests** - File browsing
3. **TransferViewUITests** - Transfers
4. **TasksUITests** - Task management
5. **WorkflowUITests** - End-to-end flows

## Debugging

```swift
// Print app hierarchy
print(app.debugDescription)

// Check if element exists
if element.exists {
    print("Found: \(element)")
}

// Wait and retry
for _ in 0..<5 {
    if element.exists { break }
    sleep(1)
}
```

## Best Practices

✅ Use waitForElement() not sleep()
✅ Add descriptive test names
✅ One assertion per test when possible
✅ Take screenshots on failures
✅ Group related tests
✅ Clean up after tests

❌ Don't use hardcoded delays
❌ Don't test implementation details
❌ Don't create test dependencies
❌ Don't ignore flaky tests

## Common Issues

**Element not found:**
- Add wait: `waitForElement(element)`
- Check identifier
- Verify view is loaded

**Test timeout:**
- Increase timeout
- Check for deadlock
- Verify app launches

**Flaky test:**
- Add explicit waits
- Check for race conditions
- Verify element state

## Files

- `UI_TESTING_GUIDE.md` - Full documentation
- `README.md` - Implementation summary
- `*UITests.swift` - Test files

**Location:** `/Users/antti/Claude/CloudSyncAppUITests/`
