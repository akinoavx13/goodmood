//
//  CategoryDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class CategoryDIContainer {
    
    struct Dependencies {
        let trackingService: TrackingServiceProtocol
        let preferenceService: PreferenceServiceProtocol
        let quoteService: QuoteServiceProtocol
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    
    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeCategoryFlowCoordinator(navigationController: UINavigationController,
                                     delegate: CategoryViewControllerDelegate?) -> CategoryFlowCoordinator {
        CategoryFlowCoordinator(navigationController: navigationController,
                                delegate: delegate,
                                dependencies: self)
    }
    
    // MARK: - Private methods
    
    private func makeCategoryViewModel(actions: CategoryViewModelActions) -> CategoryViewModelProtocol {
        CategoryViewModel(actions: actions,
                          trackingService: dependencies.trackingService,
                          preferenceService: dependencies.preferenceService,
                          quoteService: dependencies.quoteService)
    }
}

// MARK: - CategoryFlowCoordinatorDependencies -

extension CategoryDIContainer: CategoryFlowCoordinatorDependencies {
    func makeCategoryViewController(actions: CategoryViewModelActions) -> CategoryViewController {
        CategoryViewController.create(with: makeCategoryViewModel(actions: actions))
    }
}
