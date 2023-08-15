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

    private(set) var blockchainUpdatesMonitor: BlockchainUpdatesMonitor = .init()

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
        AccountAssetDescendingAmountAlgorithm(currency: currency),
        AccountAssetAscendingAmountAlgorithm(currency: currency)
    ]

    private lazy var deviceRegistrationController = DeviceRegistrationController(
        target: target,
        session: session,
        api: api
    )

    private lazy var accountAuthorizationDeterminer = AccountAuthorizationDeterminer(session: session)
    
    var isAvailable: Bool {
        return isFirstPollingRoundCompleted
    }
    var isPollingAvailable: Bool {
        return session.authenticatedUser.unwrap { !$0.accounts.isEmpty } ?? false
    }

    private lazy var blockProcessor = createBlockProcessor()
    private lazy var blockProcessorEventQueue = DispatchQueue(
        label: "pera.queue.blockProcessor.events",
        qos: .userInitiated
    )
    
    private var nextAccountCollection: AccountCollection = []

    private var transactionParamsResult: Result<TransactionParams, HIPNetworkError<NoAPIModel>>?
    
    @Atomic(identifier: "sharedAPIDataController.status")
    private var status: Status = .idle
    @Atomic(identifier: "sharedAPIDataController.isFirstPollingRoundCompleted")
    private var isFirstPollingRoundCompleted = false
    
    private let target: ALGAppTarget
    private let session: Session
    private let api: ALGAPI
    private let cache: Cache

    init(
        target: ALGAppTarget,
        currency: CurrencyProvider,
        session: Session,
        api: ALGAPI
    ) {
        let cache = Cache()

        self.target = target
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
    private func fetchTransactionParams(
        _ handler: ((Result<TransactionParams, HIPNetworkError<NoAPIModel>>) -> Void)? = nil
    ) {
        api.getTransactionParams {
            [weak self] response in
            guard let self else {
                return
            }

            switch response {
            case .success(let transactionParams):
                self.transactionParamsResult = .success(transactionParams)
                handler?(.success(transactionParams))
            case .failure(let apiError, let apiErrorDetail):
                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                self.transactionParamsResult = .failure(error)
                handler?(.failure(error))
            }
        }
    }

    func getTransactionParams(
        isCacheEnabled: Bool,
        _ handler: @escaping (Result<TransactionParams, HIPNetworkError<NoAPIModel>>) -> Void
    ) {
        if isCacheEnabled, let transactionParamsResult = transactionParamsResult {
            switch transactionParamsResult {
            case .success:
                handler(transactionParamsResult)
                fetchTransactionParams()
            case .failure:
                fetchTransactionParams(handler)
            }

            return
        }

        fetchTransactionParams(handler)
    }

    func getTransactionParams(_ handler: @escaping (Result<TransactionParams, HIPNetworkError<NoAPIModel>>) -> Void) {
        getTransactionParams(isCacheEnabled: false, handler)
    }
}

extension SharedAPIDataController {
    func startPolling() {
        $status.mutate { $0 = .running }
        blockProcessor.start()

        fetchTransactionParams { result in
            switch result {
            case .success(let params):
                self.transactionParamsResult = .success(params)
            case .failure(let error):
                self.transactionParamsResult = .failure(error)
            }
        }
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

        deviceRegistrationController.sendDeviceDetails()

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
    func hasOptedIn(
        assetID: AssetID,
        for account: Account
    ) -> OptInStatus {
        let hasPendingOptedIn = blockchainUpdatesMonitor.hasPendingOptInRequest(
            assetID: assetID,
            for: account
        )
        let hasAlreadyOptedIn = account.isOptedIn(to: assetID)

        switch (hasPendingOptedIn, hasAlreadyOptedIn) {
        case (true, false): return .pending
        case (true, true): return .optedIn
        case (false, true): return .optedIn
        case (false, false): return .rejected
        }
    }

    func hasOptedOut(
        assetID: AssetID,
        for account: Account
    ) -> OptOutStatus {
        let hasPendingOptedOut = blockchainUpdatesMonitor.hasPendingOptOutRequest(
            assetID: assetID,
            for: account
        )
        let hasAlreadyOptedOut = account[assetID] == nil

        switch (hasPendingOptedOut, hasAlreadyOptedOut) {
        case (true, false): return .pending
        case (true, true): return .optedOut
        case (false, true): return .optedOut
        case (false, false): return .rejected
        }
    }
}

extension SharedAPIDataController {
    func rekeyedAccounts(
        of account: Account
    ) -> [AccountHandle] {
        return accountCollection.rekeyedAccounts(of: account.address)
    }

    func authAccount(
        of account: Account
    ) -> AccountHandle? {
        guard let authAddress = account.authAddress else {
            return nil
        }
        return accountCollection[authAddress]
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
                cachedCurrency: self.currency,
                blockchainRequests: self.blockchainUpdatesMonitor.makeBatchRequest()
            )
        }
        let cycle = ALGBlockCycle(api: api)
        let processor = ALGBlockProcessor(blockRequest: request, blockCycle: cycle, api: api)
        
        processor.notify(queue: blockProcessorEventQueue) {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .willStart:
                self.blockProcessorWillStart()
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
            case .didFetchAssetDetails(let account, let assetDetails, let blockchainUpdates):
                self.blockProcessorDidFetchAssetDetails(
                    assetDetails: assetDetails,
                    blockchainUpdates: blockchainUpdates,
                    for: account
                )
            case .didFailToFetchAssetDetails(let account, let error):
                self.blockProcessorDidFailToFetchAssetDetails(
                    error,
                    for: account
                )
            case .didFinish:
                self.blockProcessorDidFinish()
            }
        }
        
        return processor
    }
    
    private func blockProcessorWillStart() {
        $status.mutate { $0 = .running }

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
        assetDetails: [AssetID: AssetDecoration],
        blockchainUpdates: BlockchainAccountBatchUpdates,
        for account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .ready)
        nextAccountCollection[account.address] = updatedAccount

        for assetDetail in assetDetails {
            assetDetailCollection[assetDetail.key] = assetDetail.value
        }

        for assetID in blockchainUpdates.optedInAssets {
            blockchainUpdatesMonitor.markOptInUpdatesForNotification(
                forAssetID: assetID,
                for: account
            )
        }

        for assetID in blockchainUpdates.optedOutAssets {
            blockchainUpdatesMonitor.markOptOutUpdatesForNotification(
                forAssetID: assetID,
                for: account
            )
        }

        for assetID in blockchainUpdates.sentPureCollectibleAssets {
            blockchainUpdatesMonitor.markSendPureCollectibleAssetUpdatesForNotification(
                forAssetID: assetID,
                for: account
            )
        }
    }
    
    private func blockProcessorDidFailToFetchAssetDetails(
        _ error: HIPNetworkError<NoAPIModel>,
        for account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .failed(error))
        nextAccountCollection[account.address] = updatedAccount
    }
    
    private func blockProcessorDidFinish() {
        setAccountsAuthorizationWhenBlockProcessorDidFinish()

        accountCollection = nextAccountCollection
        nextAccountCollection = []

        $isFirstPollingRoundCompleted.mutate { $0 = true }

        blockchainUpdatesMonitor.removeCompletedUpdates()

        if status != .running {
            return
        }

        $status.mutate { $0 = .completed }
        
        publish(.didFinishRunning)
    }
    
    private func blockDidReset() {
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
            set { userDefaults.set(newValue, forKey: accountSortingAlgorithmNameKey) }
        }

        var collectibleSortingAlgorithmName: String? {
            get { userDefaults.string(forKey: collectibleSortingAlgorithmNameKey) }
            set { userDefaults.set(newValue, forKey: collectibleSortingAlgorithmNameKey) }
        }

        var accountAssetSortingAlgorithmName: String? {
            get { userDefaults.string(forKey: accountAssetSortingAlgorithmNameKey) }
            set { userDefaults.set(newValue, forKey: accountAssetSortingAlgorithmNameKey) }
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

extension SharedAPIDataController {
    private func setAccountsAuthorizationWhenBlockProcessorDidFinish() {
        nextAccountCollection.forEach { accountHandle in
            let aRawAccount = accountHandle.value
            aRawAccount.authorization = determineAccountAuthorization(of: aRawAccount)
        }
    }

    func determineAccountAuthorization(of account: Account) -> AccountAuthorization {
        accountAuthorizationDeterminer.determineAccountAuthorization(
            of: account,
            with: nextAccountCollection
        )
    }
}
