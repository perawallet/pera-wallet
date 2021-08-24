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
//  SingleSelectionListView.swift

import UIKit

class SingleSelectionListView: BaseView {
    
    weak var delegate: SingleSelectionListViewDelegate?
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.tertiary
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(SingleSelectionCell.self, forCellWithReuseIdentifier: SingleSelectionCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var errorView = ListErrorView()
    
    private lazy var contentStateView = ContentStateView()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        errorView.setImage(img("icon-warning-error"))
        errorView.setTitle("transaction-filter-error-title".localized)
        errorView.setSubtitle("transaction-filter-error-subtitle".localized)
    }
    
    override func linkInteractors() {
        errorView.delegate = self
    }

    override func prepareLayout() {
        setupCollectionViewLayout()
    }
}

extension SingleSelectionListView {
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundView = contentStateView
        collectionView.refreshControl = refreshControl
    }
}

extension SingleSelectionListView {
    @objc
    private func didRefreshList() {
        delegate?.singleSelectionListViewDidRefreshList(self)
    }
}

extension SingleSelectionListView {
    func reloadData() {
        collectionView.reloadData()
    }
    
    func setListDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }
    
    var isListRefreshing: Bool {
        return refreshControl.isRefreshing
    }
    
    func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func setErrorState() {
        collectionView.contentState = .error(errorView)
    }
    
    func setNormalState() {
        collectionView.contentState = .none
    }

    func setLoadingState() {
        if !refreshControl.isRefreshing {
            collectionView.contentState = .loading
        }
    }
}

extension SingleSelectionListView: ListErrorViewDelegate {
    func listErrorViewDidTryAgain(_ listErrorView: ListErrorView) {
        delegate?.singleSelectionListViewDidTryAgain(self)
    }
}

protocol SingleSelectionListViewDelegate: AnyObject {
    func singleSelectionListViewDidRefreshList(_ singleSelectionListView: SingleSelectionListView)
    func singleSelectionListViewDidTryAgain(_ singleSelectionListView: SingleSelectionListView)
}
