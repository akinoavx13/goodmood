//
//  TemplateViewController.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit
import RxSwift

protocol TemplateViewControllerDelegate: AnyObject {
    func templateViewController(_ sender: TemplateViewController,
                                didSelectTemplate templateId: String)
}

final class TemplateViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet { collectionView.register(cellType: TemplateCell.self) }
    }
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
        
    weak var delegate: TemplateViewControllerDelegate?
    
    var viewModel: TemplateViewModelProtocol!
    
    private var composition = TemplateViewModel.Composition()
    private let disposeBag = DisposeBag()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .rigid)

    // MARK: - Lifecycle
    
    static func create(with viewModel: TemplateViewModelProtocol) -> TemplateViewController {
        guard let viewController = R.storyboard.templateViewController().instantiateInitialViewController()
                as? TemplateViewController
        else { fatalError("Could not instantiate TemplateViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        impactGenerator.impactOccurred()
    }
    
    // MARK: - Setup methods
    
    private func configure() {
        title = R.string.localizable.templates()
    }
    
    // MARK: - Private methods
    
    private func bind(to viewModel: TemplateViewModelProtocol) {
        viewModel.composition
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.composition = $0
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
    
    private func selectTemplate(row: Int) {
        guard let templateId = viewModel.selectTemplate(row: row) else { return }
        
        impactGenerator.impactOccurred()
        dismiss(animated: true)
        
        delegate?.templateViewController(self, didSelectTemplate: templateId)
    }
}

// MARK: - UICollectionViewDataSource -

extension TemplateViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { composition.sections.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { composition.sections[section].count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return UICollectionViewCell() }

        switch type {
        case let .template(viewModel):
            let cell: TemplateCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(to: viewModel)
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension TemplateViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return .zero }
        
        switch type {
        case .template: return TemplateCell.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return }
        
        switch type {
        case .template: selectTemplate(row: indexPath.row)
        }
    }
}
