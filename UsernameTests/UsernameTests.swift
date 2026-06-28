//
//  UsernameTests.swift
//  UsernameTests
//
//  Created by u on 28/06/2026.
//

import Testing
@testable import Username

struct UsernameRulesTests {

    // MARK: sanitize

    @Test func sanitizeStripsPunctuation() {
        #expect(UsernameRules.sanitize("hello world!") == "helloworld")
    }

    @Test func sanitizeStripsSymbols() {
        #expect(UsernameRules.sanitize("a@b.c") == "abc")
    }

    @Test func sanitizeStripsEmoji() {
        #expect(UsernameRules.sanitize("emoji_😀_test") == "emoji__test")
    }

    @Test func sanitizePreservesAllowedCharacters() {
        #expect(UsernameRules.sanitize("ABC_xyz_123") == "ABC_xyz_123")
    }

    @Test func sanitizeCapsAtMaxLength() {
        let raw = String(repeating: "a", count: UsernameRules.maxLength + 5)
        #expect(UsernameRules.sanitize(raw).count == UsernameRules.maxLength)
    }

    @Test func sanitizeHandlesEmpty() {
        #expect(UsernameRules.sanitize("") == "")
    }

    @Test func sanitizeIsIdempotent() {
        let once = UsernameRules.sanitize("Hello, world!")
        let twice = UsernameRules.sanitize(once)
        #expect(once == twice)
    }

    // MARK: isValid

    @Test func isValidAcceptsMinimumLength() {
        let candidate = String(repeating: "a", count: UsernameRules.minLength)
        #expect(UsernameRules.isValid(candidate))
    }

    @Test func isValidAcceptsMaximumLength() {
        let candidate = String(repeating: "a", count: UsernameRules.maxLength)
        #expect(UsernameRules.isValid(candidate))
    }

    @Test func isValidRejectsEmpty() {
        #expect(!UsernameRules.isValid(""))
    }

    @Test func isValidRejectsBelowMinimum() {
        let candidate = String(repeating: "a", count: UsernameRules.minLength - 1)
        #expect(!UsernameRules.isValid(candidate))
    }

    @Test func isValidRejectsAboveMaximum() {
        let candidate = String(repeating: "a", count: UsernameRules.maxLength + 1)
        #expect(!UsernameRules.isValid(candidate))
    }
}

struct ContentViewTests {

    @MainActor
    @Test func initializesWithoutCrashing() {
        _ = ContentView(initialUsername: "alice") { _ in }
    }
}
