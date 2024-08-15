//
//  ProjectNote.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI
import LoremSwiftum

struct ProjectNote: View {
    @Binding var text: String
    @FocusState private var fieldIsFocused: Bool
    private let focusedColor = Color.blue.opacity(0.6)
    var body: some View {
        TextFieldWithUnderline(hint: "Note", text: $text)
    }
}

struct TextFieldWithUnderline: View {
    var hint: String
    @Binding var text: String
    @FocusState private var fieldIsFocused: Bool
    private let focusedColor = Color.blue.opacity(0.6)
    var body: some View {
        TextField(hint, text: $text, prompt: Text(hint).foregroundStyle(fieldIsFocused ? focusedColor : .secondary))
            .labelsHidden()
            .focused($fieldIsFocused)
//            .animation(.easeIn(duration: 3), value: fieldIsFocused)
#if os(iOS)
            .textInputAutocapitalization(.never)
#endif
            .disableAutocorrection(true)
            .padding()
            .background {
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, topTrailing: 5))
                    .fill(.thickMaterial)
            }
            .overlay(
                VStack {
                    Spacer()
                    (fieldIsFocused ? focusedColor : .secondary)
                        .frame(height: 1)
                        .offset(x: 0, y: 0)
                }
                    .frame(maxHeight: .infinity)
            )
            .textFieldStyle(.plain)
    }
}

#Preview {
    ProjectNote(text: .constant(Lorem.sentences(0)))
        .padding()
}
