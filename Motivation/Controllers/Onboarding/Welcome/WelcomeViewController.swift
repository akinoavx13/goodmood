//
//  WelcomeViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

import UIKit
import SwiftRichString

final class WelcomeViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet { titleLabel.text = R.string.localizable.welcome() }
    }
    @IBOutlet private weak var subtitleLabel: UILabel! {
        didSet { subtitleLabel.attributedText = R.string.localizable.welcome_description().set(style: subtitleStyles) }
    }
    @IBOutlet private weak var continueButton: AnimateButton! {
        didSet {
            continueButton.setTitle(R.string.localizable.continue(), for: .normal)
            continueButton.layer.smoothCorner(8)
        }
    }
    
    // MARK: - Properties
    
    var viewModel: WelcomeViewModelProtocol!
    
    private lazy var subtitleStyleNormal = Style { $0.font = UIFont.systemFont(ofSize: 17, weight: .regular) }
    private lazy var subtitleStyleHighlighted = Style { $0.font = UIFont.systemFont(ofSize: 17, weight: .bold) }
    private lazy var subtitleStyles = StyleXML(base: subtitleStyleNormal, ["b": subtitleStyleHighlighted])
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: WelcomeViewModelProtocol) -> WelcomeViewController {
        guard let viewController = R.storyboard.welcomeViewController().instantiateInitialViewController()
                as? WelcomeViewController
        else { fatalError("Could not instantiate WelcomeViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    // MARK: - Actions
    
    @IBAction private func continueButtonDidTap(_ sender: AnimateButton) {
        viewModel.nextButtonDidTap()
    }
}
