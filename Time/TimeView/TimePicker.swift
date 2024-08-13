//
//  TimePicker.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI

struct TimePicker<Label>: View where Label: View {
    @Binding var date: Date?
    @ViewBuilder var label: () ->  Label
    
    @State private var pickerIsShown: Bool = false
    @State private var dateCache: Date = .now
    
    init(date: Binding<Date?>, label: @escaping () -> Label = {EmptyView()}) {
        self._date = date
        self.label = label
        self.dateCache = date.wrappedValue ?? .now
    }
    init(_ title: String, date: Binding<Date?>) where Label == Text {
        self.init(date: date) {
            Text(title)
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            label()
                .foregroundStyle(.secondary)
            if let date = date {
                Text(date, style: .time)
                    .font(.title2)
            } else {
                Text("No time")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        #if os(iOS)
        .sheet(isPresented: $pickerIsShown, content: {
            picker
        })
        #else
        .popover(isPresented: $pickerIsShown) {
            picker
        }
        #endif
        .onTapGesture {
            dateCache = date ?? .now
            pickerIsShown = true
        }
    }
    
    private var picker: some View {
        VStack {
            DatePicker("", selection: $dateCache, displayedComponents: [.hourAndMinute])
            #if os(iOS)
                .datePickerStyle(.wheel)
            #else
                .offset(y: 14)
                .datePickerStyle(.automatic)
            #endif
                .fixedSize()
            HStack {
                Button("Cancel", role: .cancel) {
                    pickerIsShown = false
                }
                Spacer()
                Button("Confirm", role: .destructive) {
                    date = dateCache
                    pickerIsShown = false
                }
            }
            .padding()
        }
    }
}

struct DebugViewModifier<S: ShapeStyle>: ViewModifier {
    private var shapeStyle: S
    init(_ shapeStyle: S) {
        self.shapeStyle = shapeStyle
    }
    init() where S == Color {
        self.shapeStyle = .red
    }
    func body(content: Content) -> some View {
        content.border(shapeStyle)
    }
}

extension View {
    func debug<S: ShapeStyle>(_ shapeStyle: S) -> some View {
        modifier(DebugViewModifier(shapeStyle))
    }
    func debug() -> some View {
        modifier(DebugViewModifier())
    }
}

#Preview {
    TimePicker("From", date: .constant(.now))
        .frame(width: 300, height: 300)
}
