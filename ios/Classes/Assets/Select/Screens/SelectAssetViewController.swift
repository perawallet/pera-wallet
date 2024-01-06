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
//  SelectAssetViewController.swift

import UIKit
import MacaroonUIKit

final class SelectAssetViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var listView: UICollectionView = {
        let collectionViewLayout = SelectAssetViewControllerListLayout.build()
        let collectionView =
            UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(PreviewLoadingCell.self)
        collectionView.register(AssetListItemCell.self)
        collectionView.register(CollectibleListItemCell.self)
        return collectionView
    }()

    private lazy var listDataSource = SelectAssetViewControllerDataSource(
        account: account,
        sharedDataController: sharedDataController
    )
    private lazy var listLayout =
        SelectAssetViewControllerListLayout(listDataSource: listDataSource)

    private var isViewLayoutLoaded = false

    private let account: Account
    private let receiverAccount: Account?
    private let theme: SelectAssetViewControllerTheme

    init(
        account: Account,
        receiver: String?,
        theme: SelectAssetViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.receiverAccount = receiver.unwrap { Account(address: $0) }
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        navigationItem.title = "send-select-asset".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            loadData()
            isViewLayoutLoaded = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLoading()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopLoading()
    }
}

extension SelectAssetViewController {
    private func addUI() {
        addBackground()
        addList()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }

        listView.delegate = self
        listView.dataSource = listDataSource
    }
}

extension SelectAssetViewController {
    private func startLoading() {
        let loadingCell = findVisibleLoadingCell()
        loadingCell?.startAnimating()
    }

    private func loadData() {
        listDataSource.loadData {
            [weak self] in
            guard let self = self else { return }
            self.listView.reloadData()
        }
    }

    private func stopLoading() {
        let loadingCell = findVisibleLoadingCell()
        loadingCell?.stopAnimating()
    }

    private func findVisibleLoadingCell() -> PreviewLoadingCell? {
        return listView.visibleCells.first { $0 is PreviewLoadingCell } as? PreviewLoadingCell
    }
}

extension SelectAssetViewController {
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
}

extension SelectAssetViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let loadingCell = cell as? PreviewLoadingCell {
            loadingCell.startAnimating()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let loadingCell = cell as? PreviewLoadingCell {
            loadingCell.stopAnimating()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let asset = itemIdentifier.asset

        var assetAmount: Decimal?
        if let collectibleAsset = asset as? CollectibleAsset,
           collectibleAsset.isPure {
            assetAmount = 1
        }

        let mode: TransactionMode = asset.isAlgo ? .algo : .asset(asset)
        let draft = SendTransactionDraft(
            from: account,
            toAccount: receiverAccount,
            amount: assetAmount,
            transactionMode: mode
        )
        open(
            .sendTransaction(draft: draft),
            by: .push
        )
    }
}
