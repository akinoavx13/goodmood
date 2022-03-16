//
//  QuoteCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

final class QuoteCellViewModel {
    
    // MARK: - Properties
    
    let content: String
    let author: String?
    
    // MARK: - Lifecycle
    
    init(content: String) {
        let splited = content.components(separatedBy: "@ -")
        
        if splited.count == 2,
           let author = splited.last,
           let contentWithoutAuthor = splited.first {
            self.author = author
            self.content = contentWithoutAuthor.replacingOccurrences(of: "\n", with: "")
        } else {
            self.author = nil
            self.content = content
        }
    }
}
