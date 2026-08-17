//
//  ClassView.swift
//  EPFLearn
//
//  One idea: a class is a blueprint. Every `new` stamps out an
//  independent instance with its own fields. A method acts on `this`
//  instance only - touching one object never touches the other.
//

import SwiftUI

struct ClassView: View {

    /// Two objects or one object under two names. The second variant exists
    /// because "Counter b = a" is the case the aliasing question asks about,
    /// and drawing only "b = new Counter()" left that question with nothing
    /// on screen to check it against.
    enum Variant: String, CaseIterable {
        case separate, alias

        var label: String { self == .separate ? "two objects" : "one object, two names" }
        var declLine: String {
            self == .separate ? "Counter b = new Counter();" : "Counter b = a;"
        }
    }

    @State private var step = 0
    @State private var variant: Variant = .separate

    private var code: [String] {
        ["class Counter {",
         "    int count = 0;",
         "    void inc() { count++; }",
         "}",
         "",
         "Counter a = new Counter();",
         variant.declLine,
         "a.inc();",
         "a.inc();",
         "b.inc();"]
    }

    private struct Frame {
        let line: Int
        let aLive: Bool
        let bLive: Bool
        let aCount: Int
        let bCount: Int
        let target: Character?   // which instance a method runs on
        let note: String?
    }

    private var frames: [Frame] {
        switch variant {
        case .separate:
            return [
                Frame(line: 0, aLive: false, bLive: false, aCount: 0, bCount: 0, target: nil,
                      note: "the class is only a blueprint, no object yet"),
                Frame(line: 5, aLive: true, bLive: false, aCount: 0, bCount: 0, target: nil,
                      note: "new Counter(): instance a, its own count = 0"),
                Frame(line: 6, aLive: true, bLive: true, aCount: 0, bCount: 0, target: nil,
                      note: "new Counter(): instance b, a separate count = 0"),
                Frame(line: 7, aLive: true, bLive: true, aCount: 1, bCount: 0, target: "a",
                      note: "a.inc(): this = a, so a.count++"),
                Frame(line: 8, aLive: true, bLive: true, aCount: 2, bCount: 0, target: "a",
                      note: "a.inc() again: a.count = 2, b untouched"),
                Frame(line: 9, aLive: true, bLive: true, aCount: 2, bCount: 1, target: "b",
                      note: "b.inc(): this = b, only b.count changes"),
                Frame(line: -1, aLive: true, bLive: true, aCount: 2, bCount: 1, target: nil,
                      note: "two instances, two independent states")
            ]
        case .alias:
            // One 'new', so one object throughout: both counts track the same
            // field, which is the whole point of the variant.
            return [
                Frame(line: 0, aLive: false, bLive: false, aCount: 0, bCount: 0, target: nil,
                      note: "the class is only a blueprint, no object yet"),
                Frame(line: 5, aLive: true, bLive: false, aCount: 0, bCount: 0, target: nil,
                      note: "new Counter(): instance a, its own count = 0"),
                Frame(line: 6, aLive: true, bLive: true, aCount: 0, bCount: 0, target: nil,
                      note: "Counter b = a: no second new, so b names that same instance"),
                Frame(line: 7, aLive: true, bLive: true, aCount: 1, bCount: 1, target: "a",
                      note: "a.inc(): count = 1, and b reads that very field"),
                Frame(line: 8, aLive: true, bLive: true, aCount: 2, bCount: 2, target: "a",
                      note: "a.inc() again: count = 2, so b.count is 2 as well"),
                Frame(line: 9, aLive: true, bLive: true, aCount: 3, bCount: 3, target: "b",
                      note: "b.inc(): the same field once more, count = 3"),
                Frame(line: -1, aLive: true, bLive: true, aCount: 3, bCount: 3, target: nil,
                      note: "one instance, one state, reachable under either name")
            ]
        }
    }

    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            PBHeader(title: "Classes") {
                Picker("", selection: $variant) {
                    ForEach(Variant.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: variant) { step = 0 }
            }

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: code.map { PBCodePane.Line(code: $0) },
                           current: fr.line, accent: .cyan)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: .cyan)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var stage: some View {
        VStack(spacing: 10) {
            blueprint
            HStack(spacing: 6) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary.opacity(0.35))
                Text("new")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.5))
            }
            HStack(spacing: 14) {
                if variant == .alias {
                    // One box, and once 'Counter b = a' has run, both names on
                    // it. Two boxes here would draw the very mistake the
                    // aliasing question is asking about.
                    instance(fr.bLive ? "a, b" : "a", live: fr.aLive, count: fr.aCount,
                             color: .cyan, active: fr.target != nil)
                } else {
                    instance("a", live: fr.aLive, count: fr.aCount,
                             color: .cyan, active: fr.target == "a")
                    instance("b", live: fr.bLive, count: fr.bCount,
                             color: Color(red: 0.72, green: 0.52, blue: 1.0),
                             active: fr.target == "b")
                }
            }
        }
        .padding(10)
        .frame(minHeight: 158)
        .pbViewport()
        .overlay(alignment: .bottomLeading) {
            if let note = fr.note { PBNote(text: note).padding(7) }
        }
        .animation(.spring(duration: 0.3), value: step)
    }

    private var blueprint: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "doc.text")
                    .font(.system(size: 10)).foregroundColor(.primary.opacity(0.5))
                Text("class Counter")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.85))
            }
            HStack(spacing: 10) {
                Text("int count")
                    .font(.system(size: 11, design: .monospaced)).foregroundColor(.primary.opacity(0.5))
                Text("void inc()")
                    .font(.system(size: 11, design: .monospaced)).foregroundColor(.primary.opacity(0.5))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(.primary.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(.primary.opacity(0.15),
                          style: StrokeStyle(lineWidth: 1.2, dash: [5])))
    }

    private func instance(_ name: String, live: Bool, count: Int,
                          color: Color, active: Bool) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 5) {
                Circle().fill(live ? color : .primary.opacity(0.15))
                    .frame(width: 7, height: 7)
                Text(name)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(live ? color : .primary.opacity(0.25))
                Text(": Counter")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary.opacity(live ? 0.4 : 0.15))
            }

            VStack(spacing: 3) {
                Text("count")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.4))
                Text(live ? "\(count)" : "·")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundColor(live ? .primary : .primary.opacity(0.15))
                    .contentTransition(.numericText())
            }
            .frame(width: 84, height: 60)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(live ? (active ? 0.24 : 0.12) : 0.03)))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(color.opacity(live ? (active ? 1 : 0.4) : 0.12),
                              style: StrokeStyle(lineWidth: active ? 2 : 1,
                                                 dash: live ? [] : [4])))
            .shadow(color: active ? color.opacity(0.6) : .clear, radius: 10)

            if active {
                Text("this")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(color.opacity(0.18)))
                    .transition(.scale.combined(with: .opacity))
            } else {
                Color.clear.frame(height: 18)
            }
        }
        .scaleEffect(active ? 1.04 : 1)
    }
}

#Preview { ClassView() }
