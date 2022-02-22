//
//  CategoryCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit
import Reusable

final class CategoryCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var containerView: UIView! {
        didSet { containerView.layer.smoothCorner(8) }
    }
    @IBOutlet private weak var nameLabel: UILabel!
    
    // MARK: - Properties
    
    static var size: CGSize {
        let numberOfColumns: CGFloat = 2
        let width = (UIScreen.main.bounds.width - 32 - ((numberOfColumns - 1) * 16)) / numberOfColumns
        
        return CGSize(width: width,
                      height: 80)
    }
    
    override var isHighlighted: Bool {
        didSet { nameLabel.alpha = isHighlighted ? 0.5 : 1 }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        nameLabel.text = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: CategoryCellViewModel) {
        nameLabel.text = viewModel.name
        
        containerView.backgroundColor = viewModel.isSelected ? Colors.accent : Colors.background
        nameLabel.textColor = viewModel.isSelected ? .white : .label
    }
}
