//
//  TemplateCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 15/03/2022.
//

import UIKit
import Reusable

final class TemplateCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var templateImageView: UIImageView! {
        didSet {
            templateImageView.layer.smoothCorner(8)
            templateImageView.layer.borderColor = UIColor.label.cgColor
            templateImageView.layer.borderWidth = 0
        }
    }
    @IBOutlet private weak var selectedImageView: UIImageView! {
        didSet {
            selectedImageView.layer.borderColor = UIColor.white.cgColor
            selectedImageView.layer.borderWidth = 2
            selectedImageView.layer.cornerRadius = 12
            selectedImageView.backgroundColor = .white
        }
    }
    
    // MARK: - Properties
    
    static var size: CGSize {
        let numberOfColumns: CGFloat = 2
        let width = (UIScreen.main.bounds.width - 32 - ((numberOfColumns - 1) * 16)) / numberOfColumns
        
        return CGSize(width: width,
                      height: width * 1.50)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        templateImageView.image = nil
        templateImageView.layer.borderWidth = 0
        selectedImageView.isHidden = true
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: TemplateCellViewModel) {
        templateImageView.image = viewModel.templateImage.image
        templateImageView.layer.borderWidth = viewModel.isSelected ? 2 : 0
        selectedImageView.isHidden = !viewModel.isSelected
    }
}
