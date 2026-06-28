//
//  ContentView.swift
//  Username
//
//  Created by u on 28/06/2026.
//

import SwiftUI
import UIKit

/// Single-purpose screen for editing a user's handle.
///
/// The parent owns the navigation stack and the username value, and supplies
/// a callback for commits. The screen declares its own title and toolbar items;
/// they activate inside whatever ``NavigationStack`` the parent provides.
///
/// The screen owns one piece of internal state across launches: the anchor
/// (the first username it ever saw on this device), persisted in `@AppStorage`.
/// That anchor powers the in-screen restore chip.
struct ContentView: View {
    let initialUsername: String
    let onSet: (String) -> Void

    @AppStorage("market.Username.firstSeen") private var firstSeen: String = ""

    @State private var currentUsername: String
    @State private var draft: String
    @State private var commitTick: Int = 0
    @State private var lightTick: Int = 0
    @FocusState private var fieldFocused: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates the editor.
    /// - Parameters:
    ///   - initialUsername: The handle to display when the screen first appears.
    ///   - onSet: Called when the user commits a new handle (via Set or restore).
    init(initialUsername: String, onSet: @escaping (String) -> Void) {
        self.initialUsername = initialUsername
        self.onSet = onSet
        _currentUsername = State(initialValue: initialUsername)
        _draft = State(initialValue: initialUsername)
        if firstSeen.isEmpty {
            firstSeen = initialUsername
        }
    }

    private var trimmed: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSet: Bool {
        UsernameRules.isValid(trimmed) && trimmed != currentUsername
    }

    private var canRestore: Bool {
        !firstSeen.isEmpty && currentUsername != firstSeen
    }

    private var responsiveSpring: Animation? {
        reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.82)
    }

    private var snappySpring: Animation? {
        reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.76)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(verbatim: "@")
                    .font(.system(.largeTitle, design: .rounded, weight: .light))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)

                TextField("", text: $draft)
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .submitLabel(.done)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .focused($fieldFocused)
                    .accessibilityLabel("Username")
                    .accessibilityHint("Edit your handle, then activate Set.")
                    .onChange(of: draft) { _, new in
                        let result = UsernameRules.sanitize(new)
                        if result != new { draft = result }
                    }
                    .onSubmit { commit() }

                if !draft.isEmpty {
                    Button {
                        draft = ""
                        lightTick += 1
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear")
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal)
            .animation(responsiveSpring, value: draft.isEmpty)

            HStack(spacing: 8) {
                Group {
                    if draft.isEmpty {
                        Text("Pick something memorable")
                    } else if trimmed.count < UsernameRules.minLength {
                        Text("At least \(UsernameRules.minLength) characters")
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                if canRestore {
                    Button {
                        draft = firstSeen
                        currentUsername = firstSeen
                        onSet(firstSeen)
                        lightTick += 1
                    } label: {
                        Label {
                            Text(verbatim: "@\(firstSeen)")
                        } icon: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                        .font(.footnote.weight(.semibold))
                    }
                    .buttonStyle(.glass)
                    .controlSize(.small)
                    .accessibilityLabel("Restore original username, at \(firstSeen)")
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            )
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .frame(minHeight: 36)
            .animation(snappySpring, value: canRestore)
            .animation(responsiveSpring, value: trimmed)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Username")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Set", action: commit)
                    .disabled(!canSet)
                    .accessibilityLabel("Set username")
            }
        }
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.large ... .accessibility1)
        .sensoryFeedback(.success, trigger: commitTick)
        .sensoryFeedback(.impact(weight: .light), trigger: lightTick)
        .task {
            try? await Task.sleep(for: .milliseconds(350))
            fieldFocused = true
            UIApplication.shared.sendAction(
                #selector(UIResponder.selectAll(_:)),
                to: nil, from: nil, for: nil
            )
        }
    }

    private func commit() {
        guard canSet else { return }
        currentUsername = trimmed
        draft = trimmed
        fieldFocused = false
        onSet(trimmed)
        commitTick += 1
    }
}

/// Internal validation + sanitization rules for usernames.
///
/// Lives alongside ``ContentView`` so the screen owns its own rules
/// (parent never sees them). Exposed at module-internal scope so tests
/// can verify behavior without driving the view.
struct UsernameRules {
    static let minLength = 3
    static let maxLength = 15

    /// Strips disallowed characters and clamps length.
    /// Allowed: ASCII-letters, digits, underscore.
    static func sanitize(_ raw: String) -> String {
        let filtered = raw.unicodeScalars.filter { scalar in
            let ch = Character(scalar)
            return ch.isLetter || ch.isNumber || ch == "_"
        }
        return String(String(String.UnicodeScalarView(filtered)).prefix(maxLength))
    }

    /// Whether a trimmed candidate is within the allowed length range.
    /// Assumes the input has already passed through ``sanitize(_:)``.
    static func isValid(_ candidate: String) -> Bool {
        let count = candidate.count
        return count >= minLength && count <= maxLength
    }
}

#Preview {
    NavigationStack {
        ContentView(initialUsername: "femi") { _ in }
    }
}
