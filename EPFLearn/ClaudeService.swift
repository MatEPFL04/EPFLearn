//
//  ClaudeService.swift
//  EPFLearn
//
//  Created by Mat on 19.07.2026.
//

import Foundation

enum ClaudeError: Error { case badResponse(Int) }

struct ClaudeMessage {
    let role: String   // "user" | "assistant"
    let text: String
}

struct ClaudeService {

    /// Diffuse les morceaux de texte au fur et à mesure qu'ils arrivent.
    func streamMessage(
        system: String,
        messages: [ClaudeMessage],
        model: String = ClaudeConfig.model,
        maxTokens: Int = 512
    ) -> AsyncThrowingStream<String, Error> {

        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var req = URLRequest(url: ClaudeConfig.endpoint)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
                    ClaudeConfig.applyAuth(to: &req)

                    let body: [String: Any] = [
                        "model": model,
                        "max_tokens": maxTokens,
                        "stream": true,                       // ← active le SSE
                        "system": system,
                        "messages": messages.map { ["role": $0.role, "content": $0.text] }
                    ]
                    req.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: req)

                    guard let http = response as? HTTPURLResponse,
                          http.statusCode == 200 else {
                        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                        throw ClaudeError.badResponse(code)
                    }

                    // Le flux SSE arrive ligne par ligne : "data: {json}", "event: …", ""
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else { continue }
                        let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)

                        guard let data = payload.data(using: .utf8),
                              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let type = obj["type"] as? String
                        else { continue }

                        if type == "content_block_delta",
                           let delta = obj["delta"] as? [String: Any],
                           let text = delta["text"] as? String {
                            continuation.yield(text)          // ← un morceau de réponse
                        } else if type == "message_stop" {
                            break
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
