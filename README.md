# Username

A lightweight, single-purpose SwiftUI component for editing, validating, and persisting user handles. Designed as both a standalone iOS app and a reusable Swift Package, it provides a clean, dark-mode interface with real-time sanitization, haptic feedback, and a one-tap restore feature.

## Features
- **Real-time sanitization & validation**: Automatically strips disallowed characters and enforces a 3–15 character limit (alphanumeric + underscore only).
- **Persistent anchor state**: Remembers the first username seen on the device to power an in-screen restore chip.
- **Accessibility & UX**: Optimized for dark mode, supports dynamic type scaling, respects reduced motion preferences, and includes haptic feedback on commit/clear actions.
- **Framework-ready**: Exports a pure UI library via SPM, excluding app-specific entry points and asset catalogs.

## Architecture & Key Files
| Path | Purpose |
|------|---------|
| `Package.swift` | SPM manifest. Defines the `Username` library target, excludes app files, and enforces Swift 6 language mode. |
| `Username/ContentView.swift` | Public SwiftUI view and `UsernameRules` struct. Handles UI layout, input sanitization, validation, state persistence, and commit callbacks. |
| `Username/UsernameApp.swift` | App entry point (`@main`). Demonstrates integration and manages the root username state. |
| `Username/Localizable.xcstrings` | Centralized localization strings in the modern `.xcstrings` format. |
| `UsernameTests/UsernameTests.swift` | Unit tests using the Swift Testing framework. Covers `UsernameRules` edge cases and view initialization. |
| `UsernameUITests/` | Scaffolded UI tests for launch performance and basic automation. |
| `Username.xcodeproj/project.pbxproj` | Xcode project configuration. Sets iOS 26.5 deployment target, `MainActor` default isolation, and bundle identifier `market.Username`. |

## Installation & Build

### Xcode
1. Open `Username.xcodeproj` in Xcode.
2. Select the `Username` scheme and build/run on a simulator or device.
3. Requires Xcode 26.5+ and iOS 26.5 deployment target (as declared in project settings).

### Swift Package Manager
Add the package to your `Package.swift` or Xcode project dependencies:
```swift
.package(path: "/path/to/Username")
```
Link the `Username` library target to your app. The library target intentionally excludes `UsernameApp.swift` and `Assets.xcassets` to keep the dependency lightweight.

## Usage

`ContentView` is a public, reusable view that requires an initial username and a commit callback:

```swift
NavigationStack {
    ContentView(initialUsername: "current_handle") { newName in
        // Handle the committed username
    }
}
```

### Behavior
- **Input Handling**: The text field automatically sanitizes input via `UsernameRules.sanitize(_:)` on every keystroke.
- **Validation**: The `Set` button remains disabled until the trimmed input is 3–15 characters and differs from the current username.
- **Restore Chip**: Appears when the current username differs from the persisted anchor. Tapping it reverts to the original handle and triggers the `onSet` callback.
- **State Persistence**: The anchor is stored in `@AppStorage("market.Username.firstSeen")` and survives app relaunches.

## Testing

Run unit tests via Xcode or the Swift CLI:
```bash
swift test
```

The test suite (`UsernameTests/UsernameTests.swift`) covers:
- Sanitization edge cases: emoji stripping, punctuation removal, length clamping, and idempotency.
- Validation boundaries: minimum/maximum length, empty strings, and invalid characters.
- View initialization: ensures `ContentView` initializes without crashing on the main thread.

UI tests are scaffolded for launch performance benchmarking and basic automation.

## Configuration & Conventions

- **Concurrency Model**: Swift 6 mode is enabled with `MainActor` as the default isolation context (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`). All UI state mutations occur on the main actor.
- **Localization**: Defaults to English (`defaultLocalization: "en"` in `Package.swift`). Strings are managed in `Username/Localizable.xcstrings`.
- **UI/UX Defaults**: 
  - Forced dark mode via `.preferredColorScheme(.dark)`
  - Dynamic type support: `.large ... .accessibility1`
  - Haptic feedback: `.sensoryFeedback(.success)` on commit, `.impact(weight: .light)` on clear
  - Reduced motion: Animations are disabled when `.accessibilityReduceMotion` is true
- **Bundle Identifier**: `market.Username` (configurable in Xcode build settings under `PRODUCT_BUNDLE_IDENTIFIER`).
- **Code Signing**: Automatic code signing is enabled with development team `KW95N2FYJ8` (update as needed for production).