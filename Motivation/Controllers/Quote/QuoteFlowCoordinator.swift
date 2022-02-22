//
//  QuoteFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit
import StoreKit

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
    private weak var delegate: CategoryViewControllerDelegate?

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
                                            presentCategory: presentCategory,
                                            presentPreReviewPopup: presentPreReviewPopup(destructiveCompletion:defaultCompletion:))
        
        DispatchQueue.main.async {
            let viewController = self.dependencies.makeQuoteViewController(actions: actions)
            
            self.delegate = viewController
            
            self.navigationController?.setViewControllers([viewController],
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
            .makeCategoryFlowCoordinator(navigationController: navigationController,
                                         delegate: delegate)
            .start()
    }
    
    private func presentPreReviewPopup(destructiveCompletion: @escaping () -> Void,
                                       defaultCompletion: @escaping () -> Void) {
        let alertViewcontroller = UIAlertController(title: R.string.localizable.enjoying_the_app(),
                                                    message: nil,
                                                    preferredStyle: .alert)
        alertViewcontroller.addAction(UIAlertAction(title: R.string.localizable.no(),
                                                    style: .destructive,
                                                    handler: { _ in destructiveCompletion() }))
        alertViewcontroller.addAction(UIAlertAction(title: R.string.localizable.yes(),
                                                    style: .default,
                                                    handler: { [weak self] _ in self?.requestReview(completion: defaultCompletion) }))
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.present(alertViewcontroller, animated: true)
        }
    }
    
    private func requestReview(completion: @escaping () -> Void) {
        completion()
        
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }
}
