//
//  SettingsToggleCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit
import Reusable

protocol SettingsToggleCellDelegate: AnyObject {
    func settingsToggleCell(_ sender: SettingsToggleCell,
                            switchValueDidChange isOn: Bool,
                            id: String)
}

final class SettingsToggleCell: UITableViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchView: UISwitch!
    
    // MARK: - Properties
        
    weak var delegate: SettingsToggleCellDelegate?
    
    var viewModel: SettingsToggleCellViewModel? {
        didSet { configure() }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        delegate = nil
        
        titleLabel.text = nil
        titleLabel.alpha = 1
        switchView.isOn = false
        switchView.isEnabled = true
        subtitleLabel.text = nil
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        switchView.isOn = viewModel.isOn
        
        titleLabel.alpha = viewModel.isDisabled ? 0.5 : 1
        switchView.isEnabled = !viewModel.isDisabled
    }
    
    // MARK: - Methods
    
    static func size(for viewModel: SettingsToggleCellViewModel) -> CGSize {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width - 16 * 6 - 51,
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
    
    @IBAction private func switchValueDidChange(_ sender: UISwitch) {
        guard let viewModel = viewModel else { return }

        delegate?.settingsToggleCell(self,
                                     switchValueDidChange: sender.isOn,
                                     id: viewModel.id)
    }
    
}
