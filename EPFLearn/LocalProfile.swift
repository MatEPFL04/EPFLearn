//
//  LocalProfile.swift
//  LearnViz
//
//  A stable per-install identifier. Not an account: it exists only so that
//  QuizResultRecord.userID keeps a stable value without a schema migration.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class LocalProfile {

    private enum Keys {
        static let profileID    = "profileID"
        static let legacyApple  = "appleUserID"   // written by pre-1.0 builds
        static let legacyGuest  = "guestUserID"
    }

    private let defaults: UserDefaults
    private(set) var id: String

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let existing = defaults.string(forKey: Keys.profileID) {
            id = existing
        } else {
            // Adopt whatever id earlier builds were writing, so a TestFlight
            // tester who already has a history doesn't silently lose it.
            let adopted = defaults.string(forKey: Keys.legacyApple)
                ?? defaults.string(forKey: Keys.legacyGuest)
                ?? UUID().uuidString
            defaults.set(adopted, forKey: Keys.profileID)
            id = adopted
        }
    }

    /// Starts a fresh identity. Call *after* the records have been deleted.
    func reset() {
        let fresh = UUID().uuidString
        defaults.set(fresh, forKey: Keys.profileID)
        defaults.removeObject(forKey: Keys.legacyApple)
        defaults.removeObject(forKey: Keys.legacyGuest)
        id = fresh
    }
}
