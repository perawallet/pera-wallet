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
//   ALGBlockProcessor.swift


import Foundation
import MagpieCore
import MagpieHipo

final class ALGBlockProcessor: BlockProcessor {
    typealias BlockRequest = () -> ALGBlockRequest
    
    private lazy var queue = ALGBlockOperationQueue()
    
    private var blockEventQueue: DispatchQueue?
    private var blockEventHandler: BlockEventHandler?

    private let blockRequest: BlockRequest
    private let blockCycle: BlockCycle
    private let api: ALGAPI
    private let blockCycleNotificationQueue = DispatchQueue(
        label: "pera.queue.blockCycle.notifications",
        qos: .default
    )
    
    init(
        blockRequest: @escaping BlockRequest,
        blockCycle: BlockCycle,
        api: ALGAPI
    ) {
        self.blockRequest = blockRequest
        self.blockCycle = blockCycle
        self.api = api
    }
}

extension ALGBlockProcessor {
    func notify(
        queue: DispatchQueue,
        execute handler: @escaping BlockEventHandler
    ) {
        blockEventQueue = queue
        blockEventHandler = handler
    }

    func start() {
        blockCycle.notify(queue: blockCycleNotificationQueue) {
            [weak self] in
            guard let self = self else { return }
            
            if !self.canProceedOnBlock() {
                return
            }
            
            let newBlockRequest = self.blockRequest()
            self.proceed(with: newBlockRequest)
        }
        blockCycle.startListening()
    }
    
    func stop() {
        blockCycle.stopListening()
        queue.cancelAllOperations()
    }
    
    func cancel() {
        blockCycle.cancelListening()
        queue.cancelAllOperations()
    }
}

extension ALGBlockProcessor {
    private func canProceedOnBlock() -> Bool {
        return queue.isAvailable
    }
    
    private func proceed(
        with newBlockRequest: ALGBlockRequest
    ) {        
        publish(blockEvent: .willStart)
        
        var currencyFetchOperation: CurrencyRefreshOperation?

        if newBlockRequest.cachedCurrency.isExpired {
            let aCurrencyFetchOperation = CurrencyRefreshOperation(
                cachedCurrency: newBlockRequest.cachedCurrency,
                api: api
            )
            queue.enqueue(aCurrencyFetchOperation)
            
            currencyFetchOperation = aCurrencyFetchOperation
        }

        newBlockRequest.localAccounts.forEach { localAccount in
            publish(blockEvent: .willFetchAccount(localAccount))

            let accountFetchOperationInput = AccountDetailFetchOperation.Input(
                localAccount: localAccount
            )
            let accountFetchOperation = AccountDetailFetchOperation(
                input: accountFetchOperationInput,
                api: api
            )
            let assetDetailGroupFetchOperationInput = AssetDetailGroupFetchOperation.Input()
            let assetDetailGroupFetchOperation = AssetDetailGroupFetchOperation(
                input: assetDetailGroupFetchOperationInput,
                api: api
            )
            let adapterOperation = BlockOperation {
                [
                    weak self,
                    unowned accountFetchOperation,
                    unowned assetDetailGroupFetchOperation
                ] in
                guard let self = self else { return }
                
                var input = AssetDetailGroupFetchOperation.Input()
                
                switch accountFetchOperation.result {
                case .success(let output):
                    let account = output.account
                    
                    self.publish(blockEvent: .didFetchAccount(account))
                    
                    input.account = account
                    input.cachedAccounts = newBlockRequest.cachedAccounts
                    input.cachedAssetDetails = newBlockRequest.cachedAssetDetails
                    input.blockchainRequests = newBlockRequest.blockchainRequests[account.address] ?? .init()
                    
                    self.publish(blockEvent: .willFetchAssetDetails(account))
                case .failure(let error):
                    self.publish(
                        blockEvent: .didFailToFetchAccount(
                            localAccount: accountFetchOperation.input.localAccount,
                            error: error
                        )
                    )
                    
                    input.error = error
                }
                
                assetDetailGroupFetchOperation.input = input
            }
            let finishOperation = BlockOperation {
                [weak self, unowned assetDetailGroupFetchOperation] in
                guard let self = self else { return }
                
                switch assetDetailGroupFetchOperation.result {
                case .success(let output):
                    self.publish(
                        blockEvent: .didFetchAssetDetails(
                            account: output.account,
                            assetDetails: output.newAssetDetails,
                            blockchainUpdates: output.blockchainUpdates
                        )
                    )
                case .failure(let error):
                    if let account = assetDetailGroupFetchOperation.input.account {
                        self.publish(
                            blockEvent: .didFailToFetchAssetDetails(
                                account: account,
                                error: error
                            )
                        )
                    }
                }
                
                self.queue.dequeueOperations(forAccountAddress: localAccount.address)
            }
            
            finishOperation.addDependency(assetDetailGroupFetchOperation)
            assetDetailGroupFetchOperation.addDependency(adapterOperation)
            adapterOperation.addDependency(accountFetchOperation)
            
            if let currencyFetchOperation = currencyFetchOperation {
                accountFetchOperation.addDependency(currencyFetchOperation)
            }
            
            let operations = [
                accountFetchOperation,
                adapterOperation,
                assetDetailGroupFetchOperation,
                finishOperation
            ]
            
            queue.enqueue(
                operations,
                forAccountAddress: localAccount.address
            )
        }
        
        queue.addBarrier { [weak self] in
            guard let self = self else { return }
            self.publish(blockEvent: .didFinish)
        }
    }
}

extension ALGBlockProcessor {
    private func publish(
        blockEvent event: BlockEvent
    ) {
        blockEventQueue?.async { [weak self] in
            guard let self = self else { return }
            self.blockEventHandler?(event)
        }
    }
}
