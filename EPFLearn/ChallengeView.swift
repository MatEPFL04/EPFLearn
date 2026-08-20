//
//  ChallengeView.swift
//  EPFLearn
//
//  The inverted question. The figure fills the screen and stays live, the
//  instruction sits above it, and below it nothing but the attempts left and
//  a Check button. There is no warmer/colder meter on purpose: with one, the
//  fastest route to every answer was to wiggle and watch the bar. Nor is the
//  figure's state echoed under the prompt, because every view already prints
//  its own values and the duplication only squeezed the picture.
//

import SwiftUI

struct ChallengeView: View {
    var vm: ChallengeViewModel

    /// Build mode wears its own colour rather than the quiz's blue: a
    /// turquoise that reads as a different room, not a different accent.
    static let tint = Color(red: 0.06, green: 0.65, blue: 0.68)
    static let tintDeep = Color(red: 0.03, green: 0.40, blue: 0.50)

    /// The chrome is washed with a gradient rather than a flat fill, so the
    /// bands above and below the figure have some depth to them and the
    /// figure itself reads as the lit part of the screen.
    static func gradient(_ opacity: Double) -> LinearGradient {
        LinearGradient(colors: [tint.opacity(opacity),
                                tintDeep.opacity(opacity * 0.65)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Solid version for anything carrying white text.
    static let solid = LinearGradient(colors: [tint, tintDeep],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)

    var body: some View {
        VStack(spacing: 0) {
            if let challenge = vm.currentChallenge {
                promptCard(challenge)

                ChallengeCanvas(type: challenge.visualization) { reading in
                    vm.report(reading)
                }
                .frame(maxHeight: .infinity)

                if vm.resolved {
                    resolutionCard(challenge)
                } else {
                    commitBar
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.resolved)
        .animation(.easeInOut(duration: 0.2), value: vm.lastCommitFailed)
    }

    // MARK: Prompt

    private func promptCard(_ challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Self.solid))

                Text("BUILD IT")
                    .font(.system(size: 11, weight: .heavy))
                    .kerning(1.2)
                    .foregroundStyle(Self.tint)

                Spacer(minLength: 0)

                Text("\(vm.currentIndex + 1) / \(vm.totalChallenges)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            // Now that nothing else is written in the chrome, the instruction
            // can carry the weight it deserves: it is the only thing on screen
            // that is not the figure.
            Text(challenge.prompt)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
        .background(Self.gradient(0.22))
        .background(.regularMaterial)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Self.tint.opacity(0.35)).frame(height: 1)
        }
    }

    // MARK: Commit

    private var commitBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            // No echo of the figure's own numbers here: every view already
            // prints them, and repeating them under the prompt just pushed
            // the picture up the screen.
            if let blocker = vm.feedback.blocker {
                Label(blocker, systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if vm.lastCommitFailed {
                Label(vm.attemptsExhausted
                      ? "Still not it. Take the worked example and move on."
                      : "Not this configuration. Read the figure again.",
                      systemImage: "xmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 12) {
                attemptDots

                Spacer(minLength: 16)

                Button("Show me") { vm.reveal() }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(vm.attemptsExhausted ? ChallengeView.tint : .secondary)

                Button {
                    vm.check()
                } label: {
                    Text("Check")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 9)
                        .background(Self.solid)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(vm.attemptsExhausted)
                .opacity(vm.attemptsExhausted ? 0.4 : 1)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }

    /// One dot per remaining commit. Spending them is the cost that makes a
    /// guess a real decision rather than a free roll.
    private var attemptDots: some View {
        HStack(spacing: 5) {
            ForEach(0..<ChallengeViewModel.maxAttempts, id: \.self) { i in
                Circle()
                    .fill(i < vm.attempts ? Color.red.opacity(0.65) : ChallengeView.tint.opacity(0.35))
                    .frame(width: 7, height: 7)
            }
        }
    }

    // MARK: Solved or revealed

    private func resolutionCard(_ challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: vm.revealedCurrent ? "eye.fill" : "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Self.solid))

                Text(vm.revealedCurrent ? "REVEALED" : "YOU BUILT IT")
                    .font(.system(size: 11, weight: .heavy))
                    .kerning(1.2)
                    .foregroundStyle(Self.tint)

                Spacer(minLength: 0)
            }

            // The worked example runs to a few paragraphs, and it must not
            // push the Next button off the bottom of the screen.
            ScrollView {
                Text(challenge.explanation)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 190)

            Button {
                vm.next()
            } label: {
                HStack(spacing: 6) {
                    Text(vm.currentIndex + 1 < vm.totalChallenges ? "Next challenge" : "See results")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Self.solid)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
        .background(Self.gradient(0.22))
        .background(.regularMaterial)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - Hosting the live figure

/// Same role as `VisualizationView`'s switch, but wires each figure's
/// reading callback so the run can grade it. Only the types that report a
/// reading belong here; everything else has no challenges yet.
private struct ChallengeCanvas: View {
    let type: VisualizationType
    let onReading: (ChallengeReading) -> Void

    /// Figures that already scroll internally. Wrapping one of those in a
    /// second ScrollView is what made a downward drag move a slider instead of
    /// the page: two scroll views on the same axis fight over the gesture and
    /// whichever loses hands it to whatever control is underneath.
    private var scrollsItself: Bool {
        switch type {
        case .determinant, .image, .linearTransformations, .matrixOperations, .setOperations:
            return true
        default:
            return false
        }
    }

    var body: some View {
        GeometryReader { proxy in
            Group {
                if scrollsItself {
                    content
                } else {
                    ScrollView {
                        content
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: proxy.size.height, alignment: .center)
                    }
                    // No rubber-banding when the figure already fits: the
                    // bounce reads as "this moved" and sends you hunting for
                    // what you just changed.
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .environment(\.plotWidth, proxy.size.width)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch type {
        case .complexNumbers:    ComplexPlaneView(onReading: onReading)
        case .trigo:             TrigoView(onReading: onReading)
        case .TAF:               TAFView(onReading: onReading)
        case .determinant:       VectorSpaceView(is3D: false, onReading: onReading)
        case .matrixOperations:  MatrixOperationsView(onReading: onReading)
        case .image:             ImageSpaceView(onReading: onReading)
        case .bitwiseOperations: BitwiseView(onReading: onReading)
        case .linearTransformations: Matrix3DView(onReading: onReading)
        case .pigeonholePrinciple:   PigeonholePrincipleView(onReading: onReading)
        case .setOperations:         VennDiagramView(onReading: onReading)
        case .forLoop:               ForLoopView(onReading: onReading)
        case .binomialCoefficients:  BinomialCoefficientsView(onReading: onReading)
        case .expectation:           ExpectationView(onReading: onReading)
        default:
            ContentUnavailableView("No challenge here yet",
                                   systemImage: "hammer",
                                   description: Text("This visualization doesn't report a state to grade."))
        }
    }
}
