//
//  SettingsLinkCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit
import Reusable

final class SettingsLinkCell: UITableViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Properties
            
    var viewModel: SettingsLinkCellViewModel? {
        didSet { configure() }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
        iconImageView.tintColor = .white
        titleLabel.text = nil
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        iconImageView.image = UIImage(systemName: viewModel.iconName)
        iconImageView.tintColor = viewModel.iconColor
        titleLabel.text = viewModel.title
    }
    
    // MARK: - Methods
    
    static func size(for viewModel: SettingsLinkCellViewModel) -> CGSize {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width - 16 * 6 - 30,
                                    height: CGFloat.greatestFiniteMagnitude)
        
        var height: CGFloat = 8 + 8
        
        let titleBoundingBox = NSString(string: viewModel.title)
            .boundingRect(with: constraintRect,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          attributes: [.font: UIFont.systemFont(ofSize: 17)],
                          context: nil)
        
        height += titleBoundingBox.height

        height = max(height, 44)
        
        return CGSize(width: UIScreen.main.bounds.width,
                      height: height)
    }
}
