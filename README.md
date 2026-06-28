# Username

## Overview
`Username` is a lightweight iOS/macOS application and Swift Package that provides a polished, accessible interface for editing and validating user handles. It enforces strict character sanitization, provides real-time validation feedback, and persists the initial username across app launches to enable a one-tap restore feature.

## Features
- **Real-time Sanitization:** Automatically strips disallowed characters and clamps input length as the user types.
- **Strict Validation:** Enforces a 3–15 character limit using only ASCII letters, digits, and underscores.
- **Restore Functionality:** Persists the initial username via `@AppStorage` and offers a dedicated chip to revert changes.
- **Accessibility & Haptics:** Full support for Dynamic Type, VoiceOver, and reduced motion preferences. Includes `.sensoryFeedback` triggers for commits and clears.
- **Swift 6 & Strict Concurrency:** Built with modern Swift concurrency defaults (`MainActor` isolation, approachable concurrency).
- **Swift Testing Framework:** Unit tests leverage the native Swift Testing framework instead of XCTest.

## Architecture & Key Files
The project follows a single-screen, state-driven architecture where the view owns its validation logic and the app delegate manages the top-level state.

| Path | Description |
|------|-------------|
| `Package.swift` | Swift Package Manager manifest. Defines the `Username` library target and supports iOS 15+ / macOS 12+. |
| `Username/ContentView.swift` | Core UI component. Manages the text field, validation state, animations, haptics, and contains the `UsernameRules` struct. |
| `Username/UsernameApp.swift` | App entry point (`@main`). Initializes the navigation stack and holds the app-wide `username` state. |
| `UsernameTests/UsernameTests.swift` | Unit tests using the Swift Testing framework. Validates `UsernameRules.sanitize` and `isValid` behavior. |
| `UsernameUITests/` | XCUITest suite for launch performance and basic UI automation. |
| `Localizable.xcstrings` | Modern Swift string catalog containing all user-facing text. |

## Requirements
- Xcode 16+ (required for Swift 6 strict concurrency and Swift Testing)
- iOS 15.0+ / macOS 12.0+
- Swift 6.0+

## Installation & Building
### Using Swift Package Manager
Add the package to your project via Xcode or the command line:
```bash
swift package init
swift build
```

### Using Xcode
Open the project workspace or package:
```bash
open Username.xcodeproj
```
Select the `Username` scheme and build for your target device/simulator.

## Testing
The project ships with both unit and UI tests.

**Unit Tests (Swift Testing)**
Run the validation and sanitization tests via SPM:
```bash
swift test
```
Or in Xcode: `Product > Test` (⌘U).

**UI Tests (XCUITest)**
UI tests are configured in `UsernameUITests/`. Run them via Xcode's test navigator or:
```bash
xcodebuild test -scheme UsernameUITests -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

## Usage & Integration
`Username` is distributed as both an app and a library. To embed the editor in your own SwiftUI app:

```swift
import Username
import SwiftUI

struct MySettingsView: View {
    @State private var handle = "existing_user"

    var body: some View {
        NavigationStack {
            ContentView(initialUsername: handle) { newHandle in
                handle = newHandle
                // Persist or sync `handle` with your backend
            }
        }
    }
}
```

The `ContentView` initializer accepts:
- `initialUsername: String`: The handle to display on first load.
- `onSet: (String) -> Void`: A callback triggered when the user taps **Set** or **Restore**.

## Non-Obvious Conventions & Implementation Details
- **Internal Rules Exposure:** `UsernameRules` is defined as a `struct` inside `ContentView.swift` at module-internal scope. It is not `public`, but is accessible to tests via `@testable import Username` in `UsernameTests/UsernameTests.swift`.
- **Persistence Key:** The "first seen" username is stored under the key `"market.Username.firstSeen"` in `UserDefaults` via `@AppStorage`. This survives app relaunches and powers the restore chip.
- **Auto-Focus Behavior:** On load, the view waits 350ms before focusing the text field and programmatically selecting all text using `UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)))`.
- **Animation & Motion:** Animations are conditionally disabled based on `.accessibilityReduceMotion`. Springs use custom damping/response values (`responsiveSpring`, `snappySpring`) to match the app's tactile feel.
- **Strict Concurrency Defaults:** The Xcode project (`Username.xcodeproj/project.pbxproj`) enforces `SWIFT_APPROACHABLE_CONCURRENCY = YES` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. All UI state and callbacks are explicitly `MainActor`-isolated.
- **Localization Strategy:** Uses the modern `.xcstrings` format (`Localizable.xcstrings`). The project is configured with `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` and `STRING_CATALOG_GENERATE_SYMBOLS = YES` for compile-time string interpolation safety.