//
//  QuoteViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class QuoteViewController: UIViewController {
    
    // MARK: - Outlets
    
    // MARK: - Properties
    
    var viewModel: QuoteViewModelProtocol!
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: QuoteViewModelProtocol) -> QuoteViewController {
        guard let viewController = R.storyboard.quoteViewController().instantiateInitialViewController()
                as? QuoteViewController
        else { fatalError("Could not instantiate QuoteViewController.") }

        viewController.viewModel = viewModel

        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(to: viewModel)
        
        view.backgroundColor = .red
    }

    // MARK: - Private methods
    
    private func bind(to viewModel: QuoteViewModelProtocol) {
        
    }
}
