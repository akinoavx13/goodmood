//
//  TemplateViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class TemplateViewController: UIViewController {
    
    // MARK: - Outlets
    
    // MARK: - Properties
        
    var viewModel: TemplateViewModelProtocol!
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .rigid)

    // MARK: - Lifecycle
    
    static func create(with viewModel: TemplateViewModelProtocol) -> TemplateViewController {
        guard let viewController = R.storyboard.templateViewController().instantiateInitialViewController()
                as? TemplateViewController
        else { fatalError("Could not instantiate TemplateViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        impactGenerator.impactOccurred()
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        title = R.string.localizable.templates()
    }
    
    // MARK: - Private methods
    
    private func bind(to viewModel: TemplateViewModelProtocol) {

    }
}
