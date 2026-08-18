//
//  StatisticsView.swift
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
        case .programmingBasics: return "Programming Basics"
        }
    }

    var color: Color {
        switch self {
        case .analysis: return .blue
        case .graphs:   return .purple
        case .arrays:   return .orange
        case .discreteMaths: return .green
        case .linearAlgebra: return .pink
        case .programmingBasics: return .indigo
        }
    }

    var icon: String {
        switch self {
        case .analysis: return "chart.xyaxis.line"
        case .linearAlgebra: return "squareshape.split.3x3"
        case .discreteMaths: return "number.square"
        case .programmingBasics: return "chevron.left.forwardslash.chevron.right"
        case .arrays: return "arrow.up.and.down.and.sparkles"
        case .graphs: return "waveform.path"
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

    /// Per-subject success rate from a set of completed runs, in one place
    /// so "what is the student struggling with" is computed the same way
    /// wherever it is asked.
    static func compute(from scores: [ResultQCM], subjects: [Subject]) -> [CategoryStat] {
        subjects.compactMap { subject in
            let filtered = scores.filter { $0.category == subject }
            let total = filtered.reduce(0) { $0 + $1.nbQuestions }
            guard total > 0 else { return nil }
            let correct = filtered.reduce(0) { $0 + $1.nbCorrectAnswers }
            return CategoryStat(subject: subject, rate: Double(correct) / Double(total), attempts: filtered.count)
        }
    }
}

// One attempt = one row (bars + label)
struct AttemptRow: View {
    let number: Int
    let result: ResultQCM

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Try \(number)")
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

            Text("\(result.nbCorrectAnswers) / \(result.nbQuestions) right")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

struct StatisticsView: View {
    @Binding var scores: [ResultQCM]
    var streak: Int
    var onStartReview: (Subject) -> Void

    // How many attempts stay visible before collapsing
    private let previewCount = 5
    @State private var showAllAttempts = false

    private let allSubjects: [Subject] = [.analysis, .linearAlgebra, .discreteMaths, .programmingBasics, .arrays, .graphs]

    // Only topics that actually have attempts
    private var categoryStats: [CategoryStat] {
        CategoryStat.compute(from: scores, subjects: allSubjects)
    }

    // Most recent first, keeping the original "Try n" numbering
    private struct Attempt: Identifiable {
        let id: Int
        let number: Int
        let result: ResultQCM
    }

    private var attempts: [Attempt] {
        Array(scores.enumerated())
            .reversed()
            .map { Attempt(id: $0.offset, number: $0.offset + 1, result: $0.element) }
    }

    private var visibleAttempts: [Attempt] {
        showAllAttempts ? attempts : Array(attempts.prefix(previewCount))
    }

    /// The topic most worth revisiting: lowest success rate, but only surfaced
    /// once there's an actual track record and it's genuinely below par - a
    /// single unlucky run shouldn't nag.
    private var weakestTopic: CategoryStat? {
        categoryStats
            .filter { $0.attempts >= 2 && $0.rate < 0.75 }
            .min { $0.rate < $1.rate }
    }

    var body: some View {
        NavigationStack {
            List {
                if streak > 0 {
                    Section {
                        HStack(spacing: 12) {
                            Text("🔥")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(streak)-day streak")
                                    .font(.headline)
                                Text(streak == 1
                                     ? "Practice again tomorrow to keep it going"
                                     : "Keep it going, come back tomorrow")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }

                if let weak = weakestTopic {
                    Section {
                        Button {
                            onStartReview(weak.subject)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "target")
                                    .font(.title2)
                                    .foregroundStyle(weak.subject.color)
                                    .frame(width: 36)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Focus review: \(weak.subject.displayName)")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("\(Int((weak.rate * 100).rounded()))% correct so far, practice this topic")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !categoryStats.isEmpty {
                    Section("Success rate by topic") {
                        ForEach(categoryStats) { stat in
                            HStack(spacing: 16) {
                                SubjectRing(subject: stat.subject, rate: stat.rate)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stat.subject.displayName)
                                        .font(.headline)
                                    Text("\(stat.attempts) run\(stat.attempts > 1 ? "s" : "")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section {
                    ForEach(visibleAttempts) { attempt in
                        AttemptRow(number: attempt.number, result: attempt.result)
                    }

                    if scores.count > previewCount {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showAllAttempts.toggle()
                            }
                        } label: {
                            HStack {
                                Text(showAllAttempts
                                     ? "Show less"
                                     : "Show all \(scores.count) attempts")
                                Spacer()
                                Image(systemName: showAllAttempts ? "chevron.up" : "chevron.down")
                                    .font(.caption.weight(.bold))
                            }
                            .font(.subheadline.weight(.semibold))
                        }
                    }
                } header: {
                    HStack {
                        Text("Attempts")
                        Spacer()
                        if !scores.isEmpty {
                            Text("\(scores.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Progress")
            .overlay {
                if scores.isEmpty {
                    ContentUnavailableView(
                        "Nothing to show yet",
                        systemImage: "chart.bar.xaxis",
                        description: Text("Finish a run in either study mode and it lands here.")
                    )
                }
            }
        }
    }
}
