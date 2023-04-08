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

//   SwapTransactionGroupSigner.swift

import Foundation

final class SwapTransactionGroupSigner {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private var allTransactionsSigned: Bool {
        return transactionGroups.allSatisfy { transactionGroup in
            transactionGroup.signedTransactions?.allSatisfy { $0 != nil } ?? false
        }
    }

    private let account: Account
    private let transactionSigner: SwapTransactionSigner

    private var transactionGroups = [SwapTransactionGroup]()

    init(
        account: Account,
        transactionSigner: SwapTransactionSigner
    ) {
        self.account = account
        self.transactionSigner = transactionSigner
    }

    func signTransactions(
        _ groups: [SwapTransactionGroup]
    ) {
        self.transactionGroups = groups

        for transactionGroup in transactionGroups {
            guard let unsignedTransactions = transactionGroup.transactions,
                  let signedTransactions = transactionGroup.signedTransactions else {
                continue
            }

            let unsignedTransactionIndexes = signedTransactions.findEmptyElementIndexes()

            for (index, unsignedTransaction) in unsignedTransactions.enumerated() {
                if unsignedTransactionIndexes.contains(index) {
                    sign(
                        unsignedTransaction,
                        at: index,
                        in: transactionGroup
                    )

                    /// <note>
                    /// If an account requires a Ledger connection, one transaction should be signed at a time
                    /// since the signing process happens on the Ledger one by one.
                    if account.requiresLedgerConnection() {
                        return
                    }
                }
            }
        }
    }

    func clearTransactions()  {
        transactionGroups = []
    }

    func disconnectFromLedger() {
        transactionSigner.disonnectFromLedger()
    }
}

extension SwapTransactionGroupSigner {
    private func sign(
        _ unsignedTransaction: Data,
        at index: Int,
        in transactionGroup: SwapTransactionGroup
    ) {
        transactionSigner.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSignTransaction(let signedTransaction):
                transactionGroup.signedTransactions?[index] = signedTransaction
                self.publishEvent(.didSignTransaction)

                if self.allTransactionsSigned {
                    self.publishTransactions()
                    return
                }

                if self.account.requiresLedgerConnection() {
                    self.signTransactions(self.transactionGroups)
                }
            case .didFailSigning(let error):
                self.publishEvent(.didFailSigning(error: error))
            case .didLedgerRequestUserApproval(let ledger):
                self.publishEvent(.didLedgerRequestUserApproval(ledger: ledger))
            case .didFinishTiming:
                self.publishEvent(.didFinishTiming)
            case .didLedgerReset:
                self.publishEvent(.didLedgerReset)
            case .didLedgerResetOnSuccess:
                self.publishEvent(.didLedgerResetOnSuccess)
            case .didLedgerRejectSigning:
                self.publishEvent(.didLedgerRejectSigning)
            }
        }

        transactionSigner.signTransaction(
            unsignedTransaction,
            for: account
        )
    }

    private func publishTransactions() {
        var transactionsToUpload = [Data]()

        let atomicTransactionLimit = 1

        for transactionGroup in transactionGroups {
            guard let signedTransactions = transactionGroup.signedTransactions else { continue }

            /// Add transactions that are not in a group
            if signedTransactions.count == atomicTransactionLimit {
                let signedTransaction = signedTransactions.compactMap { $0 }
                transactionsToUpload.append(contentsOf: signedTransaction)
                continue
            }

            /// Combine signed group transactions as a single transaction to upload
            var signedFullGroupTransaction = Data()
            for signedTransaction in signedTransactions {
                guard let signedTransaction else { continue }
                signedFullGroupTransaction += signedTransaction
            }

            transactionsToUpload.append(signedFullGroupTransaction)
        }

        publishAllTransactions(transactionsToUpload)
    }

    private func publishAllTransactions(
        _ transactions: [Data]
    ) {
        eventHandler?(.didCompleteSigningTransactions(transactions))
    }

    private func publishEvent(
        _ event: Event
    ) {
        eventHandler?(event)
    }
}

extension SwapTransactionGroupSigner {
    enum Event {
        case didSignTransaction
        case didCompleteSigningTransactions([Data])
        case didFailSigning(error: SwapTransactionSigner.SignError)
        case didLedgerRequestUserApproval(ledger: String)
        case didFinishTiming
        case didLedgerReset
        case didLedgerResetOnSuccess
        case didLedgerRejectSigning
    }
}
