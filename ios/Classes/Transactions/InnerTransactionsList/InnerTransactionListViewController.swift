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

//   InnerTransactionListViewController.swift

import UIKit
import MacaroonUIKit

final class InnerTransactionListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = InnerTransactionListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = InnerTransactionListLayout(
        listDataSource: listDataSource,
        currency: sharedDataController.currency,
        currencyFormatter: dataController.currencyFormatter
    )

    private lazy var listDataSource = InnerTransactionListDataSource(listView)

    private let dataController: InnerTransactionListDataController
    private let theme: InnerTransactionListViewControllerTheme

    init(
        dataController: InnerTransactionListDataController,
        theme: InnerTransactionListViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        title = "inner-transactions-title".localized

        addBarButtons()
    }

    override func prepareLayout() {
        super.prepareLayout()

        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
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

    private func build() {
        addBackground()
        addListView()
    }
}

extension InnerTransactionListViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .closeTitle) {
            [weak self] in
            self?.eventHandler?(.performClose)
        }

        rightBarButtonItems = [closeBarButtonItem]
    }
}

extension InnerTransactionListViewController {
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

extension InnerTransactionListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .appCallTransaction(let item):
            openAppCallTransactionDetail(item.transaction)
        case .algoTransaction(let item):
            openTransactionDetail(item.transaction)
        case .assetTransaction(let item):
            openTransactionDetail(item.transaction)
        case .assetConfigTransaction(let item):
            openTransactionDetail(item.transaction)
        case .keyRegTransaction(let item):
            openKeyRegTransactionDetail(item.transaction)
        default:
            break
        }
    }

    private func openAppCallTransactionDetail(_ transaction: Transaction) {
        let draft = dataController.draft
        let account = draft.account

        open(
            .appCallTransactionDetail(
                account: account,
                transaction: transaction,
                transactionTypeFilter: draft.type,
                assets: getAssetDetailForTransactionType(transaction)
            ),
            by: .present
        )
    }

    private func openKeyRegTransactionDetail(
        _ transaction: Transaction
    ) {
        open(
            .keyRegTransactionDetail(
                account: dataController.draft.account,
                transaction: transaction
            ),
            by: .present
        )
    }

    private func openTransactionDetail(
        _ transaction: Transaction
    ) {
        open(
            .transactionDetail(
                account: dataController.draft.account,
                transaction: transaction,
                assetDetail: getAssetDetailForTransactionType(transaction)?.first
            ),
            by: .present
        )
    }

    private func getAssetDetailForTransactionType(_ transaction: Transaction) -> [Asset]? {
        let draft = dataController.draft

        switch draft.type {
        case .all:
            let assetID =
            transaction.assetTransfer?.assetId ??
            transaction.assetFreeze?.assetId

            if let assetID = assetID,
                let decoration = sharedDataController.assetDetailCollection[assetID] {
                let standardAsset = StandardAsset(
                    asset: ALGAsset(id: assetID),
                    decoration: decoration
                )
                return [standardAsset]
            }

            if let applicationCall = transaction.applicationCall,
               let foreignAssets = applicationCall.foreignAssets {
                let assets: [StandardAsset] = foreignAssets.compactMap { ID in
                    if let decoration = sharedDataController.assetDetailCollection[ID] {
                        let standardAsset = StandardAsset(
                            asset: ALGAsset(id: ID),
                            decoration: decoration
                        )
                        return standardAsset
                    }

                    return nil
                }

                return assets
            }

            return nil
        case .asset:
            guard let asset = draft.asset else {
                return nil
            }

            return [asset]
        case .algos:
            return nil
        }
    }
}

extension InnerTransactionListViewController {
    enum Event {
        case performClose
    }
}
