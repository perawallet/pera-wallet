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

//   SelectSwapPoolAssetDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class SelectSwapPoolAssetDataController:
    SelectAssetDataController,
    SharedDataControllerObserver {
    var eventHandler: ((SelectAssetDataControllerEvent) -> Void)?

    private lazy var currecyFormatter = CurrencyFormatter()

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)
    private var ongoingEndpoint: EndpointOperatable?

    private let updatesQueue = DispatchQueue(label: Constants.DispatchQueues.swapLocalAssetSnapshot)
    private var lastSnapshot: Snapshot?

    private var lastQuery: String?

    private var assets: [AssetDecoration] = []

    private(set) var account: Account
    private let userAsset: AssetID
    private let swapProviders: [SwapProvider]
    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    init(
        account: Account,
        userAsset: AssetID,
        swapProviders: [SwapProvider],
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.userAsset = userAsset
        self.swapProviders = swapProviders
        self.api = api
        self.sharedDataController = sharedDataController

        sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript(indexPath: IndexPath) -> Asset? {
        guard let assetDecoration = assets[safe: indexPath.item] else { return nil }

        if assetDecoration.isAlgo {
            return account.algo
        }

        if let assetInAccount = account[assetDecoration.id] {
            return assetInAccount
        }

        if assetDecoration.isCollectible {
            return CollectibleAsset(decoration: assetDecoration)
        }

        return StandardAsset(decoration: assetDecoration)
    }

    subscript(id: AssetID) -> Asset? {
        guard let assetDecoration = assets.first(where: { $0.id == id }) else { return nil }

        if assetDecoration.isAlgo {
            return account.algo
        }

        if let assetInAccount = account[assetDecoration.id] {
            return assetInAccount
        }

        if assetDecoration.isCollectible {
            return CollectibleAsset(decoration: assetDecoration)
        }

        return StandardAsset(decoration: assetDecoration)
    }
}

extension SelectSwapPoolAssetDataController {
    func load() {
        deliverLoadingSnapshot()
        getPoolAssets()
    }

    func search(
        for query: String?
    ) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.getPoolAssets(with: query)
        }
    }

    func resetSearch() {
        lastQuery = nil
        searchThrottler.cancelAll()
        load()
    }
}

extension SelectSwapPoolAssetDataController {
    private func getPoolAssets(
        with query: String? = nil
    ) {
        cancelOngoingEndpoint()

        let draft = AvailablePoolAssetsQuery(
            assetID: userAsset,
            providers: swapProviders,
            query: query
        )

        ongoingEndpoint = api.getAvailablePoolAssets(
            draft,
            ignoreResponseOnCancelled: true
        ) { [weak self] response in
            guard let self = self else { return }

            self.ongoingEndpoint = nil

            switch response {
            case .success(let list):
                self.assets = list.results

                self.deliverContentSnapshot()
            case .failure(let apiError, let hipAPIError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipAPIError
                )
                self.deliverErrorSnapshot(error)
            }
        }
    }

    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension SelectSwapPoolAssetDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
        }
    }

    private func updateAccountIfNeeded() {
        let updatedAccount = sharedDataController.accountCollection[account.address]

        guard let account = updatedAccount else { return }

        if !account.isAvailable { return }

        self.account = account.value
    }
}

extension SelectSwapPoolAssetDataController {
    private func deliverLoadingSnapshot() {
        deliverUpdates() {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [
                    .empty(.loading("1")),
                    .empty(.loading("2"))
                ],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverUpdates() {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            let viewModel = SelectAssetNoContentItemViewModel()
            snapshot.appendItems(
                [.empty(.noContent(viewModel))],
                toSection: .empty
            )
            return snapshot
        }
    }
    
    private func deliverContentSnapshot() {
        if assets.isEmpty {
            deliverNoContentSnapshot()
            return
        }

        deliverUpdates() {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            let currency = self.sharedDataController.currency
            let currencyFormatter = self.currecyFormatter

            var snapshot = Snapshot()
            snapshot.appendSections([.assets])

            let selectAssetItems: [SelectAssetItem] = self.assets.map {
                assetDecoration in
                
                let asset: Asset
                if let assetInTheAccount = self.account[assetDecoration.id] {
                    asset = assetInTheAccount
                } else {
                    if assetDecoration.isCollectible {
                        asset = CollectibleAsset(decoration: assetDecoration)
                    } else {
                        asset = StandardAsset(decoration: assetDecoration)
                    }
                }

                let assetItem = AssetItem(
                    asset: asset,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let listItem = SelectAssetListItem(item: assetItem, account: self.account)
                return SelectAssetItem.asset(listItem)
            }
            snapshot.appendItems(
                selectAssetItems,
                toSection: .assets
            )

            return snapshot
        }
    }

    private func deliverErrorSnapshot(
        _ error: SelectAssetDataController.Error
    ) {
        deliverUpdates(error: error) {
            var snapshot = Snapshot()
            snapshot.appendSections([.error])
            let viewModel = SelectAssetErrorItemViewModel()
            snapshot.appendItems(
                [.error(viewModel)],
                toSection: .error
            )
            return snapshot
        }
    }

    private func deliverUpdates(
        error: SelectAssetDataController.Error? = nil,
        _ snapshot: @escaping () -> Snapshot
    ) {
        updatesQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()
            self.lastSnapshot = newSnapshot
            let updates = (snapshot: newSnapshot, error: error)
            let event = SelectAssetDataControllerEvent.didUpdate(updates)

            self.publish(event)
        }
    }
}

extension SelectSwapPoolAssetDataController {
    private func publish(
        _ event: SelectAssetDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
