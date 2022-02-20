//
//  QuoteFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

protocol QuoteFlowCoordinatorDependencies: AnyObject {
    func makeQuoteViewController(actions: QuoteViewModelActions) -> QuoteViewController
}

final class QuoteFlowCoordinator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?

    private let dependencies: QuoteFlowCoordinatorDependencies
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         dependencies: QuoteFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func start() {
        let actions = QuoteViewModelActions()
        
        DispatchQueue.main.async {
            self.navigationController?.setViewControllers([self.dependencies.makeQuoteViewController(actions: actions)],
                                                          animated: false)
        }
    }
}
