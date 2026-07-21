//
//  WelcomeView.swift
//  EPFLearn
//
import SwiftUI

extension Subject {
    var displayName: String {
        switch self {
        case .analysis: return "Analysis"
        case .arrays:   return "Searching & Sorting"
        case .graphs:   return "Graphs"
        case .discreteMaths: return "Discrete Maths"
        case .linearAlgebra: return "Linear Algebra"
        }
    }

    var color: Color {
        switch self {
        case .analysis: return .blue
        case .graphs:   return .purple
        case .arrays:   return .orange
        case .discreteMaths: return .green
        case .linearAlgebra: return .pink
        }
    }
}

// One ring, one topic, one independent rate
struct SubjectRing: View {
    let subject: Subject
    let rate: Double   // 0...1

    var body: some View {
        ZStack {
            Circle()
                .stroke(subject.color.opacity(0.18), lineWidth: 8)
            Circle()
                .trim(from: 0, to: rate)
                .stroke(subject.color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int((rate * 100).rounded()))%")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(width: 64, height: 64)
    }
}

struct CategoryStat: Identifiable {
    let id = UUID()
    let subject: Subject
    let rate: Double     // 0...1
    let attempts: Int
}

struct StatisticsView: View {
    @Binding var scores: [ResultQCM]

    private let allSubjects: [Subject] = [.analysis, .graphs, .arrays, .discreteMaths, .linearAlgebra]

    // Single source of truth: summed correct answers ÷ summed questions
    private func correctRate(for category: Subject) -> Double {
        let filtered = scores.filter { $0.category == category }
        let (total, correct) = filtered.reduce(into: (0, 0)) { acc, r in
            acc.0 += r.nbQuestions
            acc.1 += r.nbCorrectAnswers
        }
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }

    // Only topics that actually have attempts
    private var categoryStats: [CategoryStat] {
        allSubjects.compactMap { subject in
            let attempts = scores.filter { $0.category == subject }.count
            guard attempts > 0 else { return nil }
            return CategoryStat(
                subject: subject,
                rate: correctRate(for: subject),
                attempts: attempts
            )
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !categoryStats.isEmpty {
                    Section("Success by topic") {
                        ForEach(categoryStats) { stat in
                            HStack(spacing: 16) {
                                SubjectRing(subject: stat.subject, rate: stat.rate)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stat.subject.displayName)
                                        .font(.headline)
                                    Text("\(stat.attempts) quiz\(stat.attempts > 1 ? "zes" : "")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Attempts") {
                    ForEach(Array(scores.enumerated()), id: \.offset) { index, result in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Try \(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text(result.category.displayName)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(result.category.color.opacity(0.15))
                                    .foregroundStyle(result.category.color)
                                    .cornerRadius(8)
                            }

                            HStack(spacing: 4) {
                                ForEach(0..<result.nbQuestions, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(result.correctAnswers.contains(i) ? Color.green : Color.red)
                                        .frame(height: 12)
                                }
                            }

                            Text("\(result.nbCorrectAnswers) / \(result.nbQuestions) correct answers")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Statistics")
            .overlay {
                if scores.isEmpty {
                    ContentUnavailableView(
                        "No finished attempt yet",
                        systemImage: "chart.bar.xaxis",
                        description: Text("Complete a quiz to see your statistics")
                    )
                }
            }
        }
    }
}
