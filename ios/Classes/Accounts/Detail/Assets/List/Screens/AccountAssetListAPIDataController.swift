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
//   AccountAssetListAPIDataController.swift

import Foundation
import MacaroonUtils

final class AccountAssetListAPIDataController:
    AccountAssetListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AccountAssetListDataControllerEvent) -> Void)?

    var addedAssetDetails: [StandardAsset] = []
    var removedAssetDetails: [StandardAsset] = []

    private lazy var currencyFormatter = CurrencyFormatter()

    private var accountHandle: AccountHandle
    private var assets: [StandardAsset] = []

    private var searchKeyword: String? = nil
    private var searchResults: [StandardAsset] = []

    private var listItems: [AssetPreviewModel] = []

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let updatesQueue = DispatchQueue(label: "com.algorand.queue.accountAssetListDataController")

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    init(
        _ accountHandle: AccountHandle,
        _ sharedDataController: SharedDataController
    ) {
        self.accountHandle = accountHandle
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript(index: Int) -> StandardAsset? {
        let searchResultIndex = index - 2
        return listItems[safe: searchResultIndex]?.asset as? StandardAsset
    }
}

extension AccountAssetListAPIDataController {
    func load() {
        sharedDataController.add(self)
    }

    func reload() {
        deliverContentUpdates()
    }
}

extension AccountAssetListAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case let .didStartRunning(first):
            if first ||
               lastSnapshot == nil {
                deliverContentUpdates()
            }
        case .didFinishRunning:
            if let updatedAccountHandle = sharedDataController.accountCollection[accountHandle.value.address] {
                accountHandle = updatedAccountHandle
            }
            deliverContentUpdates()
        default:
            break
        }
    }
}

extension AccountAssetListAPIDataController {
    private func deliverContentUpdates(
        isNewSearch: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        deliverUpdates {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = Snapshot()

            let currency = self.sharedDataController.currency
            let currencyFormatter = self.currencyFormatter
            let isWatchAccount = self.accountHandle.value.isWatchAccount()

            let portfolio = AccountPortfolioItem(
                accountValue: self.accountHandle,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            let portfolioItem = AccountPortfolioViewModel(portfolio)

            snapshot.appendSections([.portfolio])

            if isWatchAccount {
                snapshot.appendItems(
                    [.watchPortfolio(portfolioItem)],
                    toSection: .portfolio
                )
            } else {
                snapshot.appendItems(
                    [.portfolio(portfolioItem)],
                    toSection: .portfolio
                )
            }

            if !isWatchAccount {
                snapshot.appendSections([.quickActions])
                snapshot.appendItems(
                    [.quickActions],
                    toSection: .quickActions
                )
            }

            var assetItems: [AccountAssetsItem] = []

            let titleItem: AccountAssetsItem

            if isWatchAccount {
                titleItem = .watchAccountAssetManagement(
                    ManagementItemViewModel(
                        .asset(
                            isWatchAccountDisplay: true
                        )
                    )
                )
            } else {
                titleItem = .assetManagement(
                    ManagementItemViewModel(
                        .asset(
                            isWatchAccountDisplay: false
                        )
                    )
                )
            }

            assetItems.append(titleItem)
            assetItems.append(.search)

            self.clearAddedAssetDetailsIfNeeded(for: self.accountHandle.value)
            self.clearRemovedAssetDetailsIfNeeded(for: self.accountHandle.value)

            self.load(with: self.searchKeyword)

            var assetPreviewModels: [AssetPreviewModel] = []

            if self.isKeywordContainsAlgo() {
                let algoAssetItem = AlgoAssetItem(
                    account: self.accountHandle,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let algoAssetPreview = AssetPreviewModelAdapter.adapt(algoAssetItem)
                assetPreviewModels.append(algoAssetPreview)
            }

            self.searchResults.forEach { asset in
                if self.removedAssetDetails.contains(asset) {
                    return
                }

                let assetItem = AssetItem(
                    asset: asset,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let preview = AssetPreviewModelAdapter.adaptAssetSelection(assetItem)
                assetPreviewModels.append(preview)
            }

            if let selectedAccountSortingAlgorithm = self.sharedDataController.selectedAccountAssetSortingAlgorithm {
                self.listItems = assetPreviewModels.sorted(
                    by: selectedAccountSortingAlgorithm.getFormula
                )
                assetItems.append(
                    contentsOf: self.listItems.map({
                        let viewModel = AssetPreviewViewModel($0)

                        switch $0.icon {
                        case .algo:
                            return .algo(viewModel)
                        default:
                            return .asset(viewModel)
                        }
                    })
                )
            } else {
                self.listItems = assetPreviewModels
                assetItems.append(
                    contentsOf: self.listItems.map({
                        let viewModel = AssetPreviewViewModel($0)

                        switch $0.icon {
                        case .algo:
                            return .algo(viewModel)
                        default:
                            return .asset(viewModel)
                        }
                    })
                )
            }

            self.addedAssetDetails.forEach {
                let assetItem: AccountAssetsItem = .pendingAsset(PendingAssetPreviewViewModel(AssetPreviewModelAdapter.adaptPendingAsset($0)))
                assetItems.append(assetItem)
            }

            self.removedAssetDetails.forEach {
                let assetItem: AccountAssetsItem = .pendingAsset(PendingAssetPreviewViewModel(AssetPreviewModelAdapter.adaptPendingAsset($0)))
                assetItems.append(assetItem)
            }

            snapshot.appendSections([.assets])
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            if self.searchResults.isEmpty && !self.isKeywordContainsAlgo() {
                snapshot.appendSections([.empty])

                snapshot.appendItems(
                    [ .empty(AssetListSearchNoContentViewModel(hasBody: true)) ],
                    toSection: .empty
                )
            }

            var updates = Updates(snapshot: snapshot)
            updates.isNewSearch = isNewSearch
            updates.completion = completion
            return updates
        }
    }

    private func deliverUpdates(
        updates: @escaping () -> Updates?
    ) {
        updatesQueue.async {
            [weak self] in
            guard let self = self else { return }

            guard let updates = updates() else {
                return
            }

            self.lastSnapshot = updates.snapshot
            self.publish(event: .didUpdate(updates))
        }
    }
}

extension AccountAssetListAPIDataController {
    private func publish(
        event: AccountAssetListDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }

    private func clearAddedAssetDetailsIfNeeded(for account: Account) {
        addedAssetDetails = addedAssetDetails.filter { !account.containsAsset($0.id) }.uniqueElements()
    }

    private func clearRemovedAssetDetailsIfNeeded(for account: Account) {
        removedAssetDetails = removedAssetDetails.filter { account.containsAsset($0.id) }.uniqueElements()
    }
}

/// <mark>: Search
extension AccountAssetListAPIDataController {
    func search(
        for query: String?,
        completion: @escaping () -> Void
    ) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.load(with: query)
            self.deliverContentUpdates(
                isNewSearch: true,
                completion: completion
            )
        }
    }

    private func load(with query: String?) {
        if query.isNilOrEmpty {
            searchKeyword = nil
        } else {
            searchKeyword = query
        }

        guard let searchKeyword = searchKeyword else {
            searchResults = accountHandle.value.standardAssets.someArray
            return
        }

        searchResults = accountHandle.value.standardAssets.someArray.filter { asset in
            isAssetContainsID(asset, query: searchKeyword) ||
            isAssetContainsName(asset, query: searchKeyword) ||
            isAssetContainsUnitName(asset, query: searchKeyword)
        }
    }

    private func isAssetContainsID(_ asset: StandardAsset, query: String) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: StandardAsset, query: String) -> Bool {
        return asset.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: StandardAsset, query: String) -> Bool {
        return asset.unitName.someString.localizedCaseInsensitiveContains(query)
    }

    private func isKeywordContainsAlgo() -> Bool {
        guard let keyword = searchKeyword, !keyword.isEmptyOrBlank else {
            /// <note>: If keyword doesn't contain any word or it's empty, it should return true for adding algo to asset list
            return true
        }

        return "algo".containsCaseInsensitive(keyword)
    }
}

extension AccountAssetListAPIDataController {
    typealias Updates = AccountAssetListUpdates
    typealias Snapshot = AccountAssetListUpdates.Snapshot
}
