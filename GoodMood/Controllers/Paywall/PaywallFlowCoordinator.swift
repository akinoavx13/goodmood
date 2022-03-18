//
//  PaywallFlowCoordinator.swift
//  GoodMood
//
//  Created by Maxime Maheo on 20/12/2021.
//

import UIKit
import SafariServices

protocol PaywallFlowCoordinatorDependencies: AnyObject {
    func makeStartPaywallViewController(actions: PaywallStartViewModelActions,
                                        origin: TrackingService.PaywallOrigin,
                                        type: PaywallFlowCoordinator.PaywallType) -> PaywallStartViewController
}

protocol PaywallFlowCoordinatorDelegate: AnyObject {
    func paywallFlowCoordinatorWillDismiss(_ sender: PaywallFlowCoordinator)
}

final class PaywallFlowCoordinator {
    
    enum PaywallType: String {
        case
             start
    }
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    private weak var paywallDelegate: PaywallViewControllerDelegate?
    
    weak var delegate: PaywallFlowCoordinatorDelegate?
    
    private let dependencies: PaywallFlowCoordinatorDependencies
    private var viewController: UIViewController!
    private var origin: TrackingService.PaywallOrigin!

    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController?,
         dependencies: PaywallFlowCoordinatorDependencies,
         paywallDelegate: PaywallViewControllerDelegate?) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.paywallDelegate = paywallDelegate
    }
    
    // MARK: - Methods
    
    func start(type: PaywallType,
               origin: TrackingService.PaywallOrigin) {
        switch type {
        case .start:
            startStartPaywall(origin: origin,
                              type: type)
        }
    }
    
    // MARK: - Private methods
    
    private func startStartPaywall(origin: TrackingService.PaywallOrigin,
                                   type: PaywallType) {
        self.origin = origin
        
        let actions = PaywallStartViewModelActions(dismiss: dismiss,
                                                   presentSafariViewController: presentSafariViewController(urlString:))
        
        DispatchQueue.main.async {
            self.viewController = self.dependencies.makeStartPaywallViewController(actions: actions,
                                                                                   origin: origin,
                                                                                   type: type)
            if let viewController = self.viewController as? PaywallStartViewController {
                viewController.delegate = self.paywallDelegate
            }
            self.viewController.modalPresentationStyle = .fullScreen
            
            self.navigationController?.present(self.viewController, animated: origin != .onboarding)
        }
    }
}

// MARK: - PaywallViewModelActions -

extension PaywallFlowCoordinator {
    private func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.paywallFlowCoordinatorWillDismiss(self)
            self.viewController.dismiss(animated: self.origin != .onboarding)
        }
    }
    
    private func presentSafariViewController(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController.present(SFSafariViewController(url: url), animated: true)
        }
    }
}
