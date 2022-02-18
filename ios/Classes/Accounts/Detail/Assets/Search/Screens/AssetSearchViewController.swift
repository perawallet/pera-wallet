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
//   AssetSearchViewController.swift

import Foundation
import UIKit
import MacaroonUtils
import MacaroonUIKit

final class AssetSearchViewController: BaseViewController {
    private lazy var theme = Theme()
    lazy var handlers = Handlers()

    private lazy var listLayout = AssetSearchListLayout(dataController: dataController)
    private lazy var dataSource = AssetSearchDataSource(listView)
    private lazy var dataController = AssetSearchLocalDataController(accountHandle, sharedDataController)
    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    private lazy var searchInputView = SearchInputView()

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(AssetPreviewCell.self)
        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        return collectionView
    }()

    private let accountHandle: AccountHandle

    init(
        accountHandle: AccountHandle,
        configuration: ViewControllerConfiguration
    ) {
        self.accountHandle = accountHandle
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }

        dataController.load()
    }

    override func setListeners() {
        listView.dataSource = dataSource
        listView.delegate = listLayout
        setListListeners()
    }

    override func linkInteractors() {
        searchInputView.delegate = self
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.listBackgroundColor)
    }

    override func prepareLayout() {
        addSearchInputView()
        addListView()
    }
}

extension AssetSearchViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension AssetSearchViewController {
    private func addSearchInputView() {
        searchInputView.customize(theme.searchInputViewTheme)

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.top.equalToSuperview().inset(theme.topInset).priority(.low)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AssetSearchViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        if query.isEmpty {
            dataController.resetSearch()
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
    
    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        dataController.resetSearch()
    }
}

extension AssetSearchViewController {
    private func setListListeners() {
        listLayout.handlers.didSelectIndex = { [weak self] index in
            guard let self = self,
                  let compoundAsset = self.dataController[index] else {
                return
            }

            self.closeScreen(by: .dismiss, animated: false)
            self.handlers.didSelectAsset?(compoundAsset)
        }
    }
}

extension AssetSearchViewController {
    struct Handlers {
        var didSelectAsset: ((CompoundAsset) -> Void)?
    }
}
