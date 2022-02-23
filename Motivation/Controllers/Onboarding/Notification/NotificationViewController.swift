//
//  NotificationViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationViewController: UIViewController {
    
    // MARK: - Outlets
        
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet { titleLabel.text = R.string.localizable.notification_title() }
    }
    @IBOutlet private weak var continueButton: AnimateButton! {
        didSet {
            continueButton.setTitle(R.string.localizable.continue(), for: .normal)
            continueButton.layer.smoothCorner(8)
        }
    }
    @IBOutlet private weak var nbTimesContainer: UIView! {
        didSet { nbTimesContainer.layer.smoothCorner(8) }
    }
    @IBOutlet private weak var nbTimesTitleLabel: UILabel! {
        didSet { nbTimesTitleLabel.text = R.string.localizable.number_of_reminders() }
    }
    @IBOutlet private weak var nbTimesValueLabel: UILabel!
    @IBOutlet private weak var nbTimesStepper: UIStepper!
    @IBOutlet private weak var startAtContainer: UIView! {
        didSet { startAtContainer.layer.smoothCorner(8) }
    }
    @IBOutlet private weak var startAtTitleLabel: UILabel! {
        didSet { startAtTitleLabel.text = R.string.localizable.start_at() }
    }
    @IBOutlet private weak var startAtDatePicker: UIDatePicker!
    @IBOutlet private weak var endAtContainer: UIView! {
        didSet { endAtContainer.layer.smoothCorner(8) }
    }
    @IBOutlet private weak var endAtTitleLabel: UILabel! {
        didSet { endAtTitleLabel.text = R.string.localizable.end_at() }
    }
    @IBOutlet private weak var endAtDatePicker: UIDatePicker!
    
    // MARK: - Properties
    
    var viewModel: NotificationViewModelProtocol!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: NotificationViewModelProtocol) -> NotificationViewController {
        guard let viewController = R.storyboard.notificationViewController().instantiateInitialViewController()
                as? NotificationViewController
        else { fatalError("Could not instantiate NotificationViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(to: viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    // MARK: - Private methods
    
    private func bind(to viewModel: NotificationViewModelProtocol) {
        viewModel
            .nbTimes
            .map { R.string.localizable.x_times($0) }
            .bind(to: nbTimesValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .nbTimes
            .map { Double($0) }
            .bind(to: nbTimesStepper.rx.value)
            .disposed(by: disposeBag)
        
        viewModel
            .startAt
            .bind(to: startAtDatePicker.rx.date)
            .disposed(by: disposeBag)
        
        viewModel
            .endAt
            .bind(to: endAtDatePicker.rx.date)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction private func nextButtonDidTap(_ sender: AnimateButton) {
        Task {
            await viewModel.nextButtonDidTap()
        }
    }
    
    @IBAction private func nbTimesStepperValueChanged(_ sender: UIStepper) {
        viewModel.update(nbTimes: sender.value)
    }
    
    @IBAction private func startAtValueChanged(_ sender: UIDatePicker) {
        viewModel.update(startAt: sender.date)
    }
    
    @IBAction private func endAtValueChanged(_ sender: UIDatePicker) {
        viewModel.update(endAt: sender.date)
    }
}
