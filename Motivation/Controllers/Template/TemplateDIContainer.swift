//
//  TemplateDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class TemplateDIContainer {
    
    struct Dependencies {
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    
    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeTemplateFlowCoordinator(navigationController: UINavigationController) -> TemplateFlowCoordinator {
        TemplateFlowCoordinator(navigationController: navigationController,
                                dependencies: self)
    }
    
    // MARK: - Private methods
    
    private func makeTemplateViewModel(actions: TemplateViewModelActions) -> TemplateViewModelProtocol {
        TemplateViewModel(actions: actions)
    }
}

// MARK: - TemplateFlowCoordinatorDependencies -

extension TemplateDIContainer: TemplateFlowCoordinatorDependencies {
    func makeTemplateViewController(actions: TemplateViewModelActions) -> TemplateViewController {
        TemplateViewController.create(with: makeTemplateViewModel(actions: actions))
    }
}
