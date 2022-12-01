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

//   TransactionPoolMonitor.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class TransactionPoolMonitor: TransactionMonitor {
    typealias Seconds = TimeInterval

    var eventHandler: EventHandler?

    var hasReachedRepeatingLimit: Bool {
        return repeatingLimit == currentRepeatCount
    }

    private let repeatingLimit = 30
    private var currentRepeatCount = 0
    private let monitorInterval: Seconds = 1.0

    private var ongoingMonitor: EndpointOperatable?
    private var transactionMonitorRepeater: Repeater?
    
    private let api: ALGAPI

    init(api: ALGAPI) {
        self.api = api
    }

    deinit {
        transactionMonitorRepeater?.invalidate()
    }
}

extension TransactionPoolMonitor {
    func monitor(
        _ transaction: TxnID
    ) {
        transactionMonitorRepeater = Repeater(intervalInSeconds: monitorInterval) {
            [weak self] in
            guard let self = self else { return }

            if self.hasReachedRepeatingLimit {
                self.failTransaction(transaction)
                return
            }

            self.currentRepeatCount += 1
            self.monitorTransaction(transaction)
        }

        transactionMonitorRepeater?.resume(immediately: false)
    }

    func stop() {
        ongoingMonitor?.cancel()
        ongoingMonitor = nil
        stopRepeater()
    }
}

extension TransactionPoolMonitor {
    private func monitorTransaction(
        _ transaction: TxnID
    ) {
        ongoingMonitor = api.getPendingTransaction(transaction) {
            [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let pendingTransaction):
                let status = pendingTransaction.getTransactionStatus()

                switch status {
                case .completed:
                    self.completeTransaction(transaction)
                case .inProgress:
                    break
                case .failed:
                    self.failTransaction(transaction)
                }
            case .failure(let apiError, let apiModelError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: apiModelError
                )

                self.eventHandler?(.didFailedNetwork(error))
            }
        }
    }

    private func stopRepeater() {
        transactionMonitorRepeater?.invalidate()
        transactionMonitorRepeater = nil
    }
}

extension TransactionPoolMonitor {
    private func completeTransaction(
        _ transaction: TxnID
    ) {
        eventHandler?(.didCompleted(transaction))
        stop()
    }

    private func failTransaction(
        _ transaction: TxnID
    ) {
        eventHandler?(.didFailedTransaction(transaction))
        stop()
    }
}
