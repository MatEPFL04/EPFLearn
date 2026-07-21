//
//  TutorView.swift
//  EPFLearn
//
//  Created by Mat on 19.07.2026.
//

import SwiftUI


struct TutorView: View {
    @State private var vm: TutorViewModel

    init(question: Question, studentChoice: Int) {
        _vm = State(initialValue: TutorViewModel(question: question, studentChoice: studentChoice))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(vm.messages) { msg in
                            bubble(for: msg).id(msg.id)
                        }
                    }
                    .padding()
                }
                // Suit le texte qui grandit à chaque morceau
                .onChange(of: vm.messages.last?.text) {
                    if let last = vm.messages.last {
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if let err = vm.errorText {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }

            HStack(spacing: 8) {
                TextField("Enter your response…", text: $vm.input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(vm.isStreaming)
                    .onSubmit { Task { await vm.send() } }

                Button {
                    Task { await vm.send() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.title2)
                }
                .disabled(vm.input.trimmingCharacters(in: .whitespaces).isEmpty || vm.isStreaming)
            }
            .padding()
        }
        .navigationTitle("Tutor")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func bubble(for msg: TutorViewModel.Msg) -> some View {
        let isUser = msg.role == "user"
        HStack {
            if isUser { Spacer(minLength: 40) }
            Text(msg.text.isEmpty && vm.isStreaming ? "…" : msg.text)
                .padding(10)
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if !isUser { Spacer(minLength: 40) }
        }
    }
}
