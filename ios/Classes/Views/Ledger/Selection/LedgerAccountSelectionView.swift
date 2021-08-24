// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  LedgerAccountSelectionView.swift

import UIKit

class LedgerAccountSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerAccountSelectionViewDelegate?
    
    private lazy var errorView = ListErrorView()
    
    private lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 24.0, left: 0.0, bottom: layout.current.bottomInset + safeAreaBottom + 60.0, right: 0.0)
        flowLayout.minimumLineSpacing = 20.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = isMultiSelect
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = .zero
        collectionView.register(LedgerAccountCell.self, forCellWithReuseIdentifier: LedgerAccountCell.reusableIdentifier)
        collectionView.register(
            LedgerAccountSelectionHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: LedgerAccountSelectionHeaderSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    private lazy var addButton = MainButton(title: "ledger-account-selection-verify".localized)
    
    private let isMultiSelect: Bool
    
    init(isMultiSelect: Bool) {
        self.isMultiSelect = isMultiSelect
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        errorView.setImage(img("icon-warning-error"))
        errorView.setTitle("transaction-filter-error-title".localized)
        errorView.setSubtitle("transaction-filter-error-subtitle".localized)
    }
    
    override func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAccountsCollectionViewLayout()
        setupAddButtonLayout()
    }
}

extension LedgerAccountSelectionView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.ledgerAccountSelectionViewDidAddAccount(self)
    }
}

extension LedgerAccountSelectionView {
    private func setupAccountsCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension LedgerAccountSelectionView {
    func reloadData() {
        accountsCollectionView.reloadData()
    }
    
    func setListDelegate(_ delegate: UICollectionViewDelegate?) {
        accountsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        accountsCollectionView.dataSource = dataSource
    }
    
    func setErrorState() {
        accountsCollectionView.contentState = .error(errorView)
    }
    
    func indexPath(for cell: UICollectionViewCell) -> IndexPath? {
        return accountsCollectionView.indexPath(for: cell)
    }
    
    func setNormalState() {
        accountsCollectionView.contentState = .none
    }
    
    func setLoadingState() {
        accountsCollectionView.contentState = .loading
    }
    
    var selectedIndexes: [IndexPath] {
        return accountsCollectionView.indexPathsForSelectedItems ?? []
    }

    func bind(_ viewModel: LedgerAccountSelectionViewModel) {
        addButton.isEnabled = viewModel.isEnabled
        addButton.setTitle(viewModel.buttonText, for: .normal)
    }
}

extension LedgerAccountSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
        let listBottomInset: CGFloat = -4.0
    }
}

protocol LedgerAccountSelectionViewDelegate: AnyObject {
    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView)
}
