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

//   SwapAssetAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class SwapAssetAPIDataController:
    SwapAssetDataController,
    SharedDataControllerObserver {
    typealias DataStore = SwapMutableAmountPercentageStore

    var eventHandler: EventHandler?

    var account: Account {
        get {
            return swapController.account
        }
        set {
            swapController.account = newValue
        }
    }
    var userAsset: Asset {
        get {
            return swapController.userAsset
        }
        set {
            swapController.userAsset = newValue
        }
    }
    var poolAsset: Asset? {
        get {
            return swapController.poolAsset
        }

        set {
            swapController.poolAsset = newValue
        }
    }

    private var quote: SwapQuote? {
        return swapController.quote
    }
    private var providers: [SwapProvider] {
        return swapController.providers
    }
    private var swapType: SwapType {
        return swapController.swapType
    }

    private var currentQuoteEndpoint: EndpointOperatable?
    private lazy var quoteThrottler = Throttler(intervalInSeconds: 0.8)

    private var swapController: SwapController

    private let dataStore: DataStore
    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    init(
        dataStore: DataStore,
        swapController: SwapController,
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.dataStore = dataStore
        self.swapController = swapController
        self.api = api
        self.sharedDataController = sharedDataController

        sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension SwapAssetAPIDataController {
    func loadQuote(
        swapAmount: UInt64
    ) {
        guard let deviceID = api.session.authenticatedUser?.getDeviceId(on: api.network),
              let poolAssetID = poolAsset?.id else {
            return
        }

        let draft = SwapQuoteDraft(
            providers: providers,
            swapperAddress: account.address,
            type: swapType,
            deviceID: deviceID,
            assetInID: userAsset.id,
            assetOutID: poolAssetID,
            amount: swapAmount,
            slippage: swapController.slippage
        )

        eventHandler?(.willLoadQuote)

        if currentQuoteEndpoint != nil {
            cancelLoadingQuote()
        }
        
        quoteThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.loadData(draft)
        }
    }

    private func loadData(
        _ draft: SwapQuoteDraft
    ) {
        currentQuoteEndpoint = api.getSwapQuote(draft) {
            [weak self] response in
            guard let self = self else { return }

            self.currentQuoteEndpoint = nil

            switch response {
            case .success(let quoteList):
                guard let quote = quoteList.results[safe: 0] else { return }

                self.swapController.quote = quote
                self.eventHandler?(.didLoadQuote(quote))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                self.eventHandler?(.didFailToLoadQuote(error))
            }
        }
    }

    func cancelLoadingQuote() {
        cancelOngoingRequest()
        quoteThrottler.cancelAll()
    }

    private func cancelOngoingRequest() {
        currentQuoteEndpoint?.cancel()
        currentQuoteEndpoint = nil
    }
}

extension SwapAssetAPIDataController {
    func saveAmountPercentage(_ percentage: SwapAmountPercentage?) {
        dataStore.amountPercentage = percentage
    }
}

extension SwapAssetAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
        }
    }

    private func updateAccountIfNeeded() {
        guard let updatedAccount = sharedDataController.accountCollection[account.address] else {
            return
        }

        if !updatedAccount.isAvailable { return }

        self.account = updatedAccount.value
    }
}
