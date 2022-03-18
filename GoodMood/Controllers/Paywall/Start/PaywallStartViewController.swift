//
//  PaywallStartViewController.swift
//  GoodMood
//
//  Created by Maxime Maheo on 20/12/2021.
//

import UIKit
import RxSwift
import PKHUD
import SwiftRichString

protocol PaywallViewControllerDelegate: AnyObject {
    func paywallViewController(_ sender: UIViewController, hasPurchaseSucceed: Bool)
    func paywallViewController(_ sender: UIViewController, closeButtonDidTap button: UIButton)
}

final class PaywallStartViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private weak var gradientView: GradientView! {
        didSet {
            gradientView.type = .custom(colors: [Colors.dark.withAlphaComponent(0),
                                                 Colors.dark],
                                        startPoint: CGPoint(x: 0.5, y: 0),
                                        endPoint: CGPoint(x: 0.5, y: 1))
        }
    }
    @IBOutlet private weak var restoreButton: UIButton! {
        didSet { restoreButton.setTitle(R.string.localizable.restore(), for: .normal) }
    }
    @IBOutlet private weak var closeButtonContainerView: UIView! {
        didSet {
            closeButtonContainerView.layer.cornerRadius = 15
            closeButtonContainerView.alpha = 0
            closeButtonContainerView.isUserInteractionEnabled = false
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = R.string.localizable.all_pro_features()
            titleLabel.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 24, weight: .semibold)
        }
    }
    @IBOutlet private weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = R.string.localizable.start_paywall_description()
            subtitleLabel.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 17, weight: .regular)
        }
    }
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var ctaButton: UIButton! {
        didSet {
            ctaButton.setTitle(R.string.localizable.continue().uppercased(), for: .normal)
            ctaButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
            ctaButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
            ctaButton.layer.smoothCorner(8)
            ctaButton.isEnabled = false
        }
    }
    @IBOutlet private weak var footerLabel: UILabel! {
        didSet { footerLabel.text = R.string.localizable.auto_renewed_subscription() }
    }
    @IBOutlet private weak var privacyPolicyButton: UIButton! {
        didSet { privacyPolicyButton.setTitle(R.string.localizable.privacy_policy(), for: .normal) }
    }
    @IBOutlet private weak var termsOfUseButton: UIButton! {
        didSet { termsOfUseButton.setTitle(R.string.localizable.terms_of_use(), for: .normal) }
    }
    @IBOutlet private weak var spacerHeightConstraint: NSLayoutConstraint! {
        didSet { spacerHeightConstraint.constant = UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.58 : 0.44) }
    }
    
    // MARK: - Properties
        
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var shouldAutorotate: Bool { false }
    
    weak var delegate: PaywallViewControllerDelegate?

    var viewModel: PaywallStartViewModelProtocol!
    
    private let disposeBag = DisposeBag()

    private lazy var titleStyleNormal = Style {
        $0.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 15, weight: .regular)
    }
    private lazy var titleStyleHighlighted = Style {
        $0.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 15, weight: .bold)
    }
    private lazy var priceStyle = StyleXML(base: titleStyleNormal, ["b": titleStyleHighlighted])
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: PaywallStartViewModelProtocol) -> PaywallStartViewController {
        guard let viewController = R.storyboard.paywallStartViewController().instantiateInitialViewController()
                as? PaywallStartViewController
        else { fatalError("Could not instantiate PaywallStartViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        presentationController?.delegate = self
        
        if viewModel.origin != .onboarding {
            showCloseButtonContainerView()
        }
        bind(to: viewModel)
        
        Task { await viewModel.viewDidLoad() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showCloseButtonContainerView()
        }
    }

    // MARK: - Private methods
    
    private func bind(to viewModel: PaywallStartViewModelProtocol) {
        viewModel.price
            .asDriver()
            .drive(onNext: { [weak self] price in
                guard let self = self else { return }
                
                self.priceLabel.attributedText = price.set(style: self.priceStyle)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .asDriver()
            .filter { $0 }
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.ctaButton.isEnabled = true
                
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateHUD(isSuccess: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.paywallViewController(self, hasPurchaseSucceed: isSuccess)

            if isSuccess {
                HUD.flash(.success, delay: Constants.animationDuration)
                                
                self.viewModel.dismiss()
            } else {
                HUD.flash(.error, delay: Constants.animationDuration)
            }
        }
    }
    
    private func showCloseButtonContainerView() {
        UIView.animate(withDuration: 1) {
            self.closeButtonContainerView.alpha = 0.3
            self.closeButtonContainerView.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func closeButtonDidTap(_ sender: UIButton) {
        viewModel.dismiss()
        
        delegate?.paywallViewController(self, closeButtonDidTap: sender)
    }
    @IBAction private func restoreButtonDidTap(_ sender: UIButton) {
        HUD.show(.progress)
        
        Task { updateHUD(isSuccess: await viewModel.restore()) }
    }
    @IBAction private func ctaButtonDidTap(_ sender: UIButton) {
        HUD.show(.progress)
        
        Task { updateHUD(isSuccess: await viewModel.purchase()) }
    }
    @IBAction private func termsOfUseButtonDidTap(_ sender: UIButton) { viewModel.termsOfUse() }
    @IBAction private func privacyPolicyButtonDidTap(_ sender: UIButton) { viewModel.privacyPolicy() }
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension PaywallStartViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        // Prevent user from dismiss with swipe-down gesture
        return false
    }
}

// MARK: - UIScrollViewDelegate -

extension PaywallStartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > 50 else { return }
        
        showCloseButtonContainerView()
    }
}
