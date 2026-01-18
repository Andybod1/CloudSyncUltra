# DEV2 Enhancement #168: Mail.ru Cloud App Password Wizard Guidance

## Status: COMPLETE

## Summary
Added clear instructions in the Mail.ru Cloud setup wizard explaining that app passwords are required, including a direct link to the Mail.ru security settings page.

## Changes Made

### File: `/Users/antti/claude/CloudSyncApp/Views/Wizards/ProviderConnectionWizard/Steps/ConfigureSettingsStep.swift`

#### 1. Added Mail.ru instructions in `providerInstructions` (line 595-596)
```swift
case .mailRuCloud:
    return "Mail.ru requires an App Password (not your regular password). Create one at Mail.ru Security Settings: Settings → Security → App Passwords (Пароли для внешних приложений). Note: The Mail.ru interface is in Russian."
```

#### 2. Added Mail.ru help URL in `providerHelpURL` (line 635-636)
```swift
case .mailRuCloud:
    return URL(string: "https://account.mail.ru/user/2-step-auth/passwords")
```

## Context
- Mail.ru Cloud requires app passwords when 2FA is enabled (or may require them by default)
- Using regular password causes "oauth2: server response missing access_token" error
- The Mail.ru interface is in Russian; the setting is labeled "Пароли для внешних приложений" (Passwords for external applications)
- Direct URL to app password creation page: https://account.mail.ru/user/2-step-auth/passwords

## Testing Notes
- When Mail.ru Cloud is selected in the provider connection wizard, users will now see:
  1. An info box explaining that an app password is required
  2. The Russian label in parentheses to help users find the setting
  3. A note that the interface is in Russian
  4. A help link that opens directly to the Mail.ru app passwords page

## Dev-2 Sign-off
Enhancement #168 implemented as specified.
