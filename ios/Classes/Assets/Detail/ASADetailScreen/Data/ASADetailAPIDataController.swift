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

//   ASADetailAPIDataController.swift

import Foundation
import MagpieHipo

final class ASADetailScreenAPIDataController:
    ASADetailScreenDataController,
    SharedDataControllerObserver {
    var eventHandler: EventHandler?

    private(set) var configuration: ASADetailScreenConfiguration

    private(set) var account: Account {
        didSet { publishEventWhenAccountDidUpdate(oldAccount: oldValue) }
    }

    private(set) var asset: Asset

    private var assetDetail: AssetDecoration?

    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    init(
        account: Account,
        asset: Asset,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        configuration: ASADetailScreenConfiguration?
    ) {
        self.account = account
        self.asset = asset
        self.api = api
        self.sharedDataController = sharedDataController

        lazy var defaultConfiguration = ASADetailScreenConfiguration(
            shouldDisplayAccountActionsBarButtonItem: true,
            shouldDisplayQuickActions: !account.authorization.isWatch
        )
        self.configuration = configuration ?? defaultConfiguration
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension ASADetailScreenAPIDataController {
    func loadData() {
        if asset.isAlgo {
            didLoadData()
            return
        }

        eventHandler?(.willLoadData)

        let draft = AssetDetailFetchDraft(id: asset.id)
        api.fetchAssetDetail(draft) {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let newAssetDetail):
                let algAsset = ALGAsset(asset: self.asset)
                self.asset = StandardAsset(asset: algAsset, decoration: newAssetDetail)
                self.assetDetail = newAssetDetail

                self.didLoadData()
            case .failure(let apiError, let apiErrorDetail):
                self.assetDetail = nil
                self.sharedDataController.remove(self)

                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                self.eventHandler?(.didFailToLoadData(error))
            }
        }
    }

    private func didLoadData() {
        self.eventHandler?(.didLoadData)
        self.sharedDataController.add(self)
    }
}

/// <mark>
/// SharedDataControllerObserver
extension ASADetailScreenAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            publishEventIfAssetDidUpdate()
        }
    }

    private func publishEventIfAssetDidUpdate() {
        let address = account.address

        guard let newAccount = sharedDataController.accountCollection[address] else { return }

        if !newAccount.isAvailable { return }

        if asset.isAlgo {
            publishEventIfAlgoAssetDidUpdate(newAccount.value)
        } else {
            publishEventIfStandardAssetDidUpdate(newAccount.value)
        }

        account = newAccount.value
    }

    private func publishEventIfAlgoAssetDidUpdate(_ newAccount: Account) {
        let newAsset = newAccount.algo

        if !isAssetUpdated(newAsset) { return }

        asset = newAsset
        eventHandler?(.didLoadData)
    }

    private func publishEventIfStandardAssetDidUpdate(_ newAccount: Account) {
        guard let newAsset = newAccount[asset.id] else { return }

        guard let assetDetail = assetDetail else { return }

        if !isAssetUpdated(newAsset) { return }

        let algAsset = ALGAsset(asset: newAsset)
        asset = StandardAsset(asset: algAsset, decoration: assetDetail)
        eventHandler?(.didLoadData)
    }

    private func isAssetUpdated(_ newAsset: Asset) -> Bool {
        return
            newAsset.decimalAmount != asset.decimalAmount ||
            newAsset.usdValue != asset.usdValue
    }
}

extension ASADetailScreenAPIDataController {
    private func publishEventWhenAccountDidUpdate(oldAccount: Account) {
        eventHandler?(.didUpdateAccount(old: oldAccount))
    }
}
