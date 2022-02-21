//
//  RMQuote.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import Foundation
import RealmSwift

final class RMQuote: Object {

    enum RMCategory: String, CaseIterable, PersistableEnum {
        case general,
             positivity,
             encouragement,
             breakup
        
        var translatedName: String {
            switch self {
            case .general: return R.string.localizable.general()
            case .positivity: return R.string.localizable.positivity()
            case .encouragement: return R.string.localizable.encouragement()
            case .breakup: return R.string.localizable.breakup()
            }
        }
        
        var icon: String {
            switch self {
            case .general: return "💬"
            case .positivity: return "👍"
            case .encouragement: return "👏"
            case .breakup: return "💔"
            }
        }
    }

    enum RMLanguage: String, PersistableEnum {
        case french,
             english
        
        static var user: Self {
            switch Locale.language() {
            case "fr": return .french
            default: return .english
            }
        }
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
