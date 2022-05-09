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

final class AssetSearchViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    lazy var handlers = Handlers()
    
    private lazy var searchInputView = SearchInputView()

    private lazy var listView: UICollectionView = {
        let flowLayout = AssetSearchListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()

    private lazy var listLayout = AssetSearchListLayout(
        listDataSource: listDataSource
    )

    private lazy var listDataSource = AssetSearchDataSource(listView)

    private let theme: Theme
    private let dataController: AssetSearchDataController
    
    private let accountHandle: AccountHandle

    init(
        theme: Theme = .init(),
        accountHandle: AccountHandle,
        dataController: AssetSearchDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        self.accountHandle = accountHandle
        self.dataController = dataController
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
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }

        dataController.load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchInputView.beginEditing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchInputView.endEditing()
    }

    override func setListeners() {
        listView.delegate = self
        searchInputView.delegate = self
    }

    override func prepareLayout() {
        build()
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
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section],
              listSection == .assets,
              let asset = dataController[indexPath.item.advanced(by: -1)] else {
                  return
              }

        self.handlers.didSelectAsset?(asset)
    }
}

extension AssetSearchViewController {
    private func build() {
        addBackground()
        addSearchInputView()
        addListView()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

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
    struct Handlers {
        var didSelectAsset: ((StandardAsset) -> Void)?
    }
}
