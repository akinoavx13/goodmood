//
//  CompositionSection.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import Foundation

public struct CompositionSection<T, V> {
    
    // MARK: - Properties
    
    var count: Int { cells.count }
    
    let type: T
    let title: String?
    
    private let cells: [V]

    // MARK: - Methods
    
    static func section(_ type: T,
                        title: String? = nil,
                        cells: [V] = []) -> CompositionSection<T, V> {
        CompositionSection(type: type,
                           title: title,
                           cells: cells)
    }

    func cellForIndex(_ index: Int) -> V? {
        guard index < cells.count else { return nil }
        
        return cells[index]
    }
}
