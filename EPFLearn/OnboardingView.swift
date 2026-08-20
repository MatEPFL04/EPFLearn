//
//  OnboardingView.swift
//  EPFLearn
//
//  First-launch flow. The whole point is to put a real, live visualization
//  in front of the student (and the App Store reviewer) before anything
//  else, so the app's actual differentiator isn't hidden behind a toolbar
//  toggle three taps into a quiz.
//

import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0
    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                WelcomePage().tag(0)

                DemoPage(
                    caption: "TOUCH IT, DON'T JUST READ IT, TRY DRAGGING BELOW",
                    type: .complexNumbers
                ).tag(1)

                DemoPage(
                    caption: "47 FIGURES LIKE THIS, ACROSS 6 SUBJECTS",
                    type: .image
                ).tag(2)

                FinalPage().tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageIndicator
                .padding(.bottom, 10)

            Button {
                if page < pageCount - 1 {
                    withAnimation(.easeInOut) { page += 1 }
                } else {
                    onFinish()
                }
            } label: {
                Text(buttonLabel)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var buttonLabel: String {
        switch page {
        case 0: return "Show me"
        case pageCount - 1: return "Get Started"
        default: return "Next"
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: i == page ? 18 : 6, height: 6)
            }
        }
        .animation(.easeInOut, value: page)
    }
}

// MARK: - Page 1: welcome

private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "graduationcap.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .padding(28)
                .background(Circle().fill(Color.accentColor.opacity(0.12)))

            Text("Welcome to LearnScope")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Work through your first-year engineering courses on figures you manipulate yourself, either by answering questions about them or by building them.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 28) {
                stat("214", "questions")
                stat("47", "visualizations")
                stat("6", "subjects")
            }
            .padding(.top, 10)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title2.bold()).foregroundStyle(Color.accentColor)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Pages 2 & 3: live visualization demos

/// Embeds the *real* `VisualizationView` used inside a quiz question's Hint
/// screen (same view, same layout, same header baked into each hint view),
/// so this is pixel-for-pixel what the student gets in an actual question,
/// not a lookalike built for the onboarding.
private struct DemoPage: View {
    let caption: String
    let type: VisualizationType

    var body: some View {
        VStack(spacing: 10) {
            Text(caption)
                .font(.system(size: 11, weight: .heavy))
                .kerning(1.1)
                .foregroundStyle(Color.accentColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.top, 24)

            // A fixed height instead of letting the view expand into whatever
            // room the page has left: on shorter demos that flexible height
            // left a lot of dead grey space around the plot and made it read
            // as zoomed way out.
            VisualizationView(type: type, hint: "")
                .frame(maxWidth: 700, maxHeight: 460)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
    }
}

// MARK: - Page 4: progress + CTA

private struct FinalPage: View {
    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)

            Text("Track every step")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 14) {
                bullet("checklist", "Quiz mode: multiple choice, with the figure as a hint")
                bullet("hand.draw.fill", "Build it mode: no options, you answer by moving the figure")
                bullet("chart.bar.fill", "Progress tracks both modes, and points you at your weakest subject")
                bullet("lock.fill", "No account. Everything stays on this device.")
            }
            .padding(.horizontal, 32)
            .padding(.top, 4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func bullet(_ icon: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
