//
//  QuoteViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

struct QuoteViewModelActions { }

protocol QuoteViewModelProtocol: AnyObject { }

final class QuoteViewModel: QuoteViewModelProtocol {
    
    // MARK: - Properties
    
    private let actions: QuoteViewModelActions
    
    // MARK: - Lifecycle
    
    init(actions: QuoteViewModelActions) {
        self.actions = actions
    }
    
}
