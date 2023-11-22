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
//   WCTransactionValidator.swift

import UIKit

protocol WCTransactionValidator {
    func validateTransactions(
        _ transactions: [WCTransaction],
        with transactionGroups: [Int64: [WCTransaction]],
        sharedDataController: SharedDataController
    )
    func rejectTransactionRequest(with error: WCTransactionErrorResponse)
}

extension WCTransactionValidator {
    func validateTransactions(
        _ transactions: [WCTransaction],
        with transactionGroups: [Int64: [WCTransaction]],
        sharedDataController: SharedDataController
    ) {
        if !hasValidTransactionCount(for: transactions) {
            rejectTransactionRequest(with: .invalidInput(.transactionCount))
            return
        }

        if hasInvalidTransactionDetail(among: transactions) {
             rejectTransactionRequest(with: .invalidInput(.transactionParse))
             return
         }

        if !hasValidAddresses(in: transactions) {
            rejectTransactionRequest(with: .invalidInput(.publicKey))
            return
        }

        if containsMultisigTransaction(in: transactions) {
            rejectTransactionRequest(with: .unsupported(.multisig))
            return
        }

        if !hasValidSignerAddress(in: transactions) {
            rejectTransactionRequest(with: .invalidInput(.signer))
            return
        }

        if !containsTransactionAuthInTheWallet(for: transactions) {
            rejectTransactionRequest(with: .unauthorized(.transactionSignerNotFound))
            return
        }

        if !containsSignerInTheWallet(for: transactionGroups) {
            rejectTransactionRequest(with: .unauthorized(.transactionSignerNotFound))
            return
        }

        if hasInvalidGroupedTransaction(in: transactionGroups) {
            rejectTransactionRequest(with: .invalidInput(.group))
            return
        }
    }

    private func hasValidTransactionCount(for transactions: [WCTransaction]) -> Bool {
        return transactions.count <= supportedTransactionCount
    }
    
    private func hasInvalidTransactionDetail(among transactions: [WCTransaction]) -> Bool {
         return transactions.contains { $0.transactionDetail == nil }
    }

    private func hasValidAddresses(in transactions: [WCTransaction]) -> Bool {
        let algorandSDK = AlgorandSDK()
        for transaction in transactions {
            let addresses = transaction.validationAddresses.compactMap { $0 }
            for address in addresses {
                if !algorandSDK.isValidAddress(address) {
                    return false
                }
            }
        }

        return true
    }

    private func containsMultisigTransaction(in transactions: [WCTransaction]) -> Bool {
        return transactions.contains { $0.isMultisig }
    }

    private func hasValidSignerAddress(in transactions: [WCTransaction]) -> Bool {
        for transaction in transactions where transaction.authAddress != nil {
            if !transaction.hasValidAuthAddressForSigner || !transaction.hasValidSignerAddress {
                return false
            }
        }

        return true
    }

    private func containsTransactionAuthInTheWallet(for transactions: [WCTransaction]) -> Bool {
        for transaction in transactions where transaction.authAddress != nil {
            if !transaction.requestedSigner.containsSignerInTheWallet {
                return false
            }
        }

        return true
    }

    private func containsSignerInTheWallet(for transactionGroups: [Int64: [WCTransaction]]) -> Bool {
        for group in transactionGroups {
            /// <note>
            /// In a group transaction, if there's a signer address specified but we don't have the signer account in the wallet,
            /// the transaction should not e accepted.
            let signableTransactionsInTheGroup = group.value.filter { $0.requestedSigner.containsSignerInTheWallet }
            if signableTransactionsInTheGroup.isEmpty {
                return false
            }
        }

        return true
    }

    private func hasInvalidGroupedTransaction(in transactionGroups: [Int64: [WCTransaction]]) -> Bool {
        for group in transactionGroups {
            let signableTransactions = group.value.filter { $0.requestedSigner.account != nil }
            if signableTransactions.isEmpty {
                return true
            }
        }

        return false
    }
}

extension WCTransactionValidator {
    private var supportedTransactionCount: Int {
        return 1000
    }
}
