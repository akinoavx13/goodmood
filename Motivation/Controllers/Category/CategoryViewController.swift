//
//  CategoryViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit
import RxSwift

protocol CategoryViewControllerDelegate: AnyObject {
    func categoryViewControllerDidDismiss(_ sender: CategoryViewController)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet { collectionView.register(cellType: CategoryCell.self) }
    }
    @IBOutlet private weak var accountButton: AnimateButton! {
        didSet { accountButton.layer.smoothCorner(8) }
    }
    
    // MARK: - Properties
    
    weak var delegate: CategoryViewControllerDelegate?
    
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
        
        configure()
        
        bind(to: viewModel)
        
        viewModel.refreshCategories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        delegate?.categoryViewControllerDidDismiss(self)
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        title = R.string.localizable.categories()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(rightBarButtonItemDidTap))
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
    
    @objc private func rightBarButtonItemDidTap() {
        dismiss(animated: true)
    }
    
    private func selectCategory(row: Int) {
        viewModel.selectCategory(row: row)
        
        // TODO: Dismiss only if selected category is different
        dismiss(animated: true)
    }
}
// MARK: - UICollectionViewDataSource -

extension CategoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { composition.sections.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { composition.sections[section].count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return UICollectionViewCell() }

        switch type {
        case let .category(viewModel):
            let cell: CategoryCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(to: viewModel)
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return .zero }
        
        switch type {
        case .category: return CategoryCell.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return }
        
        switch type {
        case .category: selectCategory(row: indexPath.row)
        }
    }
}
