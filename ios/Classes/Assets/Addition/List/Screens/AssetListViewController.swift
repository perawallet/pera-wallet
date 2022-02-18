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
//   AssetListViewController.swift

import Foundation

final class AssetListViewController: BaseViewController {
    weak var delegate: AssetListViewControllerDelegate?

    private lazy var theme = Theme()
    private lazy var assetListView = AssetListView()

    private lazy var dataSource = AssetListViewDataSource(assetListView.collectionView)
    private lazy var dataController = AssetListViewAPIDataController(self.api!, filter: filter)
    private lazy var listLayout = AssetListViewLayout(listDataSource: dataSource)

    private let filter: AssetSearchFilter

    init(filter: AssetSearchFilter, configuration: ViewControllerConfiguration) {
        self.filter = filter
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        assetListView.customize(theme.assetListViewTheme)
        view.addSubview(assetListView)
        assetListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func linkInteractors() {
        super.linkInteractors()

        assetListView.collectionView.delegate = listLayout
        assetListView.collectionView.dataSource = dataSource
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
        super.setListeners()

        listLayout.handlers.willDisplay = { [weak self] cell, indexPath in
            guard let self = self else {
                return
            }

            self.dataController.loadNextPageIfNeeded(for: indexPath)
        }

        listLayout.handlers.didSelectAssetAt = { [weak self] indexPath in
            guard let self = self,
                  let item = self.dataController.assets[safe: indexPath.item] else {
                return
            }

            self.delegate?.assetListViewController(self, didSelectItem: item)
        }
    }

    func fetchAssets(for query: String?) {
        dataController.search(for: query)
    }
}

protocol AssetListViewControllerDelegate: AnyObject {
    func assetListViewController(_ assetListViewController: AssetListViewController, didSelectItem item: AssetInformation)
}
