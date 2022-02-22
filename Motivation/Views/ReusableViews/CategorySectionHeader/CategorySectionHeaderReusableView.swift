//
//  CategorySectionHeaderReusableView.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

import UIKit
import Reusable

final class CategorySectionHeaderReusableView: UICollectionReusableView, NibReusable {

    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 44)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
    
    // MARK: - Methods
    
    static func size(for viewModel: CategorySectionHeaderReusableViewModel) -> CGSize {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width - 32,
                                    height: CGFloat.greatestFiniteMagnitude)

        let titleBoundingBox = NSString(string: viewModel.title)
            .boundingRect(with: constraintRect,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)],
                          context: nil)
        
        return CGSize(width: UIScreen.main.bounds.width,
                      height: 10 + titleBoundingBox.height + 10)
    }
    
    func bind(to viewModel: CategorySectionHeaderReusableViewModel) {
        titleLabel.text = viewModel.title
    }
}
