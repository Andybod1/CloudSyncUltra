# Task: Fix Onboarding Connect Button (#101)

## Worker: Dev-1 (UI)
## Priority: HIGH
## Size: S (30min - 1hr)

---

## Issue

The "Connect" button in onboarding step 2 (AddProviderStepView) doesn't actually connect the provider - it just advances to the next step like "Skip".

## Root Cause

In `AddProviderStepView.swift` lines 240-262, the `connectProvider()` function:
1. Creates a CloudRemote with `isConfigured: false`
2. Adds it to remotesVM
3. Waits 0.5 seconds
4. Advances to next step

It **never triggers the actual OAuth or credential flow**.

## Files to Modify

- `CloudSyncApp/Views/Onboarding/AddProviderStepView.swift`

## Solution

The Connect button should trigger the same connection flow used elsewhere in the app. Looking at RemotesViewModel, there should be a method to initiate provider connection.

### Option A: Trigger OAuth via RemotesViewModel
```swift
private func connectProvider() {
    guard let provider = selectedProvider else { return }

    isConnecting = true
    connectionError = nil

    // Use the existing connection flow from RemotesViewModel
    Task {
        do {
            try await remotesVM.connectProvider(provider)
            await MainActor.run {
                isConnecting = false
                onboardingVM.providerConnected(name: provider.displayName)
            }
        } catch {
            await MainActor.run {
                isConnecting = false
                connectionError = error.localizedDescription
            }
        }
    }
}
```

### Option B: If RemotesViewModel doesn't have async connect
Check what method RemotesViewModel uses for connection and call that instead of creating a stub remote.

## Verification Steps

1. Build passes
2. Launch app with fresh state (delete UserDefaults or use `OnboardingViewModel.shared.resetOnboarding()`)
3. Go through onboarding to step 2
4. Select a provider (e.g., Google Drive)
5. Click "Connect"
6. **Expected**: OAuth flow opens in browser OR credential sheet appears
7. **Not Expected**: Just advancing to next step

## Constraints

- DO NOT modify OnboardingViewModel
- DO NOT modify RemotesViewModel (use existing methods)
- Use existing types from TYPE_INVENTORY.md
- Run `./scripts/worker-qa.sh` before marking complete

## Related Files (Read-Only Reference)

- `CloudSyncApp/ViewModels/RemotesViewModel.swift` - Check for connection methods
- `CloudSyncApp/ViewModels/OnboardingViewModel.swift` - Already read
