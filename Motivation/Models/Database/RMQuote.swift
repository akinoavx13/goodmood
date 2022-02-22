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
             breakup,
             anxiety,
             depression,
             fallingInLove,
             love,
             moveOn
        
        var translatedName: String {
            switch self {
            case .general: return R.string.localizable.general()
            case .positivity: return R.string.localizable.positivity()
            case .encouragement: return R.string.localizable.encouragement()
            case .breakup: return R.string.localizable.breakup()
            case .anxiety: return R.string.localizable.anxiety()
            case .depression: return R.string.localizable.depression()
            case .fallingInLove: return R.string.localizable.fallingInLove()
            case .love: return R.string.localizable.love()
            case .moveOn: return R.string.localizable.moveOn()
            }
        }
        
        var icon: String {
            switch self {
            case .general: return "💬"
            case .positivity: return "👍"
            case .encouragement: return "👏"
            case .breakup: return "💔"
            case .anxiety: return "😧"
            case .depression: return "😞"
            case .fallingInLove: return "🥰"
            case .love: return "❤️"
            case .moveOn: return "🤜"
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
