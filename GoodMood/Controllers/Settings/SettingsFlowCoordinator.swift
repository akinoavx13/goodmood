//
//  SettingsFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 18/12/2021.
//

import UIKit
import StoreKit

protocol SettingsFlowCoordinatorDependencies: AnyObject {
    func makeSettingsViewController(actions: SettingsViewModelActions) -> SettingsViewController
}

final class SettingsFlowCoordinator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    
    private let dependencies: SettingsFlowCoordinatorDependencies
    private var viewController: UINavigationController!
    private let application: UIApplication
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         dependencies: SettingsFlowCoordinatorDependencies,
         application: UIApplication = UIApplication.shared) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.application = application
    }
    
    // MARK: - Methods
    
    func start() {
        let actions = SettingsViewModelActions(openUrl: openUrl(urlString:),
                                               presentActivityViewController: presentActivityViewController(text:sourceView:completion:),
                                               requestReview: requestReview)
        
        DispatchQueue.main.async {
            let settingsViewController = self.dependencies.makeSettingsViewController(actions: actions)
            self.viewController = UINavigationController(rootViewController: settingsViewController)
            self.viewController.navigationBar.prefersLargeTitles = true
            
            self.navigationController?.present(self.viewController, animated: true)
        }
    }
}

// MARK: - SettingsViewModelActions -

extension SettingsFlowCoordinator {
    private func openUrl(urlString: String) {
        guard let url = URL(string: urlString),
              application.canOpenURL(url)
        else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.application.open(url, options: [:])
        }
    }
    
    private func presentActivityViewController(text: String,
                                               sourceView: UIView?,
                                               completion: @escaping (String?, Bool) -> Void) {
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popoverPresentationController = activityViewController.popoverPresentationController,
           let sourceView = sourceView {
            popoverPresentationController.sourceRect = sourceView.bounds
            popoverPresentationController.sourceView = sourceView
        }
        activityViewController.completionWithItemsHandler = { activityType, success, _, _ in
            guard (activityType == nil && !success) || success else { return }
            
            completion(activityType?.rawValue, success)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.present(activityViewController, animated: true)
        }
    }
    
    private func requestReview() {
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
