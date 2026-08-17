
import SwiftUI

struct QuizView: View {
    @Binding var vm: QuizViewModel
    /// Set from outside (the Progress tab's "focus review" button) to jump
    /// straight into a quiz for that subject, bypassing the category picker.
    @Binding var pendingSubject: Subject?
    @State private var quizHasStarted = false

    var body: some View {
        NavigationStack {
            Group {
                if !quizHasStarted {
                    categorySelectionView
                } else if vm.isFinished {
                    completionView
                } else {
                    QuestionView(vm: vm)
                }
            }
            .navigationTitle(quizHasStarted ? "Quiz" : "Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if quizHasStarted {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            vm.restart()
                            quizHasStarted = false
                        }) {
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
                vm.start(subject)
                quizHasStarted = true
            }
            pendingSubject = nil
        }
    }

    // Écran de sélection stylisé
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Choose a category")
                    .font(.largeTitle)
                    .bold()
            }
            .padding(.horizontal)
            .padding(.top, 20)

            ScrollView {
                VStack(spacing: 16) {
                    CategoryCard(title: "Analysis", subtitle: "Functions, integrals, limits", icon: "chart.xyaxis.line", color: .blue) {
                        startQuiz(index: 0)
                    }
                    
                    CategoryCard(title: "Linear Algebra", subtitle: "Matrices, vectors, transformations", icon: "squareshape.split.3x3", color: .pink) {
                        startQuiz(index: 4)
                    }
                    
                    
                    CategoryCard(title: "Discrete Maths", subtitle: "Combinatorics, probability, recurrence", icon: "number.square", color: .green) {
                        startQuiz(index: 3)
                    }
                    
                    CategoryCard(title: "Programming Basics", subtitle: "Variables, loops, functions", icon: "chevron.left.forwardslash.chevron.right", color: .indigo) {
                        startQuiz(index: 5)
                    }
                    
                    
                    CategoryCard(title: "Searching & Sorting (Advanced)", subtitle: "Algorithms, reasoning on inputs", icon: "arrow.up.and.down.and.sparkles", color: .orange) {
                        startQuiz(index: 1)
                    }
          
                   
                    CategoryCard(title: "Graphs (Advanced)", subtitle: "Visualizing and understanding graphs", icon: "waveform.path", color: .purple) {
                        startQuiz(index: 2)
                    }
                    
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
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
                    Text("Back to the category menu")
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

    private func startQuiz(index: Int) {
        withAnimation(.easeInOut) {
            vm.tapped(index)
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
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
