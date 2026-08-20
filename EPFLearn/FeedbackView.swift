//
//  FeedbackView.swift
//  EPFLearn
//
//  Two different opinions want two different destinations: a happy tap
//  belongs on the App Store, where it helps the app get found. A bug or a
//  half-formed idea belongs in an email, where it can actually get read and
//  answered. Funnelling both into one inbox loses the first, and funnelling
//  both into a star rating loses the second.
//

import SwiftUI
import MessageUI

// MARK: - Entry: which kind of opinion is this

struct FeedbackView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section {
                Text("How's LearnScope working for you?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .listRowBackground(Color.clear)

            Section {
                Button {
                    openURL(RateAppManager.writeReviewURL)
                } label: {
                    Label("Enjoying it? Leave a review", systemImage: "star.fill")
                }
            } footer: {
                Text("Opens LearnScope's App Store page to write a public review.")
            }

            Section {
                NavigationLink {
                    FeedbackFormView()
                } label: {
                    Label("Something to report or suggest?", systemImage: "envelope.fill")
                }
            } footer: {
                Text("Bugs and ideas go straight to the developer by email.")
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - The written-feedback form

enum FeedbackCategory: String, CaseIterable, Identifiable {
    case bug = "Bug"
    case improvement = "Improvement idea"
    case experience = "Overall experience"
    case other = "Something else"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bug:         return "ladybug.fill"
        case .improvement: return "lightbulb.fill"
        case .experience:  return "bubble.left.and.bubble.right.fill"
        case .other:       return "ellipsis.circle.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .bug:         return "What went wrong, and what were you doing when it happened?"
        case .improvement: return "What would make this better?"
        case .experience:  return "How has studying with LearnScope been going?"
        case .other:       return "Tell us anything."
        }
    }
}

struct FeedbackFormView: View {
    private static let recipient = "matteo.lazzari@epfl.ch"

    @State private var category: FeedbackCategory = .improvement
    @State private var message = ""
    @State private var showMailComposer = false
    @State private var showMailUnavailable = false

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "n/a"
        let build   = info?["CFBundleVersion"] as? String ?? "n/a"
        return "\(version) (\(build))"
    }

    private var subject: String { "LearnScope feedback: \(category.rawValue)" }

    private var mailBody: String {
        "\(message)\n\nCategory: \(category.rawValue)\nApp version: \(appVersion)"
    }

    var body: some View {
        List {
            Section("Category") {
                Picker("Category", selection: $category) {
                    ForEach(FeedbackCategory.allCases) { c in
                        Label(c.rawValue, systemImage: c.icon).tag(c)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 160)
                    .overlay(alignment: .topLeading) {
                        if message.isEmpty {
                            Text(category.placeholder)
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
            } header: {
                Text("Your message")
            } footer: {
                Text("Opens Mail, addressed to the developer. Only your message, the category, and the app version go with it, nothing else about you or your device.")
            }

            Section {
                Button {
                    send()
                } label: {
                    HStack {
                        Spacer()
                        Text("Send Feedback").fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMailComposer) {
            MailComposerView(recipient: Self.recipient, subject: subject, body: mailBody)
        }
        .alert("Mail isn't set up", isPresented: $showMailUnavailable) {
            Button("Copy Address") { UIPasteboard.general.string = Self.recipient }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Add a Mail account in Settings, or email \(Self.recipient) directly.")
        }
    }

    private func send() {
        if MFMailComposeViewController.canSendMail() {
            showMailComposer = true
        } else {
            showMailUnavailable = true
        }
    }
}

// MARK: - Mail composer bridge

private struct MailComposerView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                    didFinishWith result: MFMailComposeResult,
                                    error: Error?) {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        FeedbackView()
    }
    .preferredColorScheme(.dark)
}
