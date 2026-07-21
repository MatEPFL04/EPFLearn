//
//  ClaudeConfig.swift
//  EPFLearn
//
//  Created by Mat on 19.07.2026.
//

import Foundation

enum ClaudeConfig {
    // ⬇️ LA seule ligne à changer pour passer en production
    static let mode: Mode = .development

    enum Mode { case development, production }

    static let model = "claude-sonnet-5"   // raisonnement maths solide

    static var endpoint: URL {
        switch mode {
        case .development:
            return URL(string: "https://api.anthropic.com/v1/messages")!
        case .production:
            // Ton serveur qui relaie vers Claude et détient la clé
            return URL(string: "https://your-backend.example.com/tutor")!
        }
    }

    // Dev : on ajoute la clé. Prod : rien, c'est le serveur qui l'ajoute.
    static func applyAuth(to req: inout URLRequest) {
        if mode == .development {
            req.setValue(Secrets.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        }
    }
}
