// Copyright 2022 Pera Wallet, LDA

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
import MacaroonUIKit

final class SingleSelectionListView: View {
    weak var delegate: SingleSelectionListViewDelegate?
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.collectionViewMinimumLineSpacing
        flowLayout.minimumInteritemSpacing = theme.collectionViewMinimumInteritemSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.register(SingleSelectionCell.self)
        collectionView.register(header: SingleGrayTitleHeaderSuplementaryView.self)
        return collectionView
    }()
    
    private lazy var theme = SingleSelectionListViewTheme()
    private lazy var errorView = NoContentWithActionView()
    
    private lazy var refreshControl = UIRefreshControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize(theme)
        linkInteractors()
    }

    func customize(_ theme: SingleSelectionListViewTheme) {
        errorView.customize(NoContentWithActionViewCommonTheme())
        errorView.bindData(ListErrorViewModel())

        addCollectionView(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func linkInteractors() {
        errorView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.singleSelectionListViewDidTryAgain(self)
        }

        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
    }
}

extension SingleSelectionListView {
    private func addCollectionView(_ theme: SingleSelectionListViewTheme) {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
    
    func setRefreshControl() {
        collectionView.refreshControl = refreshControl
    }
}

protocol SingleSelectionListViewDelegate: AnyObject {
    func singleSelectionListViewDidRefreshList(_ singleSelectionListView: SingleSelectionListView)
    func singleSelectionListViewDidTryAgain(_ singleSelectionListView: SingleSelectionListView)
}
