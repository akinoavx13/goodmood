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
    
    @IBOutlet private weak var categoryButton: AnimateButton! {
        didSet { categoryButton.layer.smoothCorner(8) }
    }
    
    // MARK: - Properties
    
    static var size: CGSize {
        let numberOfColumns: CGFloat = 2
        let width = (UIScreen.main.bounds.width - 32 - ((numberOfColumns - 1) * 16)) / numberOfColumns
        
        return CGSize(width: width,
                      height: 80)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        categoryButton.setTitle(nil, for: .normal)
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: CategoryCellViewModel) {
        categoryButton.setTitle(viewModel.name, for: .normal)
    }
}
