# Username

A lightweight iOS/macOS application built with SwiftUI that provides a dedicated, accessible screen for editing and validating a user's handle. The app enforces strict formatting rules, persists the initial username across sessions, and delivers a polished editing experience with real-time sanitization, haptic feedback, and smooth animations.

## Features

- **Real-time Input Sanitization**: Automatically strips disallowed characters and clamps length to 15 characters as the user types.
- **Strict Validation**: Requires 3–15 characters using only ASCII letters, digits, and underscores.
- **Persistent Restore**: Remembers the first username seen on the device via `@AppStorage`, enabling a one-tap restore chip.
- **Accessibility & Dynamic Type**: Fully supports VoiceOver, Dynamic Type scaling, and reduced motion preferences.
- **Haptic Feedback**: Triggers success and light impact haptics on commit and clear actions.
- **Dark Mode Optimized**: Forces a dark color scheme for consistent visual presentation.
- **Localization Ready**: UI strings are managed in a modern `.xcstrings` catalog.

## Architecture & Key Files

The project follows a minimal, single-screen architecture where the app delegate owns the navigation stack and state, while the view owns its own validation rules.

| Path | Purpose |
|------|---------|
| `Username/UsernameApp.swift` | App entry point. Initializes the default state (`"femi"`) and wraps `ContentView` in a `NavigationStack`. |
| `Username/ContentView.swift` | Core UI and business logic. Contains `ContentView` (the editor) and `UsernameRules` (validation/sanitization). Uses `@AppStorage` to persist the initial handle. |
| `Username/Localizable.xcstrings` | String catalog for UI text. Configured as the primary localization format. |
| `UsernameTests/UsernameTests.swift` | Unit tests using the Swift Testing framework. Covers `UsernameRules` edge cases and view initialization. |
| `UsernameUITests/` | XCTest-based UI tests for launch and performance baselines. |
| `Package.swift` | Swift Package Manager manifest. Defines the `Username` library, targets, and Swift 6 language mode. |
| `Username.xcodeproj/` | Xcode project configuration for building, running, and testing the application. |

## Installation & Building

### Prerequisites
- Xcode 15+ (recommended for SwiftUI and Swift Testing support)
- iOS 15+ or macOS 12+ deployment target
- Swift 6

### Using Xcode (Recommended)
1. Open `Username.xcodeproj` in Xcode.
2. Select the `Username` scheme.
3. Choose a simulator or physical device.
4. Press `⌘R` to build and run.

### Using Swift Package Manager
The project is structured as a Swift Package for library consumption:
```bash
git clone <repository-url>
cd Username
swift build
```
*Note: SPM builds the `Username` library target. To run the full application with SwiftUI, use Xcode.*

## Running the App

Upon launch, the app displays a centered text field prefixed with `@`. The field automatically focuses and selects existing text after a brief delay.

- **Set a new handle**: Type a valid username and tap the `Set` button in the navigation bar, or press Return.
- **Clear input**: Tap the `×` button that appears when text is entered.
- **Restore original**: If the current username differs from the first-seen value, a restore chip appears showing `@<original>`. Tapping it reverts to the original handle and commits the change.
- **Validation feedback**: If the draft is empty or below the 3-character minimum, contextual hints appear below the input field.

## Testing

### Unit Tests
Run via Xcode's test navigator or the command line:
```bash
swift test
```
Tests cover:
- `UsernameRules.sanitize(_:)`: Stripping punctuation, symbols, emoji, preserving allowed characters, length clamping, idempotency, and empty input.
- `UsernameRules.isValid(_:)`: Boundary checks for minimum (3) and maximum (15) lengths.
- `ContentView` initialization without crashes.

### UI Tests
Located in `UsernameUITests/`. Provides baseline launch metrics and screen capture attachments. Run via Xcode or:
```bash
xcodebuild test -scheme UsernameUITests
```

## Localization

UI strings are centralized in `Username/Localizable.xcstrings`. The Xcode project is configured with `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` and `STRING_CATALOG_GENERATE_SYMBOLS = YES`.

To add a new language:
1. Open `Localizable.xcstrings` in Xcode.
2. Click the `+` button in the localization inspector and select the target language.
3. Translate the extracted strings. The app will automatically pick up the localized strings at runtime.

## Non-Obvious Conventions & Notes

- **State Persistence**: The initial username is stored in `@AppStorage("market.Username.firstSeen")`. This value is set once on first launch and never cleared, enabling the restore functionality across app relaunches.
- **Input Sanitization Flow**: The `.onChange(of: draft)` modifier runs `UsernameRules.sanitize(new)` synchronously. Disallowed characters are removed immediately, and the string is truncated to 15 characters before validation occurs.
- **Concurrency & Isolation**: The package enforces Swift 6 strict concurrency (`swiftLanguageModes: [.v6]`). All UI state and callbacks are `@MainActor`-isolated.
- **Deployment Target Configuration**: The Xcode project file (`project.pbxproj`) contains `IPHONEOS_DEPLOYMENT_TARGET = 26.5`, which appears to be a placeholder or future-dated value. The SPM manifest (`Package.swift`) correctly specifies `.iOS(.v15)`. Adjust deployment targets in Xcode's project settings if targeting specific OS versions.
- **Haptic Triggers**: Haptics are driven by integer state variables (`commitTick`, `lightTick`) rather than direct API calls, allowing SwiftUI's `.sensoryFeedback()` modifier to handle timing and animation synchronization cleanly.