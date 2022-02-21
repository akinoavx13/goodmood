//
//  QuoteDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class QuoteDIContainer {
    
    struct Dependencies {
        let databaseService: DatabaseServiceProtocol
        let trackingService: TrackingServiceProtocol
        let settingsDIContainer: SettingsDIContainer
        let categoryDIContainer: CategoryDIContainer
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies

    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeQuoteFlowCoordinator(navigationController: UINavigationController) -> QuoteFlowCoordinator {
        QuoteFlowCoordinator(navigationController: navigationController,
                             dependencies: self)
    }
    
    // MARK: - Private methods
    
    private func makeQuoteViewModel(actions: QuoteViewModelActions) -> QuoteViewModelProtocol {
        QuoteViewModel(actions: actions,
                       databaseService: dependencies.databaseService,
                       trackingService: dependencies.trackingService)
    }
}

// MARK: - QuoteFlowCoordinatorDependencies -

extension QuoteDIContainer: QuoteFlowCoordinatorDependencies {
    
    // MARK: - Properties
    
    var settingsDIContainer: SettingsDIContainer {
        dependencies.settingsDIContainer
    }
    
    var cateogryDIContainer: CategoryDIContainer {
        dependencies.categoryDIContainer
    }
    
    // MARK: - Methods
    
    func makeQuoteViewController(actions: QuoteViewModelActions) -> QuoteViewController {
        QuoteViewController.create(with: makeQuoteViewModel(actions: actions))
    }
}
