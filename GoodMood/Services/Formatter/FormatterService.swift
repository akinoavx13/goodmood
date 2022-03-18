//
//  FormatterService.swift
//  The Weather
//
//  Created by Maxime Maheo on 07/12/2021.
//

import Foundation

protocol FormatterServiceProtocol: AnyObject {
    func format(value: Double,
                style: NumberFormatter.Style,
                locale: Locale) -> String?
}

final class FormatterService: FormatterServiceProtocol {
    
    // MARK: - Properties
    
    private let numberFormatter = NumberFormatter()
    
    private let calendar = Calendar.current

    // MARK: - Methods
    
    func format(value: Double,
                style: NumberFormatter.Style,
                locale: Locale) -> String? {
        numberFormatter.numberStyle = style
        numberFormatter.locale = locale
        
        return numberFormatter.string(from: NSNumber(value: value))
    }
}
