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

    var selectedAccountSortingAlgorithm: AccountSortingAlgorithm? {
        didSet { cache.accountSortingAlgorithmName = selectedAccountSortingAlgorithm?.name }
    }
    var selectedCollectibleSortingAlgorithm: CollectibleSortingAlgorithm? {
        didSet { cache.collectibleSortingAlgorithmName = selectedCollectibleSortingAlgorithm?.name }
    }
    var selectedAccountAssetSortingAlgorithm: AccountAssetSortingAlgorithm? {
        didSet { cache.accountAssetSortingAlgorithmName = selectedAccountAssetSortingAlgorithm?.name }
    }

    private(set) var accountCollection: AccountCollection = []

    private(set) var currency: CurrencyProvider

    private(set) var lastRound: BlockRound?

    private(set) lazy var accountSortingAlgorithms: [AccountSortingAlgorithm] = [
        AccountAscendingTitleAlgorithm(),
        AccountDescendingTitleAlgorithm(),
        AccountAscendingTotalPortfolioValueAlgorithm(currency: currency),
        AccountDescendingTotalPortfolioValueAlgorithm(currency: currency),
        AccountCustomReorderingAlgorithm()
    ]

    private(set) lazy var collectibleSortingAlgorithms: [CollectibleSortingAlgorithm] = [
        CollectibleDescendingOptedInRoundAlgorithm(),
        CollectibleAscendingOptedInRoundAlgorithm(),
        CollectibleAscendingTitleAlgorithm(),
        CollectibleDescendingTitleAlgorithm()
    ]

    private(set) lazy var accountAssetSortingAlgorithms: [AccountAssetSortingAlgorithm] = [
        AccountAssetAscendingTitleAlgorithm(),
        AccountAssetDescendingTitleAlgorithm(),
        AccountAssetDescendingAmountAlgorithm(),
        AccountAssetAscendingAmountAlgorithm()
    ]
    
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
    private let cache: Cache

    init(
        currency: CurrencyProvider,
        session: Session,
        api: ALGAPI
    ) {
        let cache = Cache()

        self.currency = currency
        self.session = session
        self.api = api
        self.cache = Cache()

        self.selectedAccountSortingAlgorithm = accountSortingAlgorithms.first {
            $0.name == cache.accountSortingAlgorithmName
        } ?? AccountCustomReorderingAlgorithm()

        self.selectedCollectibleSortingAlgorithm = collectibleSortingAlgorithms.first {
            $0.name == cache.collectibleSortingAlgorithmName
        } ?? CollectibleDescendingOptedInRoundAlgorithm()

        self.selectedAccountAssetSortingAlgorithm = accountAssetSortingAlgorithms.first {
            $0.name == cache.accountAssetSortingAlgorithmName
        } ?? AccountAssetAscendingTitleAlgorithm()
    }
}

extension SharedAPIDataController {
    func startPolling() {
        $status.mutate { $0 = .running }
        blockProcessor.start()
    }
    
    func stopPolling() {
        $status.mutate { $0 = .suspended }
        blockProcessor.stop()
    }
    
    func resetPolling() {
        $status.mutate { $0 = .suspended }
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

        session.removePrivateData(for: address)

        accountCollection[address] = nil
        
        startPolling()
    }

    func resetPollingAfterPreferredCurrencyWasChanged() {
        resetPolling()
    }
}

extension SharedAPIDataController {
    func getPreferredOrderForNewAccount() -> Int {
        let localAccounts = session.authenticatedUser?.accounts ?? []
        let lastLocalAccount = localAccounts.max { $0.preferredOrder < $1.preferredOrder }
        return lastLocalAccount.unwrap { $0.preferredOrder + 1 } ?? 0
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
            return ALGBlockRequest(
                localAccounts: self.session.authenticatedUser?.accounts ?? [],
                cachedAccounts: self.accountCollection,
                cachedAssetDetails: self.assetDetailCollection,
                cachedCurrency: self.currency
            )
        }
        let cycle = ALGBlockCycle(api: api)
        let processor = ALGBlockProcessor(blockRequest: request, blockCycle: cycle, api: api)
        
        processor.notify(queue: blockProcessorEventQueue) {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .willStart(let round):
                self.blockProcessorWillStart(for: round)
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
        $status.mutate { $0 = .running }
        
        lastRound = round
        nextAccountCollection = []
        
        publish(.didStartRunning(first: !isFirstPollingRoundCompleted))
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
        _ assetDetails: [AssetID: AssetDecoration],
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
        
        $isFirstPollingRoundCompleted.mutate { $0 = true }

        if status != .running {
            return
        }

        $status.mutate { $0 = .completed }
        
        publish(.didFinishRunning)
    }
    
    private func blockDidReset() {
        lastRound = nil
        
        $isFirstPollingRoundCompleted.mutate { $0 = false }
        $status.mutate { $0 = .idle }
        
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
    private final class Cache: Storable {
        typealias Object = Any

        var accountSortingAlgorithmName: String? {
            get { userDefaults.string(forKey: accountSortingAlgorithmNameKey) }
            set {
                userDefaults.set(newValue, forKey: accountSortingAlgorithmNameKey)
                userDefaults.synchronize()
            }
        }

        var collectibleSortingAlgorithmName: String? {
            get { userDefaults.string(forKey: collectibleSortingAlgorithmNameKey) }
            set {
                userDefaults.set(newValue, forKey: collectibleSortingAlgorithmNameKey)
                userDefaults.synchronize()
            }
        }

        var accountAssetSortingAlgorithmName: String? {
            get { userDefaults.string(forKey: accountAssetSortingAlgorithmNameKey) }
            set {
                userDefaults.set(newValue, forKey: accountAssetSortingAlgorithmNameKey)
                userDefaults.synchronize()
            }
        }

        private let accountSortingAlgorithmNameKey = "cache.key.accountSortingAlgorithmName"
        private let collectibleSortingAlgorithmNameKey = "cache.key.collectibleSortingAlgorithmName"
        private let accountAssetSortingAlgorithmNameKey = "cache.key.accountAssetSortingAlgorithmName"
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
