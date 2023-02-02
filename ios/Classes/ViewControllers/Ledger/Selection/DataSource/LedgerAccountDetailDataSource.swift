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
//   LedgerAccountDetailDataSource.swift

import MacaroonUIKit
import UIKit

final class LedgerAccountDetailDataSource: NSObject {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var collectibleAmountFormatter = CollectibleAmountFormatter()

    private var assetListItems: [LedgerAccountDetailAssetListItem] = []

    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let loadingController: LoadingController?
    private let account: Account
    private let rekeyedAccounts: [Account]

    init(
        api: ALGAPI,
        sharedDataController: SharedDataController,
        loadingController: LoadingController?,
        account: Account,
        rekeyedAccounts: [Account]
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
        self.loadingController = loadingController
        self.account = account
        self.rekeyedAccounts = rekeyedAccounts
        super.init()
    }
}

extension LedgerAccountDetailDataSource: UICollectionViewDataSource {
    private var sections: [Section] {
        var sections: [Section] = [.ledgerAccount]
        if !assetListItems.isEmpty { sections.append(.assets) }
        if !rekeyedAccounts.isEmpty { sections.append(.rekeyedAccounts) }
        return sections
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .ledgerAccount: return 1
        case .assets: return assetListItems.count
        case .rekeyedAccounts: return account.isRekeyed() ? 1 : rekeyedAccounts.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .ledgerAccount:
            return cellForLedgerAccount(collectionView, cellForItemAt: indexPath)
        case .assets:
            return cellForAsset(collectionView, cellForItemAt: indexPath)
        case .rekeyedAccounts:
            return cellForRekeyedAccount(collectionView, cellForItemAt: indexPath)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueHeader(
            LedgerAccountDetailSectionHeaderReusableView.self,
            at: indexPath
        )
        headerView.bindData(LedgerAccountDetailSectionHeaderViewModel(section: sections[indexPath.section], account: account))
        return headerView
    }
}

extension LedgerAccountDetailDataSource {
    func cellForLedgerAccount(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountListItemCell.self, at: indexPath)
        let accountNameViewModel = AccountNameViewModel(account: account)
        let item = CustomAccountListItem(
            accountNameViewModel,
            address: account.address
        )
        cell.bindData(AccountListItemViewModel(item))
        return cell
    }

    func cellForAsset(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetListItem = assetListItems[indexPath.item]

        switch assetListItem {
        case .asset(let item):
            let cell = collectionView.dequeue(
                AssetListItemCell.self,
                at: indexPath
            )
            cell.bindData(item)
            return cell
        case .collectibleAsset(let item):
            let cell = collectionView.dequeue(
                CollectibleListItemCell.self,
                at: indexPath
            )
            cell.bindData(item)
            return cell
        }
    }

    func cellForRekeyedAccount(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountListItemCell.self, at: indexPath)

        if account.isRekeyed() {
            let accountNameViewModel = AuthAccountNameViewModel(account)
            let item = CustomAccountListItem(
                accountNameViewModel,
                address: account.address
            )
            cell.bindData(AccountListItemViewModel(item))
        } else {
            let rekeyedAccount = rekeyedAccounts[indexPath.row]
            let accountNameViewModel = AccountNameViewModel(account: rekeyedAccount)
            let item = CustomAccountListItem(
                accountNameViewModel,
                address: rekeyedAccount.address
            )
            cell.bindData(AccountListItemViewModel(item))
        }
        return cell
    }
}

extension LedgerAccountDetailDataSource {
    enum Section: Int {
        case ledgerAccount = 0
        case assets = 1
        case rekeyedAccounts = 2
    }
}

extension LedgerAccountDetailDataSource {
    func fetchAssets() {
        let algoAssetListItem = makeAssetListItem(account.algo)
        assetListItems.append(algoAssetListItem)

        guard let assets = account.assets,
              !assets.isEmpty else {
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        var assetsToBeFetched: [AssetID] = []

        for asset in assets {
            if self.sharedDataController.assetDetailCollection[asset.id] == nil {
                assetsToBeFetched.append(asset.id)
            }
        }

        api.fetchAssetDetails(
            AssetFetchQuery(ids: assetsToBeFetched),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] assetResponse in
            guard let self = self else { return }

            self.loadingController?.stopLoading()

            switch assetResponse {
            case let .success(assetDetailResponse):
                assetDetailResponse.results.forEach {
                    self.sharedDataController.assetDetailCollection[$0.id] = $0
                }

                for asset in assets {
                    if let assetDetail = self.sharedDataController.assetDetailCollection[asset.id] {
                        if assetDetail.isCollectible {
                            let collectibleAsset = CollectibleAsset(asset: asset, decoration: assetDetail)
                            self.account.append(collectibleAsset)

                            let collectibleAssetListItem = self.makeCollectibleAssetListItem(collectibleAsset)
                            self.assetListItems.append(collectibleAssetListItem)
                        } else {
                            let standardAsset = StandardAsset(asset: asset, decoration: assetDetail)
                            self.account.append(standardAsset)

                            let assetListItem = self.makeAssetListItem(standardAsset)
                            self.assetListItems.append(assetListItem)
                        }
                    }
                }

                self.eventHandler?(.didLoadData)
            case .failure:
                self.eventHandler?(.didFailLoadingData)
            }
        }
    }

    private func makeAssetListItem(_ asset: Asset) -> LedgerAccountDetailAssetListItem {
        let currency = sharedDataController.currency
        let item = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let viewModel = AssetListItemViewModel(item)
        return .asset(viewModel)
    }

    private func makeCollectibleAssetListItem(_ asset: CollectibleAsset) -> LedgerAccountDetailAssetListItem {
        let item = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let viewModel = CollectibleListItemViewModel(item: item)
        return .collectibleAsset(viewModel)
    }
}

extension LedgerAccountDetailDataSource {
    enum Event {
        case didLoadData
        case didFailLoadingData
    }
}

enum LedgerAccountDetailAssetListItem {
    case asset(AssetListItemViewModel)
    case collectibleAsset(CollectibleListItemViewModel)
}
