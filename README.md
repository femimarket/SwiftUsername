# Username

## Overview
`Username` is a lightweight iOS application and Swift Package that provides a focused interface for editing, validating, and persisting user handles. It features real-time sanitization, a one-tap restore mechanism, haptic feedback, and full accessibility support. The project is structured to function both as a standalone iOS app and as a reusable library component.

## Features
- **Real-time sanitization & validation**: Automatically strips disallowed characters and enforces a 3–15 character limit (alphanumeric + underscore only).
- **Persistent restore**: Remembers the initial username across app launches via `@AppStorage` and surfaces a restore chip when the handle has been changed.
- **Modern SwiftUI**: Built with dynamic type scaling, reduced motion support, and sensory feedback (haptics).
- **Dual distribution**: Available as an Xcode project (`Username.xcodeproj`) and a Swift Package (`Package.swift`).
- **Comprehensive testing**: Unit tests using the Swift Testing framework and UI tests using XCTest.

## Architecture & Key Files
| Path | Purpose |
|------|---------|
| `Username/ContentView.swift` | Core UI and `UsernameRules` logic. Manages state, validation, sanitization, animations, and user interactions. |
| `Username/UsernameApp.swift` | App entry point (`@main`). Initializes the `NavigationStack` and manages the username state lifecycle. |
| `Username/Localizable.xcstrings` | String catalog for UI text. Currently contains English strings. |
| `Username/Assets.xcassets/` | Standard asset catalogs for app icon and accent color. |
| `Package.swift` | Swift Package Manager manifest. Defines the `Username` library target and excludes app-specific files to prevent symbol conflicts. |
| `UsernameTests/UsernameTests.swift` | Unit tests using the `Testing` framework. Covers `UsernameRules.sanitize`, `isValid`, and `ContentView` initialization. |
| `UsernameUITests/` | UI test suite using `XCTest`. Includes launch and performance benchmarks. |
| `Username.xcodeproj/project.pbxproj` | Xcode project configuration. Sets deployment target to iOS 26.5, bundle ID to `market.Username`, and configures Swift 6 concurrency defaults. |

## Requirements
- **Xcode**: 16+ (Swift 6.3 toolchain)
- **iOS**: 26.0+ (simulator or physical device)
- **Apple Developer Account**: Team ID `KW95N2FYJ8` is pre-configured in the project for code signing.

## Installation & Build
### Using Xcode
1. Open `Username.xcodeproj` in Xcode.
2. Select the `Username` scheme.
3. Choose a simulator or device running iOS 26+.
4. Press `⌘B` to build or `⌘R` to run.

### Using Swift Package Manager
Add the package to your project via Xcode (`File > Add Packages`) or include it in your `Package.swift`:
```swift
.package(url: "https://github.com/your-org/username.git", from: "1.0.0")
```
When integrated as a library, the `Username` target automatically excludes `UsernameApp.swift` and `Assets.xcassets` to avoid duplicate symbol errors.

## Usage
### As a Standalone App
Launch the app to immediately see the username editor. The field auto-focuses and selects existing text. Type a new handle and tap `Set` or press the keyboard return key. If the username has been changed, a restore chip appears showing the original handle; tapping it reverts and commits the change.

### As a Library
Import `Username` and embed `ContentView` inside your own navigation container:
```swift
NavigationStack {
    ContentView(initialUsername: "existing_handle") { newName in
        // Handle the committed username
    }
}
```
The `onSet` closure is triggered only when the input passes validation and the user commits the change.

## Testing
### Unit Tests
Run via Xcode or the command line:
```bash
swift test
```
Tests verify sanitization edge cases (emoji stripping, punctuation removal, length clamping, idempotency) and validation boundaries.

### UI Tests
Run the `UsernameUITests` scheme in Xcode. The suite includes a launch performance benchmark and a placeholder UI automation test.

## Localization
UI strings are managed in `Username/Localizable.xcstrings`. The project uses the modern `.xcstrings` format with manual extraction state. To add a new language:
1. Duplicate the `.xcstrings` file or use Xcode's Localization editor.
2. Translate the `value` fields for each string unit.
3. Ensure `defaultLocalization` in `Package.swift` matches your primary language (`en`).

## Conventions & Notes
- **Sanitization Rules**: `UsernameRules.sanitize(_:)` filters `unicodeScalars` to keep only ASCII letters, digits, and underscores. It then clamps the result to `maxLength` (15). `isValid(_:)` checks the sanitized string against `minLength` (3).
- **Persistence**: The initial username is stored in `@AppStorage("market.Username.firstSeen")`. This key is written exactly once per device and powers the restore functionality.
- **Swift 6 Defaults**: The project enforces `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES`. All UI state mutations occur on the main actor.
- **Animation & Accessibility**: Animations use `responsiveSpring` and `snappySpring` but are disabled when `@Environment(\.accessibilityReduceMotion)` is true. Haptic feedback is triggered via `.sensoryFeedback()` on commit and clear actions.
- **Deployment Target**: The project is configured for iOS 26.0+ in `Package.swift` and iOS 26.5 in `project.pbxproj`. Ensure your development environment supports this target.