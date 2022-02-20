//
//  RMQuote.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RealmSwift

final class RMQuote: Object {

    enum RMCategory: String, PersistableEnum {
        case general,
             positivity,
             encouragement,
             breakup
    }

    enum RMLanguage: String, PersistableEnum {
        case french,
             english
    }
    
    // MARK: - Properties
    
    @Persisted var content = ""
    @Persisted var category = RMCategory.general
    @Persisted var language = RMLanguage.english

    // MARK: - Lifecycle
    
    convenience init(content: String,
                     category: RMCategory,
                     language: RMLanguage) {
        self.init()
        
        self.content = content
        self.category = category
        self.language = language
    }
}
