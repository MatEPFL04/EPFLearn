
import SwiftUI

/// Two ways to work through the same material: answer questions about a
/// figure, or build the figure that answers the question.
enum StudyMode: String, CaseIterable, Identifiable {
    case quiz = "Quiz"
    case build = "Build it"
    var id: Self { self }
}

struct QuizView: View {
    @Binding var vm: QuizViewModel
    /// Set from outside (the Progress tab's "focus review" button) to jump
    /// straight into a quiz for that subject, bypassing the category picker.
    @Binding var pendingSubject: Subject?
    /// Build runs are stored alongside quiz runs so they feed the same
    /// streak, stats and focus review.
    var onChallengeComplete: ((ResultQCM) -> Void)? = nil
    @State private var quizHasStarted = false

    @State private var mode: StudyMode = .quiz
    @State private var challengeVM = ChallengeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if !quizHasStarted {
                    categorySelectionView
                } else if mode == .build {
                    if challengeVM.isFinished {
                        challengeCompletionView
                    } else {
                        ChallengeView(vm: challengeVM)
                    }
                } else if vm.isFinished {
                    completionView
                } else {
                    QuestionView(vm: vm)
                }
            }
            .navigationTitle(quizHasStarted ? mode.rawValue : "Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if quizHasStarted {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: goHome) {
                            Image(systemName: "house.circle.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .onChange(of: pendingSubject) { _, newValue in
            guard let subject = newValue else { return }
            withAnimation(.easeInOut) {
                mode = .quiz
                vm.start(subject)
                quizHasStarted = true
            }
            pendingSubject = nil
        }
    }

    private func goHome() {
        vm.restart()
        challengeVM.restart()
        quizHasStarted = false
    }

    private static let catalog: [(subject: Subject, title: String, subtitle: String, icon: String, color: Color)] = [
        (.analysis, "Analysis", "Functions, integrals, limits", "chart.xyaxis.line", .blue),
        (.linearAlgebra, "Linear Algebra", "Matrices, vectors, transformations", "squareshape.split.3x3", .pink),
        (.discreteMaths, "Discrete Maths", "Combinatorics, probability, recurrence", "number.square", .green),
        (.programmingBasics, "Programming Basics", "Variables, loops, functions", "chevron.left.forwardslash.chevron.right", .indigo),
        (.arrays, "Searching & Sorting (Advanced)", "Algorithms, reasoning on inputs", "arrow.up.and.down.and.sparkles", .orange),
        (.graphs, "Graphs (Advanced)", "Visualizing and understanding graphs", "waveform.path", .purple)
    ]

    /// Two cards rather than a segmented control. The old picker gave the
    /// modes equal, silent billing and left the difference between them to a
    /// grey caption underneath; whichever one is live now fills with its own
    /// colour and says in one line what it asks of you.
    private var modeSwitch: some View {
        HStack(spacing: 10) {
            modeCard(.quiz, icon: "checklist", tint: .blue,
                     line: "Answer multiple-choice questions. The figure is there as a hint.")
            modeCard(.build, icon: "hand.draw.fill", tint: ChallengeView.tint,
                     line: "No options given. You answer by moving the figure itself.")
        }
    }

    private func modeCard(_ target: StudyMode, icon: String,
                          tint: Color, line: String) -> some View {
        let on = mode == target
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { mode = target }
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                    Text(target.rawValue)
                        .font(.subheadline.bold())
                    Spacer(minLength: 0)
                }
                Text(line)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(on ? Color.white : tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if on {
                    LinearGradient(colors: [tint, tint.opacity(0.72)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    tint.opacity(0.09)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .strokeBorder(tint.opacity(on ? 0 : 0.30), lineWidth: 1))
            .shadow(color: on ? tint.opacity(0.28) : .clear, radius: 7, y: 4)
        }
        .buttonStyle(.plain)
    }

    /// The choosing screen is where the two modes have to be told apart at a
    /// glance, so the whole page is washed in the mode's colour: deep blue for
    /// answering, teal for building. Deliberately not per subject, which would
    /// make the mode the quieter of the two signals.
    private var modeBackdrop: some View {
        // Pushed well past a tint. The two modes should be recognisable from
        // across the room, so the wash is strong at the top and the hues are
        // kept far apart: a deep indigo-blue against a vivid teal.
        let top: Color = mode == .quiz
            ? Color(red: 0.06, green: 0.24, blue: 0.78)
            : Color(red: 0.00, green: 0.62, blue: 0.62)
        let mid: Color = mode == .quiz
            ? Color(red: 0.24, green: 0.50, blue: 0.98)
            : Color(red: 0.10, green: 0.80, blue: 0.72)
        return LinearGradient(
            stops: [.init(color: top.opacity(0.62), location: 0.00),
                    .init(color: mid.opacity(0.34), location: 0.22),
                    .init(color: mid.opacity(0.10), location: 0.48),
                    .init(color: Color(.systemGroupedBackground), location: 0.80)],
            startPoint: .top, endPoint: .bottom)
    }

    /// Build mode simply drops the subjects it has nothing for, rather than
    /// listing them greyed out: a dimmed card that never becomes tappable is
    /// just a promise the app is not keeping.
    private var visibleCategories: [(subject: Subject, title: String, subtitle: String, icon: String, color: Color)] {
        mode == .quiz ? Self.catalog : Self.catalog.filter { Challenge.hasChallenges(for: $0.subject) }
    }

    // Écran de sélection stylisé
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose a subject")
                    .font(.largeTitle)
                    .bold()

                modeSwitch
            }
            .padding(.horizontal)
            .padding(.top, 20)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(visibleCategories, id: \.subject) { item in
                        CategoryCard(title: item.title,
                                     subtitle: item.subtitle,
                                     icon: item.icon,
                                     color: item.color,
                                     // Its own colour in both modes. Washing
                                     // every card turquoise in Build mode was
                                     // left over from when the cards carried
                                     // the mode signal; the page backdrop does
                                     // that now, so the tint here is free to
                                     // go back to meaning the subject.
                                     wash: LinearGradient(
                                        colors: [item.color.opacity(0.20),
                                                 item.color.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)) {
                            start(item.subject)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
        .background(modeBackdrop.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.35), value: mode)
    }

    /// The end of a build run: how many figures were solved without asking
    /// to be shown the answer.
    private var challengeCompletionView: some View {
        let solved = challengeVM.solvedIndices.count
        let total = max(challengeVM.totalChallenges, 1)
        let subject = challengeVM.category ?? .analysis

        return VStack(spacing: 20) {
            Spacer(minLength: 0)

            VStack(spacing: 14) {
                SubjectRing(subject: subject, rate: Double(solved) / Double(total))
                    .scaleEffect(1.6)
                    .frame(height: 110)

                Text("\(solved) / \(total) built yourself")
                    .font(.title2.bold())

                Text(solved == total
                     ? "Every figure built without being shown the answer."
                     : "The ones you revealed are worth another pass: build them yourself next time.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer(minLength: 0)

            VStack(spacing: 10) {
                Button {
                    withAnimation(.easeInOut) { challengeVM.retry() }
                } label: {
                    Text("New challenges in \(subject.displayName)")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(subject.color)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: goHome) {
                    Text("Back to the subject list")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    /// The end of a run used to be a green tick and nothing else: the score was
    /// already zeroed by then. It now reports what actually happened - the
    /// score, which questions fell over, and a way straight back into the same
    /// subject.
    private var completionView: some View {
        let result = vm.lastResult
        let total = max(result?.nbQuestions ?? 0, 1)
        let correct = result?.nbCorrectAnswers ?? 0
        let rate = Double(correct) / Double(total)
        let subject = result?.category ?? vm.category ?? .analysis

        return VStack(spacing: 20) {
            Spacer(minLength: 0)

            VStack(spacing: 14) {
                SubjectRing(subject: subject, rate: rate)
                    .scaleEffect(1.6)
                    .frame(height: 110)

                Text("\(correct) / \(total) correct")
                    .font(.title2.bold())

                Text(verdict(rate))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                // One mark per question, in the order they were asked. A grid
                // rather than an HStack: a long quiz would otherwise squeeze
                // the marks off the edge.
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 24), spacing: 6)], spacing: 6) {
                    ForEach(0..<total, id: \.self) { i in
                        let ok = result?.correctAnswers.contains(i) ?? false
                        Image(systemName: ok ? "checkmark" : "xmark")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(ok ? Color.green : Color.red.opacity(0.85)))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Text("Answers are saved to Progress.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)

            VStack(spacing: 10) {
                Button {
                    withAnimation(.easeInOut) { vm.retry() }
                } label: {
                    Text("New questions in \(subject.displayName)")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(subject.color)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    vm.restart()
                    quizHasStarted = false
                } label: {
                    Text("Back to the subject list")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func verdict(_ rate: Double) -> String {
        switch rate {
        case 1:         return "Every question right."
        case 0.8...:    return "Solid run: only a detail or two to revisit."
        case 0.5..<0.8: return "Half the ground is yours. The hint views cover the rest."
        default:        return "Worth another pass: open the hint on each question you missed."
        }
    }

    private func start(_ subject: Subject) {
        withAnimation(.easeInOut) {
            switch mode {
            case .quiz:
                vm.start(subject)
            case .build:
                challengeVM.onComplete = onChallengeComplete
                challengeVM.start(subject)
            }
            quizHasStarted = true
        }
    }
}

// Composant réutilisable pour les cartes de catégories
struct CategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    /// Laid over the card's surface so the whole list changes character with
    /// the study mode, instead of the mode living only in a segmented control
    /// nobody looks at twice.
    var wash: LinearGradient? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background { if let wash { wash } }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
