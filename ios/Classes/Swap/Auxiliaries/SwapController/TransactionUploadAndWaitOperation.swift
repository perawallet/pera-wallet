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

//   TransactionUploadAndWaitOperation.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class TransactionUploadAndWaitOperation: MacaroonUtils.AsyncOperation {
    typealias EventHandler = (Event) -> Void
    typealias Error = HIPNetworkError<IndexerError>

    var eventHandler: EventHandler?

    private var ongoingEndpoint: EndpointOperatable?

    private let signedTransaction: Data
    private let waitingTimeAfterTransactionConfirmed: TimeInterval
    private let transactionMonitor: TransactionMonitor
    private let api: ALGAPI
    private let shouldReturnSuccessWhenCompleted: Bool

    init(
        signedTransaction: Data,
        waitingTimeAfterTransactionConfirmed: TimeInterval = 1.0,
        transactionMonitor: TransactionMonitor,
        api: ALGAPI,
        shouldReturnSuccessWhenCompleted: Bool
    ) {
        self.signedTransaction = signedTransaction
        self.waitingTimeAfterTransactionConfirmed = waitingTimeAfterTransactionConfirmed
        self.transactionMonitor = transactionMonitor
        self.api = api
        self.shouldReturnSuccessWhenCompleted = shouldReturnSuccessWhenCompleted
    }

    override func main() {
        if finishIfCancelled() {
            return
        }

        ongoingEndpoint = api.sendTransaction(signedTransaction) {
            [weak self] response in
            guard let self = self else { return }

            self.ongoingEndpoint = nil

            switch response {
            case .success(let signedTransaction):
                self.monitorTransaction(signedTransaction.identifier)
            case .failure(let apiError, let apiModelError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: apiModelError
                )

                self.publishEvent(.didFailNetwork(error))
                self.finish()
            }
        }
    }

    private func monitorTransaction(
        _ transactionID: TxnID
    ) {
        transactionMonitor.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didCompleted:
                /// <note>
                /// When a transaction is confirmed, we are waiting for some amount time to make sure that nodes are synced.
                /// Default waiting time is 1 second.
                asyncMain(afterDuration: self.waitingTimeAfterTransactionConfirmed) {
                    [weak self] in
                    guard let self = self else { return }

                    if self.shouldReturnSuccessWhenCompleted {
                        self.publishEvent(.didCompleteSwap)
                    }
                    
                    self.finish()
                }
            case .didFailedTransaction(let txnID):
                self.publishEvent(.didFailTransaction(txnID))
                self.finish()
            case .didFailedNetwork(let error):
                self.publishEvent(.didFailNetwork(error))
                self.finish()
            }
        }

        transactionMonitor.monitor(transactionID)
    }

    override func finishIfCancelled() -> Bool {
        if !isCancelled {
            return false
        }

        publishEvent(.didCancelTransaction)

        finish()
        return true
    }

    override func cancel() {
        cancelOngoingEndpoint()
        super.cancel()
    }
}

extension TransactionUploadAndWaitOperation {
    private func publishEvent(
        _ event: Event
    ) {
        eventHandler?(event)
    }

    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
        transactionMonitor.stop()
    }
}

extension TransactionUploadAndWaitOperation {
    enum Event {
        case didCompleteSwap
        case didFailTransaction(TxnID)
        case didFailNetwork(Error)
        case didCancelTransaction
    }
}
