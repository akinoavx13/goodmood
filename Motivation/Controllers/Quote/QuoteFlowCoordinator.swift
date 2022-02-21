//
//  QuoteFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

protocol QuoteFlowCoordinatorDependencies: AnyObject {
    
    // MARK: - Properties
    
    var settingsDIContainer: SettingsDIContainer { get }
    var cateogryDIContainer: CategoryDIContainer { get }
    
    // MARK: - Methods
    
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
        let actions = QuoteViewModelActions(presentSettings: presentSettings,
                                            presentCategory: presentCategory)
        
        DispatchQueue.main.async {
            self.navigationController?.setViewControllers([self.dependencies.makeQuoteViewController(actions: actions)],
                                                          animated: false)
        }
    }
}

// MARK: - QuoteViewModelActions -

extension QuoteFlowCoordinator {
    private func presentSettings() {
        guard let navigationController = navigationController else { return }
        
        dependencies
            .settingsDIContainer
            .makeSettingsFlowCoordinator(navigationController: navigationController)
            .start()
    }
    
    private func presentCategory() {
        guard let navigationController = navigationController else { return }
        
        dependencies
            .cateogryDIContainer
            .makeCategoryFlowCoordinator(navigationController: navigationController)
            .start()
    }
}
