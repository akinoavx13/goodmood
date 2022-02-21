//
//  Locale+Language.swift
//  Motivation
//
//  Created by Maxime Maheo on 21/02/2022.
//

import Foundation

extension Locale {

    static func preferredLocale(preferredLanguages: [String] = Locale.preferredLanguages) -> Locale {
        guard let preferredIdentifier = preferredLanguages.first else {
            return current
        }

        return Locale(identifier: preferredIdentifier)
    }

    static func language(preferredLanguages: String? = Locale.preferredLanguages.first) -> String {
        let languageIdentifier = preferredLanguages ?? "en-US"
        let languageDic = Locale.components(fromIdentifier: languageIdentifier)

        return languageDic["kCFLocaleLanguageCodeKey"] ?? "en"
    }

}
