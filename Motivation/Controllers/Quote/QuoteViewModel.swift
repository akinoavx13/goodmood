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
    
    private let databaseService: DatabaseServiceProtocol

    // MARK: - Lifecycle
    
    init(actions: QuoteViewModelActions,
         databaseService: DatabaseServiceProtocol) {
        self.actions = actions
        self.databaseService = databaseService
    }
}
