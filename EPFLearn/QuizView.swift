
import SwiftUI

struct QuizView: View {
    @Binding var vm: QuizViewModel
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
                    
                    CategoryCard(title: "Graphs", subtitle: "Visualizing and understanding graphs", icon: "waveform.path", color: .purple) {
                        startQuiz(index: 2)
                    }
                    
                    CategoryCard(title: "Searching & Sorting", subtitle: "Algorithms, reasoning on inputs", icon: "arrow.up.and.down.and.sparkles", color: .orange) {
                        startQuiz(index: 1)
                    }
                    
                    CategoryCard(title: "Discrete Maths", subtitle: "Combinatorics, probability, recurrence", icon: "number.square", color: .green) {
                        startQuiz(index: 3)
                    }
                    
                    CategoryCard(title: "Linear Algebra", subtitle: "Matrices, vectors, transformations", icon: "squareshape.split.3x3", color: .pink) {
                        startQuiz(index: 4)
                    }
                    
                    CategoryCard(title: "Programming Basics", subtitle: "Variables, loops, functions", icon: "chevron.left.forwardslash.chevron.right", color: .indigo) {
                        startQuiz(index: 5)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    // Écran de fin stylisé
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Quiz finished !")
                .font(.title)
                .bold()
            
            Button(action: { vm.restart() }) {
                Text("Start again")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
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
