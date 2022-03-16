//
//  Quote.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

struct Quote {
    
    // MARK: - Properties
    
    let content: String
    
    // MARK: - Lifecycle
    
    init(rmQuote: RMQuote) {    
        self.content = rmQuote.content
    }
}
