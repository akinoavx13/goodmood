//
//  SettingsStepperCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit
import Reusable

protocol SettingsStepperCellDelegate: AnyObject {
    func settingsStepperCell(_ sender: SettingsStepperCell,
                             stepperValueDidChange value: Double,
                             id: String)
}

final class SettingsStepperCell: UITableViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var stepper: UIStepper!
    
    // MARK: - Properties
            
    weak var delegate: SettingsStepperCellDelegate?
    
    var viewModel: SettingsStepperCellViewModel? {
        didSet { configure() }
    }
    
    private let calendar = Calendar.current
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        delegate = nil
        
        titleLabel.text = nil
        titleLabel.alpha = 1
        
        subtitleLabel.text = nil
        
        stepper.isEnabled = true
        stepper.alpha = 1
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        titleLabel.alpha = viewModel.isDisabled ? 0.5 : 1
        
        subtitleLabel.text = viewModel.subtitle
        
        stepper.value = viewModel.value
        stepper.minimumValue = viewModel.min
        stepper.maximumValue = viewModel.max
        stepper.stepValue = viewModel.step
        
        stepper.isEnabled = !viewModel.isDisabled
        stepper.alpha = viewModel.isDisabled ? 0.5 : 1
    }
    
    // MARK: - Methods
    
    static func size(for viewModel: SettingsStepperCellViewModel) -> CGSize {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width - 16 * 3 - 100,
                                    height: CGFloat.greatestFiniteMagnitude)
        
        var height: CGFloat = 12 + 12
        
        let titleBoundingBox = NSString(string: viewModel.title)
            .boundingRect(with: constraintRect,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          attributes: [.font: UIFont.systemFont(ofSize: 17)],
                          context: nil)
        
        let subtitleBoundingBox = NSString(string: viewModel.subtitle)
            .boundingRect(with: constraintRect,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          attributes: [.font: UIFont.systemFont(ofSize: 15)],
                          context: nil)
        
        height += titleBoundingBox.height + subtitleBoundingBox.height + 4

        return CGSize(width: UIScreen.main.bounds.width,
                      height: max(height, 44))
    }
    
    // MARK: - Actions
    
    @IBAction private func stepperValueChanged(_ sender: UIStepper) {
        guard let viewModel = viewModel else { return }

        delegate?.settingsStepperCell(self,
                                      stepperValueDidChange: sender.value,
                                      id: viewModel.id)
    }
}
