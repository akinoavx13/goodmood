//
//  CategoryViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit
import RxSwift

final class CategoryViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var accountButton: AnimateButton! {
        didSet { accountButton.layer.smoothCorner(8) }
    }
    
    // MARK: - Properties
    
    var viewModel: CategoryViewModelProtocol!
    
    private var composition = CategoryViewModel.Composition()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: CategoryViewModelProtocol) -> CategoryViewController {
        guard let viewController = R.storyboard.categoryViewController().instantiateInitialViewController()
                as? CategoryViewController
        else { fatalError("Could not instantiate CategoryViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = R.string.localizable.categories()
        
        bind(to: viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    // MARK: - Private methods
    
    private func bind(to viewModel: CategoryViewModelProtocol) {
        viewModel.composition
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.composition = $0
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource -

extension CategoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { composition.sections.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { composition.sections[section].count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return UICollectionViewCell() }
        
        return UICollectionViewCell()
//        switch type {
//        case let .Category(viewModel):
//            let cell: CategoryCell = collectionView.dequeueReusableCell(for: indexPath)
//            cell.bind(to: viewModel)
//
//            return cell
//        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return .zero }
        
        return .zero
//        switch type {
//        case .Category: return CategoryCell.size
//        }
    }
}
