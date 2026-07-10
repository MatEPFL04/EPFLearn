//
//  WelcomeView.swift
//  EPFLearn
//
//  Created by Mat on 09.04.2026.
//
import SwiftUI

extension Subject {
    var displayName: String {
        switch self {
        case .analysis: return "Analysis"
        case .arrays: return "Searching & Sorting"
        case .graphs: return "Graphs"
        }
    }
    
    var color: Color {
        switch self {
        case .analysis: return .blue
        case .graphs: return .purple
        case .arrays: return .orange
        }
    }
}

// 2. Vue des statistiques mise à jour
struct StatisticsView: View {
    @Binding var scores: [ResultQCM]
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(scores.enumerated()), id: \.offset) { index, result in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Try \(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            // Badge typé utilisant notre extension
                            Text(result.category.displayName)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(result.category.color.opacity(0.15))
                                .foregroundStyle(result.category.color)
                                .cornerRadius(8)
                        }
                        
                        // Barrettes de progression (Vert / Rouge)
                        HStack(spacing: 4) {
                            ForEach(0..<result.nbQuestions, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(result.correctAnswers.contains(i) ? Color.green : Color.red)
                                    .frame(height: 12)
                            }
                        }
                        
                        // Score numérique
                        Text("\(result.nbCorrectAnswers) / \(result.nbQuestions) correct answers")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
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
