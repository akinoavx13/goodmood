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
    
        contentLabel.attributedText = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: QuoteCellViewModel) {
        let attributedText = NSMutableAttributedString(string: viewModel.content, attributes: [.font: UIFont.systemFont(ofSize: 30, weight: .regular)])
        
        if let author = viewModel.author {
            attributedText.append(NSAttributedString(string: "\n\n-\(author)", attributes: [.font: UIFont.italicSystemFont(ofSize: 24)]))
        }
        
        contentLabel.attributedText = attributedText
    }
}
