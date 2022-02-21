//
//  QuoteViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit
import RxSwift

final class QuoteViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(cellType: QuoteCell.self)
            collectionView.decelerationRate = .fast
        }
    }
    @IBOutlet private weak var accountButton: AnimateButton! {
        didSet { accountButton.layer.smoothCorner(8) }
    }
    @IBOutlet private weak var categoryButton: AnimateButton! {
        didSet { categoryButton.layer.smoothCorner(8) }
    }
    
    // MARK: - Properties
    
    var viewModel: QuoteViewModelProtocol!
    
    private var composition = QuoteViewModel.Composition()
    private let disposeBag = DisposeBag()
    private var lastHiddingRow: Int?
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: QuoteViewModelProtocol) -> QuoteViewController {
        guard let viewController = R.storyboard.quoteViewController().instantiateInitialViewController()
                as? QuoteViewController
        else { fatalError("Could not instantiate QuoteViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(to: viewModel)
        
        viewModel.refreshQuotesIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    // MARK: - Private methods
    
    private func bind(to viewModel: QuoteViewModelProtocol) {
        viewModel.composition
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.composition = $0
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction private func accountButtonDidTap(_ sender: AnimateButton) {
        viewModel.presentSettings()
    }
    
    @IBAction private func categoryButtonDidTap(_ sender: AnimateButton) {
        viewModel.presentCategory()
    }
}

// MARK: - UICollectionViewDataSource -

extension QuoteViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { composition.sections.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { composition.sections[section].count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return UICollectionViewCell() }
        
        switch type {
        case let .quote(viewModel):
            let cell: QuoteCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(to: viewModel)
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension QuoteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return .zero }
        
        switch type {
        case .quote: return QuoteCell.size
        }
    }
}

// MARK: - UICollectionViewDelegate -

extension QuoteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if lastHiddingRow != indexPath.row {
            viewModel.showNextQuote()
        }
        
        lastHiddingRow = indexPath.row
    }
}

// MARK: - CategoryViewControllerDelegate -

extension QuoteViewController: CategoryViewControllerDelegate {
    func categoryViewControllerDidDismiss(_ sender: CategoryViewController) {
        viewModel.refreshSelectedCategory()
    }
}
