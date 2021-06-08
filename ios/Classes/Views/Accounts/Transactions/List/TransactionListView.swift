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
//  TransactionListView.swift

import UIKit

class TransactionListView: BaseView {
    
    weak var delegate: TransactionListViewDelegate?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        image: img("icon-transactions-empty"),
        title: "accounts-tranaction-empty-text".localized,
        subtitle: ""
    )
    private lazy var otherErrorView = ListErrorView()
    private lazy var internetConnectionErrorView = ListErrorView()
    
    private lazy var transactionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        collectionView.register(PendingTransactionCell.self, forCellWithReuseIdentifier: PendingTransactionCell.reusableIdentifier)
        collectionView.register(RewardCell.self, forCellWithReuseIdentifier: RewardCell.reusableIdentifier)
        collectionView.register(
            TransactionHistoryHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TransactionHistoryHeaderSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        internetConnectionErrorView.setImage(img("icon-no-internet-connection"))
        internetConnectionErrorView.setTitle("internet-connection-error-title".localized)
        internetConnectionErrorView.setSubtitle("internet-connection-error-detail".localized)
        internetConnectionErrorView.layer.cornerRadius = 20.0
        internetConnectionErrorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        otherErrorView.setImage(img("icon-warning-error"))
        otherErrorView.setTitle("transaction-filter-error-title".localized)
        otherErrorView.setSubtitle("transaction-filter-error-subtitle".localized)
        otherErrorView.layer.cornerRadius = 20.0
        otherErrorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        emptyStateView.titleLabel.textColor = Colors.Text.tertiary
        emptyStateView.titleLabel.font = UIFont.font(withWeight: .medium(size: 16.0))
        emptyStateView.layer.cornerRadius = 20.0
        emptyStateView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func linkInteractors() {
        otherErrorView.delegate = self
        internetConnectionErrorView.delegate = self
    }
    
    override func prepareLayout() {
        setupTransactionHistoryCollectionViewLayout()
    }
}

extension TransactionListView {
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionsCollectionView)
        
        transactionsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        transactionsCollectionView.backgroundView = contentStateView
        transactionsCollectionView.refreshControl = refreshControl
    }
}

extension TransactionListView {
    @objc
    private func didRefreshList() {
        delegate?.transactionListViewDidRefreshList(self)
    }
}

extension TransactionListView {
    func reloadData() {
        transactionsCollectionView.reloadData()
    }
    
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        transactionsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        transactionsCollectionView.dataSource = dataSource
    }
    
    var isListRefreshing: Bool {
        return refreshControl.isRefreshing
    }
    
    func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func setEmptyState() {
        transactionsCollectionView.contentState = .empty(emptyStateView)
    }
    
    func setOtherErrorState() {
        transactionsCollectionView.contentState = .error(otherErrorView)
    }
    
    func setInternetConnectionErrorState() {
        transactionsCollectionView.contentState = .error(internetConnectionErrorView)
    }
    
    func setLoadingState() {
        if !refreshControl.isRefreshing {
            transactionsCollectionView.contentState = .loading
        }
    }
    
    func setNormalState() {
        transactionsCollectionView.contentState = .none
    }
    
    func headerView() -> TransactionHistoryHeaderSupplementaryView? {
        return transactionsCollectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? TransactionHistoryHeaderSupplementaryView
    }
}

extension TransactionListView: ListErrorViewDelegate {
    func listErrorViewDidTryAgain(_ listErrorView: ListErrorView) {
        delegate?.transactionListViewDidTryAgain(self)
    }
}

protocol TransactionListViewDelegate: class {
    func transactionListViewDidRefreshList(_ transactionListView: TransactionListView)
    func transactionListViewDidTryAgain(_ transactionListView: TransactionListView)
}
