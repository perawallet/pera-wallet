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

//   CollectibleDetailAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class CollectibleDetailAPIDataController: CollectibleDetailDataController {

    var eventHandler: ((CollectibleDetailDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(label: Constants.DispatchQueues.collectibleDetailSnapshot)

    private var ongoingEndpoint: EndpointOperatable?

    private let api: ALGAPI
    private var asset: CollectibleAsset
    private let account: Account
    private let quickAction: AssetQuickAction?
    private let sharedDataController: SharedDataController

    init(
        api: ALGAPI,
        asset: CollectibleAsset,
        account: Account,
        quickAction: AssetQuickAction?,
        sharedDataController: SharedDataController
    ) {
        self.api = api
        self.asset = asset
        self.account = account
        self.quickAction = quickAction
        self.sharedDataController = sharedDataController
    }
}

extension CollectibleDetailAPIDataController {
    func load() {
        deliverLoadingSnapshot()
        fetchAssetDetails()
    }

    func retry() {
        fetchAssetDetails()
    }

    private func fetchAssetDetails() {
        cancelOngoingEndpoint()

        ongoingEndpoint = api.fetchAssetDetail(
            AssetDetailFetchDraft(id: asset.id),
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let asset):
                self.asset = CollectibleAsset(
                    asset: ALGAsset(asset: self.asset),
                    decoration: asset
                )

                self.eventHandler?(.didFetch(self.asset))
                self.deliverContentSnapshot()
            case .failure(let error, _):
                var message: String

                if let statusCode = (error as? HTTPError)?.statusCode {
                    message = String(statusCode)
                } else {
                    message = error.description
                }

                self.eventHandler?(.didResponseFail(message: message))
            }
        }
    }

    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension CollectibleDetailAPIDataController {
    func hasOptedIn() -> OptInStatus {
        return sharedDataController.hasOptedIn(
            assetID: asset.id,
            for: account
        )
    }

    func hasOptedOut() -> OptOutStatus {
        return sharedDataController.hasOptedOut(
            assetID: asset.id,
            for: account
        )
    }
}

extension CollectibleDetailAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [.loading],
                toSection: .loading
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()

            self.addMediaContent(&snapshot)
            self.addActionContentIfNeeded(&snapshot)
            self.addDescriptionContent(&snapshot)
            self.addPropertiesContent(&snapshot)

            return snapshot
        }
    }

    private func addMediaContent(
        _ snapshot: inout Snapshot
    ) {
        var mediaItems: [CollectibleDetailItem] = [.media(asset)]

        if let asset = account[asset.id] as? CollectibleAsset {
            if !asset.isOwned {
                mediaItems.append(
                    .error(
                        CollectibleMediaErrorViewModel(
                            .notOwner(isWatchAccount: account.isWatchAccount())
                        )
                    )
                )
            } else if !asset.mediaType.isSupported {
                mediaItems.append(
                    .error(
                        CollectibleMediaErrorViewModel(
                            .unsupported
                        )
                    )
                )
            }
        }

        snapshot.appendSections([.media])
        snapshot.appendItems(
            mediaItems,
            toSection: .media
        )
    }

    private func addActionContentIfNeeded(
        _ snapshot: inout Snapshot
    ) {
        if quickAction != nil {
            addWatchAccountActionContent(&snapshot)
            return
        }

        if account.isWatchAccount() {
            addWatchAccountActionContent(&snapshot)
            return
        }

        if asset.isOwned {
            addStandardActionContent(&snapshot)
            return
        }

        /// <note>: Creators cannot opt-out from the asset.
        if asset.creator?.address == account.address {
            addCreatorAccountActionContent(&snapshot)
            return
        }

        if account[asset.id] != nil {
            addOptedInActionContent(&snapshot)
        }
    }

    private func addWatchAccountActionContent(
        _ snapshot: inout Snapshot
    ) {
        let actionItem: [CollectibleDetailItem] = [
            .watchAccountAction(
                CollectibleDetailActionViewModel(
                    asset: asset,
                    account: account
                )
            )
        ]

        snapshot.appendSections([.action])
        snapshot.appendItems(
            actionItem,
            toSection: .action
        )
    }

    private func addCreatorAccountActionContent(
        _ snapshot: inout Snapshot
    ) {
        let actionItem: [CollectibleDetailItem] = [
            .collectibleCreatorAccountAction(
                CollectibleDetailActionViewModel(
                    asset: asset,
                    account: account
                )
            )
        ]

        snapshot.appendSections([.action])
        snapshot.appendItems(
            actionItem,
            toSection: .action
        )
    }

    private func addStandardActionContent(
        _ snapshot: inout Snapshot
    ) {
        let actionItem: [CollectibleDetailItem] = [
            .action(
                CollectibleDetailActionViewModel(
                    asset: asset,
                    account: account
                )
            )
        ]

        snapshot.appendSections([.action])
        snapshot.appendItems(
            actionItem,
            toSection: .action
        )
    }

    private func addOptedInActionContent(
        _ snapshot: inout Snapshot
    ) {
        let actionItem: [CollectibleDetailItem] = [
            .optedInAction(
                CollectibleDetailOptedInActionViewModel(
                    asset: asset,
                    account: account
                )
            )
        ]

        snapshot.appendSections([.action])
        snapshot.appendItems(
            actionItem,
            toSection: .action
        )
    }

    private func addDescriptionContent(
        _ snapshot: inout Snapshot
    ) {
        var descriptionItems: [CollectibleDetailItem] = []

        if !asset.description.isNilOrEmpty {
            descriptionItems.append(
                .description(
                    CollectibleDescriptionViewModel(
                        asset
                    )
                )
            )
        }

        if let asset = account[asset.id] as? CollectibleAsset,
           asset.isOwned {
            descriptionItems.append(
                .information(
                    CollectibleTransactionInformation(
                        icon: .account(account),
                        title: "collectible-detail-owner".localized,
                        value: account.name.fallback(account.address.shortAddressDisplay),
                        isCollectibleSpecificValue: false
                    )
                )
            )
        }

        descriptionItems.append(
            .assetID(
                CollectibleDetailAssetIDItemIdentifier(viewModel: CollectibleDetailAssetIDItemViewModel(asset: asset))
            )
        )

        if let collectionName = asset.collectionName,
           !collectionName.isEmpty {
            descriptionItems.append(
                .information(
                    CollectibleTransactionInformation(
                        icon: nil,
                        title: "collectible-detail-collection-name".localized,
                        value: collectionName,
                        isCollectibleSpecificValue: true
                    )
                )
            )
        }

        if let creator = asset.creator?.address {
            let source = AlgoExplorerExternalSource(address: creator, network: api.network)

            descriptionItems.append(
                .information(
                    CollectibleTransactionInformation(
                        icon: nil,
                        title: "collectible-detail-creator-address".localized,
                        value: creator.shortAddressDisplay,
                        isCollectibleSpecificValue: true,
                        actionURL: source.url
                    )
                )
            )
        }

        descriptionItems.append(
            .information(
                CollectibleTransactionInformation(
                    icon: .custom(img("icon-pera-logo")),
                    title: "collectible-detail-show-on".localized,
                    value: "collectible-detail-pera-explorer".localized,
                    isCollectibleSpecificValue: true,
                    actionURL: asset.explorerURL
                )
            )
        )

        snapshot.appendSections([.description])
        snapshot.appendItems(
            descriptionItems,
            toSection: .description
        )
    }

    private func addPropertiesContent(
        _ snapshot: inout Snapshot
    ) {
        if let properties = asset.properties,
           !properties.isEmpty {
            let propertyItems: [CollectibleDetailItem] = properties.map { .properties(CollectiblePropertyViewModel($0)) }

            snapshot.appendSections([.properties])
            snapshot.appendItems(
                propertyItems,
                toSection: .properties
            )
        }
    }

    private func addExternalSourcesContent(
        _ snapshot: inout Snapshot
    ) {
        var externalSourceItems: [CollectibleDetailItem] = [
            .external(
                CollectibleExternalSourceViewModel(
                    AlgoExplorerExternalSource(
                        asset: asset.id,
                        network: api.network
                    )
                )
            )
        ]

        if !api.isTestNet {
            externalSourceItems.append(
                .external(
                    CollectibleExternalSourceViewModel(
                        NFTExplorerExternalSource(
                            asset: asset.id,
                            network: api.network
                        )
                    )
                )
            )
        }

        snapshot.appendSections([.external])
        snapshot.appendItems(
            externalSourceItems,
            toSection: .external
        )
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension CollectibleDetailAPIDataController {
    private func publish(
        _ event: CollectibleDetailDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
