//
//  SequenceView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//
import SwiftUI
import Combine

struct SequenceView: View {
    
    @State private var visibleCount: Int = 0
    @State private var isPlaying: Bool = false
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    let totalTerms = 16
    let graphW: CGFloat = 280
    let graphH: CGFloat = 130
    
    // cos(nπ/2) : vaut 1, 0, -1, 0, 1, 0, -1, 0...
    func u(_ n: Int) -> Double { cos(Double(n) * .pi / 2) }
    
    // Sous-suite : indices pairs → vaut toujours 0
    var subIndices: [Int] { (0..<totalTerms).filter { $0 % 4 == 0 } }
    
    var visibleAllTerms: [(index: Int, value: Double)] {
        (0..<min(visibleCount, totalTerms)).map { ($0, u($0)) }
    }
    
    var visibleSubTerms: [(subIndex: Int, value: Double)] {
        subIndices
            .filter { $0 < visibleCount }
            .enumerated()
            .map { ($0.offset, u($0.element)) }
    }
    
    func xAll(_ i: Int) -> CGFloat {
        CGFloat(i) / CGFloat(totalTerms - 1) * (graphW - 20) + 10
    }
    
    func xSub(_ k: Int) -> CGFloat {
        CGFloat(k) / CGFloat(subIndices.count - 1) * (graphW - 40) + 20
    }
    
    func yVal(_ v: Double) -> CGFloat {
        graphH / 2 - CGFloat(v) * (graphH / 2 - 12)
    }
    
    var body: some View {
        Form {
            
            // Graphique 1 : toute la suite
            VStack(alignment: .leading, spacing: 6) {
                Text("uₙ = cos(nπ/2) — alterne entre 1, 0, −1")
                    .font(.caption).foregroundStyle(.secondary)
                
                ZStack(alignment: .topLeading) {
                    Color.white
                    
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: graphH / 2))
                        p.addLine(to: CGPoint(x: graphW, y: graphH / 2))
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    
                    // Segments orange
                    Path { p in
                        guard visibleAllTerms.count > 1 else { return }
                        p.move(to: CGPoint(x: xAll(0), y: yVal(u(0))))
                        for item in visibleAllTerms.dropFirst() {
                            p.addLine(to: CGPoint(x: xAll(item.index), y: yVal(item.value)))
                        }
                    }
                    .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    
                    ForEach(visibleAllTerms, id: \.index) { item in
                        Circle()
                            .fill(subIndices.contains(item.index) ? Color.blue : Color.orange)
                            .frame(width: 8, height: 8)
                            .position(x: xAll(item.index), y: yVal(item.value))
                    }
                }
                .frame(width: graphW, height: graphH)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
            }
            
            // Graphique 2 : sous-suite réindexée
            VStack(alignment: .leading, spacing: 6) {
                Text("u_φ(k) = cos(4k * π/2) = 1")
                    .font(.caption).foregroundStyle(.secondary)
                
                ZStack(alignment: .topLeading) {
                    Color.white
                    
                    // Ligne l = 1
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: yVal(1.0)))
                        p.addLine(to: CGPoint(x: graphW, y: yVal(1.0)))
                    }
                    .stroke(Color.red.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                    
                    Text("l = 1")
                        .font(.system(size: 10))
                        .foregroundStyle(.red.opacity(0.8))
                        .position(x: 18, y: yVal(1.0) - 12)
                    
                    ForEach(visibleSubTerms, id: \.subIndex) { item in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 9, height: 9)
                            .position(x: xSub(item.subIndex), y: yVal(item.value))
                    }
                }
                .frame(width: graphW, height: graphH)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
            }
            
            HStack(spacing: 12) {
                Button(isPlaying ? "Pause" : "Lancer") { isPlaying.toggle() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { isPlaying = false; visibleCount = 0 }
                    .buttonStyle(.bordered)
            }
        }
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            if visibleCount < totalTerms { visibleCount += 1 }
            else { isPlaying = false }
        }
    }
}
#Preview {
    SequenceView()
}
