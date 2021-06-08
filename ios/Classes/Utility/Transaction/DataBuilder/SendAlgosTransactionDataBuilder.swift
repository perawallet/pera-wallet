// Copyright 2019 Algorand, Inc.

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
//  SendAlgosTransactionDataBuilder.swift

import Foundation

class SendAlgosTransactionDataBuilder: TransactionDataBuilder {

    private let initialSize: Int?
    private(set) var calculatedTransactionAmount: Int64?
    private(set) var minimumAccountBalance: Int64?

    init(params: TransactionParams?, draft: TransactionSendDraft?, initialSize: Int?) {
        self.initialSize = initialSize
        super.init(params: params, draft: draft)
    }

    override func composeData() -> Data? {
        return composeAlgosTransactionData()
    }

    private func composeAlgosTransactionData() -> Data? {
        guard let params = params,
              let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              let toAddress = algosTransactionDraft.toAccount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.other))
            return nil
        }

        var isMaxTransaction = algosTransactionDraft.isMaxTransaction
        let transactionAmount = calculateTransactionAmount(isMaxTransaction: isMaxTransaction)
        self.calculatedTransactionAmount = transactionAmount
        updateMaximumTransactionStateIfNeeded(&isMaxTransaction)

        if !isValidAddress(toAddress.trimmed) || transactionAmount.isBelowZero {
            return nil
        }

        let draft = AlgosTransactionDraft(
            from: algosTransactionDraft.from,
            toAccount: toAddress.trimmed,
            transactionParams: params,
            amount: transactionAmount,
            isMaxTransaction: isMaxTransaction,
            note: algosTransactionDraft.note?.data(using: .utf8)
        )

        var transactionError: NSError?

        guard let transactionData = algorandSDK.sendAlgos(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }

    private func updateMaximumTransactionStateIfNeeded(_ isMaxTransaction: inout Bool) {
        if isMaxTransaction {
            // If transaction amount is equal to amount of the sender account when it is max transaction
            // If an account is rekeyed, it's not allowed to make max transaciton
            // If account has assets, it cannot complete max transaction
            isMaxTransaction = canSendMaxTransactions()
        }
    }

    private func calculateTransactionAmount(isMaxTransaction: Bool) -> Int64 {
        guard let params = params,
              let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              var transactionAmount = algosTransactionDraft.amount?.toMicroAlgos else {
            return 0
        }

        let feeCalculator = TransactionFeeCalculator(transactionDraft: nil, transactionData: nil, params: params)
        let calculatedFee = params.getProjectedTransactionFee(from: initialSize)
        let minimumAmountForAccount = feeCalculator.calculateMinimumAmount(
            for: algosTransactionDraft.from,
            with: .algosTransaction,
            calculatedFee: calculatedFee,
            isAfterTransaction: true
        )

        self.minimumAccountBalance = minimumAmountForAccount - calculatedFee

        if isMaxTransaction {
            if isMaxTransactionFromRekeyedAccount() || hasAdditionalAssetsForMaxTransaction() {
                // Reduce fee and minimum amount possible for the account from transaction amount
                transactionAmount -= (calculatedFee + (minimumAccountBalance ?? minimumAmountForAccount))
            } else {
                // Reduce fee from transaction amount
                transactionAmount -= calculatedFee
            }
        }

        return transactionAmount
    }

    private func canSendMaxTransactions() -> Bool {
        return !isMaxTransactionFromRekeyedAccount() && !hasAdditionalAssetsForMaxTransaction() && hasMaximumAccountAmountForTransaction()
    }

    private func isMaxTransactionFromRekeyedAccount() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft else {
            return false
        }

        return algosTransactionDraft.isMaxTransactionFromRekeyedAccount
    }

    private func hasAdditionalAssetsForMaxTransaction() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft else {
            return false
        }

        return !algosTransactionDraft.from.assetDetails.isEmpty && algosTransactionDraft.isMaxTransaction
    }

    private func hasMaximumAccountAmountForTransaction() -> Bool {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft,
              let transactionAmount = draft?.amount?.toMicroAlgos else {
            return false
        }

        return transactionAmount == algosTransactionDraft.from.amount
    }
}
