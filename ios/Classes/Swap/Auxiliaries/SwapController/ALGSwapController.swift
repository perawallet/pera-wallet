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

//   ALGSwapController.swift

import Foundation
import MacaroonUtils

final class ALGSwapController: SwapController {
    var eventHandler: EventHandler?

    var account: Account
    let swapType: SwapType = .fixedInput /// <note> Swap type won't change for now.
    let providers: [SwapProvider] = [.tinyman, .tinymanV2] /// <note> Only provider is Tinyman for now.

    var userAsset: Asset
    var quote: SwapQuote?
    var poolAsset: Asset?
    var slippage: Decimal = PresetSwapSlippageTolerancePercentage.defaultPercentage().value

    private(set) var parsedTransactions: [ParsedSwapTransaction] = []
    
    private lazy var uploadAndMonitorOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.algorad.swapTransactionUploadAndMonitorQueue"
        queue.qualityOfService = .userInitiated
        return queue
    }()

    private lazy var transactionMonitor = TransactionPoolMonitor(api: api)

    private let api: ALGAPI
    private let transactionSigner: SwapTransactionSigner

    private var signedTransactions: [Data] = []

    private lazy var swapTransactionGroupSigner = SwapTransactionGroupSigner(
        account: account,
        transactionSigner: transactionSigner
    )

    init(
        account: Account,
        userAsset: Asset,
        api: ALGAPI,
        transactionSigner: SwapTransactionSigner
    ) {
        self.account = account
        self.userAsset = userAsset
        self.api = api
        self.transactionSigner = transactionSigner
    }
}

extension ALGSwapController {
    func signTransactions(
        _ transactionGroups: [SwapTransactionGroup]
    ) {
        swapTransactionGroupSigner.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSignTransaction:
                self.publishEvent(.didSignTransaction)
            case .didCompleteSigningTransactions(let transactions):
                self.signedTransactions = transactions
                self.publishEvent(.didSignAllTransactions)
                self.uploadTransactions()
            case .didFailSigning(error: let error):
                self.publishEvent(.didFailSigning(error: error))
            case .didLedgerRequestUserApproval(let ledger):
                self.publishEvent(
                    .didLedgerRequestUserApproval(
                        ledger: ledger,
                        transactionGroups: transactionGroups
                    )
                )
            case .didFinishTiming:
                self.publishEvent(.didFinishTiming)
            case .didLedgerReset:
                self.publishEvent(.didLedgerReset)
            case .didLedgerRejectSigning:
                self.publishEvent(.didLedgerRejectSigning)
            }
        }

        parseTransactions(transactionGroups)
        swapTransactionGroupSigner.signTransactions(transactionGroups)
    }

    private func parseTransactions(
        _ transactionGroups: [SwapTransactionGroup]
    ) {
        let sdk = AlgorandSDK()

        var parsedSwapTransactions = [ParsedSwapTransaction]()

        for transactionGroup in transactionGroups where transactionGroup.transactions != nil {
            var paidTransactions = [SDKTransaction]()
            var receivedTransactions = [SDKTransaction]()
            var otherTransactions = [SDKTransaction]()

            for transaction in transactionGroup.transactions! {
                var error: NSError?
                guard let transactionData = sdk.msgpackToJSON(transaction, error: &error).data(using: .utf8),
                      let sdkTransaction = try? JSONDecoder().decode(SDKTransaction.self, from: transactionData) else {
                    continue
                }

                if sdkTransaction.sender == account.address {
                    paidTransactions.append(sdkTransaction)
                } else if sdkTransaction.receiver == account.address {
                    receivedTransactions.append(sdkTransaction)
                } else {
                    otherTransactions.append(sdkTransaction)
                }
            }

            let parsedSwapTransaction = ParsedSwapTransaction(
                purpose: transactionGroup.purpose,
                groupID: transactionGroup.groupID,
                paidTransactions: paidTransactions,
                receivedTransactions: receivedTransactions,
                otherTransactions: otherTransactions
            )

            parsedSwapTransactions.append(parsedSwapTransaction)
        }

        self.parsedTransactions = parsedSwapTransactions
    }

    func clearTransactions() {
        signedTransactions = []
        parsedTransactions = []
        swapTransactionGroupSigner.clearTransactions()
    }
}

extension ALGSwapController {
    func uploadTransactions() {
        uploadTransactionsAndWaitForConfirmation()
    }

    private func uploadTransactionsAndWaitForConfirmation() {
        var operations: [Operation] = []

        for transaction in signedTransactions {
            let isLastTransaction = signedTransactions.last == transaction
            let transactionUploadAndWaitOperation = TransactionUploadAndWaitOperation(
                signedTransaction: transaction,
                waitingTimeAfterTransactionConfirmed: isLastTransaction ? 0.0 : 1.0,
                transactionMonitor: transactionMonitor,
                api: api,
                shouldReturnSuccessWhenCompleted: isLastTransaction
            )

            transactionUploadAndWaitOperation.eventHandler = {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .didCompleteSwap:
                    self.publishEvent(.didCompleteSwap)
                case .didFailTransaction(let id):
                    self.cancelAllOperations()
                    self.publishEvent(.didFailTransaction(id))
                case .didFailNetwork(let error):
                    self.cancelAllOperations()
                    self.publishEvent(.didFailNetwork(error))
                case .didCancelTransaction:
                    self.cancelAllOperations()
                    self.publishEvent(.didCancelTransaction)
                }
            }

            operations.append(transactionUploadAndWaitOperation)
        }
        
        addOperationDependencies(&operations)
        uploadAndMonitorOperationQueue.addOperations(
            operations,
            waitUntilFinished: false
        )
    }

    private func addOperationDependencies(
        _ operations: inout [Operation]
    ) {
        var previousOperation: Operation?
        operations.forEach { operation in
            if let anOperation = previousOperation {
                operation.addDependency(anOperation)
            }

            previousOperation = operation
        }
    }

    private func cancelAllOperations() {
        uploadAndMonitorOperationQueue.cancelAllOperations()
    }
}

extension ALGSwapController {
    private func publishEvent(
        _ event: SwapControllerEvent
    ) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}
