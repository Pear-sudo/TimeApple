//
//  ViewModel.swift
//  Time
//
//  Created by A on 01/08/2024.
//

import Foundation

@Observable
class ViewModel {
    var sortParameter: SortParameter = .recentness
    var sortOrder: SortOrder = .reverse
}
