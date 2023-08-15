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
    private let authAccount: Account
    private let rekeyedAccounts: [Account]

    init(
        api: ALGAPI,
        sharedDataController: SharedDataController,
        loadingController: LoadingController?,
        account: Account,
        authAccount: Account,
        rekeyedAccounts: [Account]
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
        self.loadingController = loadingController
        self.account = account
        self.authAccount = authAccount
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
        case .rekeyedAccounts: return account.authorization.isRekeyed ? 1 : rekeyedAccounts.count
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
        let viewModel = makeAccountListItemViewModel(account)
        cell.bindData(viewModel)
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
            cell.bindData(item.viewModel)
            return cell
        case .collectibleAsset(let item):
            let cell = collectionView.dequeue(
                CollectibleListItemCell.self,
                at: indexPath
            )
            cell.bindData(item.viewModel)
            return cell
        }
    }

    func cellForRekeyedAccount(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountListItemCell.self, at: indexPath)

        if account.authorization.isRekeyed {
            let viewModel = makeAccountListItemViewModel(authAccount)
            cell.bindData(viewModel)
        } else {
            let rekeyedAccount = rekeyedAccounts[indexPath.row]
            let viewModel = makeAccountListItemViewModel(rekeyedAccount)
            cell.bindData(viewModel)
        }

        return cell
    }
}

extension LedgerAccountDetailDataSource {
    private func makeAccountListItemViewModel(_ account: Account) -> AccountListItemViewModel {
        let currency = sharedDataController.currency
        let accountValue = AccountHandle(
            account: account,
            status: .ready
        )
        let item = AccountPortfolioItem(
            accountValue: accountValue,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        return AccountListItemViewModel(item)
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
            AssetFetchQuery(ids: assetsToBeFetched, includeDeleted: true),
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
                
                if let selectedAccountSortingAlgorithm = self.sharedDataController.selectedAccountAssetSortingAlgorithm {
                    self.assetListItems.sort {
                        return selectedAccountSortingAlgorithm.getFormula(
                            asset: $0.asset,
                            otherAsset: $1.asset
                        )
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
        
        return .asset(LedgerAccountAssetListItem(item: item))
    }

    private func makeCollectibleAssetListItem(_ asset: CollectibleAsset) -> LedgerAccountDetailAssetListItem {
        let item = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        
        return .collectibleAsset(LedgerAccountCollectibleListItem(item: item))
    }
}

extension LedgerAccountDetailDataSource {
    enum Event {
        case didLoadData
        case didFailLoadingData
    }
}

enum LedgerAccountDetailAssetListItem {
    case asset(LedgerAccountAssetListItem)
    case collectibleAsset(LedgerAccountCollectibleListItem)
}

extension LedgerAccountDetailAssetListItem {
    var asset: Asset {
        switch self {
        case .asset(let item): return item.asset
        case .collectibleAsset(let item): return item.asset
        }
    }
}

struct LedgerAccountAssetListItem: Hashable {
    let asset: Asset
    let viewModel: AssetListItemViewModel
    
    init(item: AssetItem) {
        self.asset = item.asset
        self.viewModel = AssetListItemViewModel(item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(viewModel.title?.primaryTitle?.string)
        hasher.combine(viewModel.title?.secondaryTitle?.string)
        hasher.combine(viewModel.primaryValue?.string)
        hasher.combine(viewModel.secondaryValue?.string)
    }

    static func == (
        lhs: LedgerAccountAssetListItem,
        rhs: LedgerAccountAssetListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.viewModel.title?.primaryTitle?.string == rhs.viewModel.title?.primaryTitle?.string &&
            lhs.viewModel.title?.secondaryTitle?.string == rhs.viewModel.title?.secondaryTitle?.string &&
            lhs.viewModel.primaryValue?.string == rhs.viewModel.primaryValue?.string &&
            lhs.viewModel.secondaryValue?.string == rhs.viewModel.secondaryValue?.string
    }
}

struct LedgerAccountCollectibleListItem: Hashable {
    let asset: CollectibleAsset
    let viewModel: CollectibleListItemViewModel

    init(item: CollectibleAssetItem) {
        self.asset = item.asset
        self.viewModel = CollectibleListItemViewModel(item: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(asset.amount)
        hasher.combine(viewModel.primaryTitle?.string)
        hasher.combine(viewModel.secondaryTitle?.string)
    }

    static func == (
        lhs: LedgerAccountCollectibleListItem,
        rhs: LedgerAccountCollectibleListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.asset.amount == rhs.asset.amount &&
            lhs.viewModel.primaryTitle?.string == rhs.viewModel.primaryTitle?.string &&
            lhs.viewModel.secondaryTitle?.string == rhs.viewModel.secondaryTitle?.string
    }
}
