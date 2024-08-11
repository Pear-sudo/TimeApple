//
//  ProjectDatePicker.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI

struct ProjectDatePicker: View {
    @Binding var date: Date
    @State private var cachedDate: Date = .now
    @State private var showDatePicker = false
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date")
                .foregroundStyle(.secondary)
            Text(date.formatted(Date.FormatStyle()
                .year(.defaultDigits)
                .day(.twoDigits)
                .month(.abbreviated)
                .weekday(.abbreviated)
            ))
            .font(.title2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        #if os(macOS)
        .popover(isPresented: $showDatePicker) {
            picker
        }
        #else
        .sheet(isPresented: $showDatePicker) {
            picker
        }
        #endif
        .onTapGesture {
            showDatePicker = true
            cachedDate = date
        }
    }
    
    var picker: some View {
        VStack {
            DatePicker("Date", selection: $cachedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
            HStack {
                Button("Cancel", role: .cancel) {
                    showDatePicker = false
                }
                Spacer()
                Button("Confirm", role: .destructive) {
                    date = cachedDate
                    showDatePicker = false
                }
            }
        }
        .padding()
        .presentationBackground(.thickMaterial)
        .labelsHidden()
    }
}

#Preview {
    ProjectDatePicker(date: .constant(.now))
        .padding()
}
