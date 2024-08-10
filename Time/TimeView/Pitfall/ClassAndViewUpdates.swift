//
//  ClassAndViewUpdates.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI

///  the view won't be updated if class member changes
///  that's why swift ui requires view to be struct and modify it through states
///  states somehow could sense the change and force the UI update in some way
struct ClassAndViewUpdates: View {
    var number = ANumber()
    var body: some View {
        Text(number.n.formatted())
        Button("+1") {
            number.n += 1
            print(number.n)
        }
    }
}

class ANumber {
    var n = 0
}

#Preview {
    ClassAndViewUpdates()
        .padding()
}
