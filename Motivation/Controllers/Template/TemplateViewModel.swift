//
//  TemplateViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RxSwift
import RxCocoa

struct TemplateViewModelActions { }

protocol TemplateViewModelProtocol: AnyObject { }

final class TemplateViewModel: TemplateViewModelProtocol {
    
    // MARK: - Properties
    
    private let actions: TemplateViewModelActions
    
    // MARK: - Lifecycle
    
    init(actions: TemplateViewModelActions) {
        self.actions = actions
    }
}
