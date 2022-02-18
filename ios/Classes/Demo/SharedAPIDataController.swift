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
//   SharedAPIDataController.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class SharedAPIDataController:
    SharedDataController,
    WeakPublisher {
    var observations: [ObjectIdentifier: WeakObservation] = [:]

    var assetDetailCollection: AssetDetailCollection = []

    private(set) var accountCollection: AccountCollection = []
    private(set) var currency: CurrencyHandle = .idle

    private(set) var lastRound: BlockRound?
    
    var isAvailable: Bool {
        return isFirstPollingRoundCompleted
    }
    var isPollingAvailable: Bool {
        return session.authenticatedUser.unwrap { !$0.accounts.isEmpty } ?? false
    }

    private lazy var blockProcessor = createBlockProcessor()
    private lazy var blockProcessorEventQueue =
        DispatchQueue(label: "com.algorand.queue.blockProcessor.events")
    
    private var nextAccountCollection: AccountCollection = []
    
    @Atomic(identifier: "sharedAPIDataController.status")
    private var status: Status = .idle
    @Atomic(identifier: "sharedAPIDataController.isFirstPollingRoundCompleted")
    private var isFirstPollingRoundCompleted = false
    
    private let session: Session
    private let api: ALGAPI
    
    init(
        session: Session,
        api: ALGAPI
    ) {
        self.session = session
        self.api = api
    }
}

extension SharedAPIDataController {
    func startPolling() {
        $status.modify { $0 = .running }
        blockProcessor.start()
    }
    
    func stopPolling() {
        $status.modify { $0 = .suspended }
        blockProcessor.stop()
    }
    
    func resetPolling() {
        $status.modify { $0 = .suspended }
        blockProcessor.cancel()
        
        deleteData()
        blockDidReset()

        startPolling()
    }
    
    func resetPollingAfterRemoving(
        _ account: Account
    ) {
        stopPolling()
        
        let address = account.address
        
        if let localAccount = session.accountInformation(from: address) {
            session.authenticatedUser?.removeAccount(localAccount)
        }

        accountCollection[address] = nil
        
        startPolling()
    }

    func resetPollingAfterPreferredCurrencyWasChanged() {
        currency = .idle
        resetPolling()
    }
}

extension SharedAPIDataController {
    func add(
        _ observer: SharedDataControllerObserver
    ) {
        publishEventForCurrentStatus()
        
        let id = ObjectIdentifier(observer as AnyObject)
        observations[id] = WeakObservation(observer)
    }
}

extension SharedAPIDataController {
    private func deleteData() {
        accountCollection = []
        nextAccountCollection = []
        assetDetailCollection = []
    }
}

extension SharedAPIDataController {
    private func createBlockProcessor() -> BlockProcessor {
        let request: ALGBlockProcessor.BlockRequest = { [unowned self] in
            var request = ALGBlockRequest()
            request.localAccounts = self.session.authenticatedUser?.accounts ?? []
            /// <warning>
            request.cachedAccounts = self.accountCollection
            request.cachedAssetDetails = self.assetDetailCollection
            request.localCurrencyId = self.session.preferredCurrency
            request.cachedCurrency = self.currency
            return request
        }
        let cycle = ALGBlockCycle(api: api)
        let processor = ALGBlockProcessor(blockRequest: request, blockCycle: cycle, api: api)
        
        processor.notify(queue: blockProcessorEventQueue) {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .willStart(let round):
                self.blockProcessorWillStart(for: round)
            case .willFetchCurrency:
                self.blockProcessorWillFetchCurrency()
            case .didFetchCurrency(let currency):
                self.blockProcessorDidFetchCurrency(currency)
            case .didFailToFetchCurrency(let error):
                self.blockProcessorDidFailToFetchCurrency(error)
            case .willFetchAccount(let localAccount):
                self.blockProcessorWillFetchAccount(localAccount)
            case .didFetchAccount(let account):
                self.blockProcessorDidFetchAccount(account)
            case .didFailToFetchAccount(let localAccount, let error):
                self.blockProcessorDidFailToFetchAccount(
                    localAccount,
                    error
                )
            case .willFetchAssetDetails(let account):
                self.blockProcessorWillFetchAssetDetails(for: account)
            case .didFetchAssetDetails(let account, let assetDetails):
                self.blockProcessorDidFetchAssetDetails(
                    assetDetails,
                    for: account
                )
            case .didFailToFetchAssetDetails(let account, let error):
                self.blockProcessorDidFailToFetchAssetDetails(
                    error,
                    for: account
                )
            case .didFinish(let round):
                self.blockProcessorDidFinish(for: round)
            }
        }
        
        return processor
    }
    
    private func blockProcessorWillStart(
        for round: BlockRound?
    ) {
        $status.modify { $0 = .running }
        
        lastRound = round
        nextAccountCollection = []
        
        publish(.didStartRunning(first: !isFirstPollingRoundCompleted))
    }
    
    private func blockProcessorWillFetchCurrency() {}
    
    private func blockProcessorDidFetchCurrency(
        _ currencyValue: Currency
    ) {
        currency = .ready(currency: currencyValue, lastUpdateDate: Date())
    }
    
    private func blockProcessorDidFailToFetchCurrency(
        _ error: HIPNetworkError<NoAPIModel>
    ) {
        if currency.isAvailable {
            return
        }
        
        currency = .failed(error)
    }
    
    private func blockProcessorWillFetchAccount(
        _ localAccount: AccountInformation
    ) {
        let address = localAccount.address
        
        let account: Account
        if let cachedAccount = accountCollection[address] {
            account = cachedAccount.value
        } else {
            account = Account(localAccount: localAccount)
        }

        nextAccountCollection[address] = AccountHandle(account: account, status: .idle)
    }
    
    private func blockProcessorDidFetchAccount(
        _ account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .inProgress)
        nextAccountCollection[account.address] = updatedAccount
    }
    
    private func blockProcessorDidFailToFetchAccount(
        _ localAccount: AccountInformation,
        _ error: HIPNetworkError<NoAPIModel>
    ) {
        let address = localAccount.address

        let account: Account
        if let cachedAccount = accountCollection[address] {
            account = cachedAccount.value
        } else {
            account = Account(localAccount: localAccount)
        }
        
        nextAccountCollection[address] = AccountHandle(account: account, status: .failed(error))
    }
    
    private func blockProcessorWillFetchAssetDetails(
        for account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .inProgress)
        nextAccountCollection[account.address] = updatedAccount
    }
    
    private func blockProcessorDidFetchAssetDetails(
        _ assetDetails: [AssetID: AssetInformation],
        for account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .ready)
        nextAccountCollection[account.address] = updatedAccount
        
        if assetDetails.isEmpty {
            return
        }
        
        assetDetails.forEach {
            assetDetailCollection[$0.key] = $0.value
        }
    }
    
    private func blockProcessorDidFailToFetchAssetDetails(
        _ error: HIPNetworkError<NoAPIModel>,
        for account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .failed(error))
        nextAccountCollection[account.address] = updatedAccount
    }
    
    private func blockProcessorDidFinish(
        for round: BlockRound?
    ) {
        lastRound = round
        accountCollection = nextAccountCollection
        nextAccountCollection = []
        
        $isFirstPollingRoundCompleted.modify { $0 = true }

        if status != .running {
            return
        }

        $status.modify { $0 = .completed }
        
        publish(.didFinishRunning)
    }
    
    private func blockDidReset() {
        lastRound = nil
        
        $isFirstPollingRoundCompleted.modify { $0 = false }
        $status.modify { $0 = .idle }
        
        publish(.didBecomeIdle)
    }
}

extension SharedAPIDataController {
    private func publishEventForCurrentStatus() {
        switch status {
        case .idle: publish(.didBecomeIdle)
        case .running: publish(.didStartRunning(first: !isFirstPollingRoundCompleted))
        case .suspended: publish(isFirstPollingRoundCompleted ? .didFinishRunning : .didBecomeIdle)
        case .completed: publish(.didFinishRunning)
        }
    }
    
    private func publish(
        _ event: SharedDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            self.notifyObservers {
                $0.sharedDataController(
                    self,
                    didPublish: event
                )
            }
        }
    }
}

extension SharedAPIDataController {
    final class WeakObservation: WeakObservable {
        weak var observer: SharedDataControllerObserver?

        init(
            _ observer: SharedDataControllerObserver
        ) {
            self.observer = observer
        }
    }
}

extension SharedAPIDataController {
    private enum Status: Equatable {
        case idle
        case running
        case suspended
        case completed /// Waiting for the next polling cycle to be running
    }
}
