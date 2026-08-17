//
//  BinomialCoefficientsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Pascal's triangle, kept to one screen: the triangle itself and a detail
/// card that only appears once an entry is tapped.
struct BinomialCoefficientsView: View {
    @State private var rows: Int = 7
    @State private var selectedN: Int? = nil
    @State private var selectedK: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VizHeader("Binomial Coefficients", subtitle: "C(n,k) is the number of k-element subsets of a set of n.")

            VizSlider(label: "Pascal rows", intValue: $rows, range: 2...9,
                      accent: .blue, caption: "up to n = \(rows - 1)")
                .onChange(of: rows) { newValue in
                    if let n = selectedN, n >= newValue {
                        selectedN = nil
                        selectedK = nil
                    }
                }

            triangle

            if let n = selectedN, let k = selectedK {
                selectionCard(n: n, k: k)
            } else {
                Label("Tap an entry to see where it comes from.", systemImage: "hand.tap")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    // MARK: - The triangle

    private var triangle: some View {
        VStack(spacing: 5) {
            ForEach(0..<rows, id: \.self) { n in
                HStack(spacing: 4) {
                    ForEach(0...n, id: \.self) { k in
                        cell(n: n, k: k)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
    }

    private func cell(n: Int, k: Int) -> some View {
        let value = binomialCoefficient(n, k)
        let isSelected = (selectedN == n && selectedK == k)
        // Both parents of the selected entry: C(n,k) = C(n-1,k-1) + C(n-1,k).
        let isParent: Bool = {
            guard let sel = selectedN, let selK = selectedK else { return false }
            guard n == sel - 1 else { return false }
            return k == selK - 1 || k == selK
        }()
        // Spelled out rather than nested in ternaries: the type checker chokes
        // on three-deep colour conditionals inside a modifier chain.
        let foreground: Color
        let background: Color
        let border: Color
        if isSelected {
            foreground = .white; background = .purple; border = .clear
        } else if isParent {
            foreground = .orange; background = Color.orange.opacity(0.22); border = .orange
        } else {
            foreground = .purple; background = Color.purple.opacity(0.08); border = .clear
        }

        return Text("\(value)")
            .font(.system(size: cellFontSize, weight: isSelected ? .bold : .regular, design: .rounded))
            .foregroundStyle(foreground)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(width: cellSize, height: cellSize)
            .background(RoundedRectangle(cornerRadius: 7).fill(background))
            .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(border, lineWidth: 1.5))
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .onTapGesture {
                withAnimation(.spring(duration: 0.3)) {
                    if selectedN == n && selectedK == k {
                        selectedN = nil
                        selectedK = nil
                    } else {
                        selectedN = n
                        selectedK = k
                    }
                }
            }
    }

    // MARK: - Detail of the tapped entry

    private func selectionCard(n: Int, k: Int) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("C(\(n),\(k)) = \(binomialCoefficient(n, k))")
                    .font(.headline.monospaced())
                    .foregroundStyle(.purple)
                Spacer()
                Button {
                    withAnimation {
                        selectedN = nil
                        selectedK = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            if k == 0 || k == n {
                detailRow(.orange, "Edge of the row: always 1.")
            } else {
                detailRow(.orange,
                          "C(\(n-1),\(k-1)) + C(\(n-1),\(k)) = \(binomialCoefficient(n-1, k-1)) + \(binomialCoefficient(n-1, k))   (the two orange parents)")
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
        .transition(.opacity)
    }

    private func detailRow(_ tint: Color, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 7) {
            Circle().fill(tint).frame(width: 5, height: 5).padding(.top, 6)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Metrics

    private var cellSize: CGFloat {
        switch rows {
        case ...4: return 46
        case 5:    return 42
        case 6:    return 38
        case 7:    return 34
        case 8:    return 30
        default:   return 27
        }
    }

    private var cellFontSize: CGFloat {
        switch rows {
        case ...5: return 17
        case 6, 7: return 14
        default:   return 12
        }
    }

    private func binomialCoefficient(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        if k == 0 || k == n { return 1 }

        let k = min(k, n - k)
        var result = 1
        for i in 0..<k {
            result = result * (n - i) / (i + 1)
        }
        return result
    }
}

#Preview {
    BinomialCoefficientsView()
}
