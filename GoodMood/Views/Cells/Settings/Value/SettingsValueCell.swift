//
//  SettingsValueCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit
import Reusable

final class SettingsValueCell: UITableViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    // MARK: - Properties
        
    static var size: CGSize {
        let width = UIScreen.main.bounds.width
                
        return CGSize(width: width, height: 44)
    }
    
    var viewModel: SettingsValueCellViewModel? {
        didSet { configure() }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.value
    }
}
