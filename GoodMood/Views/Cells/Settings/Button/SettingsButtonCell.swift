//
//  SettingsButtonCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit
import Reusable

final class SettingsButtonCell: UITableViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var button: UIButton! {
        didSet { button.titleLabel?.numberOfLines = 0 }
    }
    
    // MARK: - Properties
    
    var viewModel: SettingsButtonCellViewModel? {
        didSet { configure() }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        button.setTitle(nil, for: .normal)
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        button.setTitle(viewModel.title, for: .normal)
    }
    
    // MARK: - Methods
    
    static func size(for viewModel: SettingsButtonCellViewModel) -> CGSize {
        let margins: CGFloat = 2 * 16
        let constraintWidth: CGFloat = UIScreen.main.bounds.width - margins
        let constraintRect = CGSize(width: constraintWidth,
                                    height: CGFloat.greatestFiniteMagnitude)
                
        let titleBoundingBox = NSString(string: viewModel.title)
            .boundingRect(with: constraintRect,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          attributes: [.font: UIFont.systemFont(ofSize: 17)],
                          context: nil)
        
        let height: CGFloat = max(titleBoundingBox.height, 44)
        
        return CGSize(width: UIScreen.main.bounds.width,
                      height: height)
    }
}
