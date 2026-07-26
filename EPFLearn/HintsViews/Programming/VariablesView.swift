//
//  VariablesView.swift
//  EPFLearn
//
//  What this view actually teaches (instead of "a number appears in a box"):
//
//    1. A variable is a *slot* with a type, a name and a lifetime.
//    2. Primitives store the value itself; object types store a REFERENCE.
//    3. Assignment always copies the content of the slot — which means it
//       copies the value for an int, and the address for an array.
//    4. Consequence: aliasing. Two names, one object, one mutation visible
//       from both. This is the #1 exam trap of every intro CS course.
//    5. Immutability: String looks like it mutates, but `s + "!"` allocates a
//       NEW object and re-points the slot; the old one becomes garbage.
//
//  The stack/heap split is drawn explicitly, and references are shown as
//  colored `→ #n` tags matching the heap object badge.
//

import SwiftUI

// MARK: - Model

private struct MemSlot: Identifiable {
    let id: String            // variable name
    let type: String
    let value: String         // literal value, or "" when it is a reference
    let ref: Int?             // heap object id when the slot holds a reference
    var changed: Bool = false
}

private struct HeapObject: Identifiable {
    let id: Int
    let type: String
    let cells: [String]
    var changed: Bool = false
    var garbage: Bool = false
}

private struct VarStep {
    let line: Int             // -1 = nothing executed yet
    let slots: [MemSlot]
    let heap: [HeapObject]
    let note: String
    var alarm: Bool = false   // step where the classic mistake bites
}

// MARK: - View

struct VariablesView: View {

    @State private var index = 0
    private let accent = Color.blue

    private let code = [
        "int a = 3;",
        "int b = a;",
        "b = 7;",
        "",
        "int[] xs = {1, 2, 3};",
        "int[] ys = xs;",
        "ys[0] = 99;",
        "",
        "String s = \"hi\";",
        "s = s + \"!\";",
    ]

    private var steps: [VarStep] { Self.trace }

    private var step: VarStep { steps[min(index, steps.count - 1)] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VizTitle(title: "Variables & memory",
                         subtitle: "A slot, a value, and — for objects — an address.",
                         accent: accent)

                VizPanel { CodePane(lines: code, activeLine: step.line, accent: accent) }

                VizPanel { StepPlayer(index: $index, count: steps.count, accent: accent) }

                StepNote(text: step.note,
                         accent: step.alarm ? .orange : accent,
                         icon: step.alarm ? "exclamationmark.triangle.fill" : "arrow.turn.down.right")

                HStack(alignment: .top, spacing: 12) {
                    stackPanel
                    heapPanel
                }

                watchPanel
                summaryPanel
            }
            .padding(18)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(duration: 0.3), value: index)
    }

    // MARK: Stack

    private var stackPanel: some View {
        VizPanel(title: "Stack", accent: accent) {
            VStack(spacing: 6) {
                if step.slots.isEmpty {
                    Text("empty")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ForEach(step.slots) { slot in
                    slotRow(slot)
                }
            }
        }
    }

    private func slotRow(_ slot: MemSlot) -> some View {
        let color = slot.ref == nil ? accent : Self.heapColor(slot.ref!)
        return HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text(slot.id)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                Text(slot.type)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            if let ref = slot.ref {
                Text("→ #\(ref)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .background(Capsule().fill(color.opacity(0.18)))
            } else {
                Text(slot.value)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(slot.changed ? 0.26 : 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(slot.changed ? 0.9 : 0), lineWidth: 1.5)
        )
    }

    // MARK: Heap

    private var heapPanel: some View {
        VizPanel(title: "Heap", accent: .teal) {
            VStack(spacing: 8) {
                if step.heap.isEmpty {
                    Text("empty")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ForEach(step.heap) { obj in
                    heapRow(obj)
                }
            }
        }
    }

    private func heapRow(_ obj: HeapObject) -> some View {
        let color = Self.heapColor(obj.id)
        return VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Text("#\(obj.id)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(Capsule().fill(color))
                Text(obj.type)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                if obj.garbage {
                    Text("garbage")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Capsule().fill(Color.secondary.opacity(0.18)))
                }
            }
            HStack(spacing: 4) {
                ForEach(Array(obj.cells.enumerated()), id: \.offset) { _, cell in
                    Text(cell)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .frame(minWidth: 24)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(color.opacity(0.18)))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .opacity(obj.garbage ? 0.45 : 1)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(color.opacity(obj.changed ? 0.20 : 0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(color.opacity(obj.changed ? 0.9 : 0), lineWidth: 1.5)
        )
    }

    // MARK: Watch

    /// The two values a student is asked about in the exam.
    private var watchPanel: some View {
        let a = step.slots.first { $0.id == "a" }?.value ?? "—"
        let xs0 = step.heap.first { $0.id == 1 }?.cells.first ?? "—"
        return HStack(spacing: 12) {
            VarChip(name: "a", value: a, type: "int", color: accent)
            VarChip(name: "xs[0]", value: xs0, type: "int", color: .teal,
                    highlighted: step.alarm)
        }
    }

    // MARK: Summary

    private var summaryPanel: some View {
        VizPanel(title: "Rule of thumb", accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                ruleRow(icon: "square.fill", color: accent,
                        head: "Primitives (int, double, char, boolean)",
                        body: "the slot holds the value → `=` copies the value → the two variables are independent forever.")
                ruleRow(icon: "arrow.right.circle.fill", color: .teal,
                        head: "Objects (arrays, String, your classes)",
                        body: "the slot holds an address → `=` copies the address → both names reach the same object. Copy explicitly (`xs.clone()`, `Arrays.copyOf`) if you want independence.")
                ruleRow(icon: "lock.fill", color: .purple,
                        head: "Immutable objects (String, Integer…)",
                        body: "aliasing is harmless: nobody can mutate them, every \"modification\" allocates a new object.")
            }
        }
    }

    private func ruleRow(icon: String, color: Color, head: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
                .padding(.top, 3)
            VStack(alignment: .leading, spacing: 2) {
                Text(head).font(.system(size: 12, weight: .semibold))
                Text(body)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private static func heapColor(_ id: Int) -> Color {
        [Color.teal, .indigo, .pink, .orange][id % 4]
    }

    // MARK: - The trace

    private static let trace: [VarStep] = {
        let arr1 = HeapObject(id: 1, type: "int[3]", cells: ["1", "2", "3"])
        let arr1mut = HeapObject(id: 1, type: "int[3]", cells: ["99", "2", "3"], changed: true)
        let str2 = HeapObject(id: 2, type: "String", cells: ["\"hi\""])
        let str2dead = HeapObject(id: 2, type: "String", cells: ["\"hi\""], garbage: true)
        let str3 = HeapObject(id: 3, type: "String", cells: ["\"hi!\""], changed: true)

        func a(_ v: String, _ ch: Bool = false) -> MemSlot {
            MemSlot(id: "a", type: "int", value: v, ref: nil, changed: ch)
        }
        func b(_ v: String, _ ch: Bool = false) -> MemSlot {
            MemSlot(id: "b", type: "int", value: v, ref: nil, changed: ch)
        }
        let xs = MemSlot(id: "xs", type: "int[]", value: "", ref: 1)
        let xsHot = MemSlot(id: "xs", type: "int[]", value: "", ref: 1, changed: true)
        let ys = MemSlot(id: "ys", type: "int[]", value: "", ref: 1, changed: true)
        let ysCold = MemSlot(id: "ys", type: "int[]", value: "", ref: 1)
        func s(_ ref: Int, _ ch: Bool = false) -> MemSlot {
            MemSlot(id: "s", type: "String", value: "", ref: ref, changed: ch)
        }

        return [
            VarStep(line: -1, slots: [], heap: [],
                    note: "Nothing exists yet. A variable only starts to exist when its declaration is executed — not when it is written in the file."),

            VarStep(line: 0, slots: [a("3", true)], heap: [],
                    note: "Declaration + initialisation. `int` is a primitive: the slot `a` physically contains the 3. No heap involved."),

            VarStep(line: 1, slots: [a("3"), b("3", true)], heap: [],
                    note: "`b = a` copies the CONTENT of the slot a, i.e. the number 3. Two separate slots now hold their own 3."),

            VarStep(line: 2, slots: [a("3"), b("7", true)], heap: [],
                    note: "b becomes 7 and a is still 3. With primitives, the two variables were never linked — only the value travelled."),

            VarStep(line: 4, slots: [a("3"), b("7"), xs], heap: [arr1],
                    note: "`{1, 2, 3}` allocates an array object on the heap (#1). The slot `xs` does NOT contain the array — it contains its address."),

            VarStep(line: 5, slots: [a("3"), b("7"), xs, ys], heap: [arr1],
                    note: "`ys = xs` copies the slot content again — but this time the content is an address. Both names now designate the SAME object #1. No copy of the array happened."),

            VarStep(line: 6, slots: [a("3"), b("7"), xsHot, ysCold], heap: [arr1mut],
                    note: "Aliasing. Writing through ys mutates object #1, so xs[0] reads 99 too, even though the line never mentions xs. Nothing was assigned to xs — the object it points to changed.", alarm: true),

            VarStep(line: 8, slots: [a("3"), b("7"), xs, ysCold, s(2, true)], heap: [arr1mut, str2],
                    note: "A String is an object too: slot `s` holds an address towards #2."),

            VarStep(line: 9, slots: [a("3"), b("7"), xs, ysCold, s(3, true)], heap: [arr1mut, str2dead, str3],
                    note: "String is immutable: `s + \"!\"` cannot touch #2. It builds a NEW object #3 and re-points the slot. #2 is now unreachable and the garbage collector will reclaim it — this is why concatenating in a loop is O(n²)."),
        ]
    }()
}

#Preview {
    VariablesView()
}
