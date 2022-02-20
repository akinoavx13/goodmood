//
//  QuoteCell.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit
import Reusable

final class QuoteCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var contentLabel: UILabel!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        contentLabel.text = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: QuoteCellViewModel) {
        contentLabel.text = viewModel.content
    }
        
}
