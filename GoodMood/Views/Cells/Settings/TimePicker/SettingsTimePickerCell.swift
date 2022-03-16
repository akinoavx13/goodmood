//
//  SettingsTimePickerCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit
import Reusable

protocol SettingsTimePickerCellDelegate: AnyObject {
    func settingsTimePickerCell(_ sender: SettingsTimePickerCell,
                                timePickerValueDidChange date: Date,
                                id: String)
}

final class SettingsTimePickerCell: UITableViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timePicker: UIDatePicker! {
        didSet {
            if #available(iOS 13.4, *) {
                timePicker.preferredDatePickerStyle = .compact
            }
        }
    }
    
    // MARK: - Properties
            
    weak var delegate: SettingsTimePickerCellDelegate?
    
    static var size: CGSize {
        let width = UIScreen.main.bounds.width
                
        if #available(iOS 13.4, *) {
            return CGSize(width: width, height: 60)
        }
        
        return CGSize(width: width, height: 150)
    }
    
    var viewModel: SettingsTimePickerCellViewModel? {
        didSet { configure() }
    }
    
    private let calendar = Calendar.current
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        delegate = nil
        
        titleLabel.text = nil
        titleLabel.alpha = 1
        timePicker.date = Date()
        timePicker.isEnabled = true
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        timePicker.date = viewModel.date
        
        titleLabel.alpha = viewModel.isDisabled ? 0.5 : 1
        timePicker.isEnabled = !viewModel.isDisabled
    }
    
    // MARK: - Actions
    
    @IBAction private func timePickerValueDidChange(_ sender: UIDatePicker) {
        guard let viewModel = viewModel else { return }

        delegate?.settingsTimePickerCell(self,
                                         timePickerValueDidChange: sender.date,
                                         id: viewModel.id)
    }
}
