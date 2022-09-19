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
//  TransactionFeeCalculator.swift

import Foundation

class TransactionFeeCalculator: NSObject {

    weak var delegate: TransactionFeeCalculatorDelegate?

    private var transactionDraft: TransactionSendDraft?
    private let transactionData: TransactionData?
    private let params: TransactionParams?

    init(transactionDraft: TransactionSendDraft?, transactionData: TransactionData?, params: TransactionParams?) {
        self.transactionDraft = transactionDraft
        self.transactionData = transactionData
        self.params = params
    }

    func calculate(for transactionType: TransactionController.TransactionType) -> UInt64? {
        guard let params = params,
              let transactionData = transactionData,
              let signedTransactionData = transactionData.signedTransaction else {
            return nil
        }

        let calculatedFee = params.getProjectedTransactionFee(from: signedTransactionData.count)

        /// Asset transaction fee amount must be asset count * minimum algos limit + minimum fee
        if !isValidTransactionAmount(for: transactionType, calculatedFee: calculatedFee) {
            return nil
        }

        return calculatedFee
    }

    func isValidTransactionAmount(for transactionType: TransactionController.TransactionType, calculatedFee: UInt64) -> Bool {
        guard let account = transactionDraft?.from,
              let isMaxTransaction = transactionDraft?.isMaxTransaction,
              !isMaxTransaction else {
            return true
        }

        let transactionAmount = transactionType == .algosTransaction ? transactionDraft?.amount?.toMicroAlgos ?? 0 : 0

        let minimumAmount = calculateMinimumAmount(
            for: account,
            with: transactionType,
            calculatedFee: calculatedFee,
            isAfterTransaction: true
        )
        
        if UInt64(account.algo.amount) < minimumAmount + transactionAmount {
            delegate?.transactionFeeCalculator(self, didFailedWith: minimumAmount)
            return false
        }

        return true
    }

    func calculateMinimumAmount(
        for account: Account,
        with transactionType: TransactionController.TransactionType,
        calculatedFee: UInt64,
        isAfterTransaction: Bool
    ) -> UInt64 {
        var assetCount = (account.assets?.count ?? 0) + 1

        switch transactionType {
        case .algosTransaction:
            break
        case .assetTransaction:
            break
        case .assetAddition:
            if isAfterTransaction {
                assetCount += 1
            }
        case .rekey:
            break
        case .assetRemoval:
            if isAfterTransaction {
                assetCount -= 1
            }
        }

        let createdAppAmount = minimumTransactionMicroAlgosLimit * UInt64(account.totalCreatedApps)
        let localStateAmount = minimumTransactionMicroAlgosLimit * UInt64(account.appsLocalState?.count ?? 0)
        let totalSchemaValueAmount = totalNumIntConstantForMinimumAmount * UInt64(account.appsTotalSchema?.intValue ?? 0)
        let byteSliceAmount = byteSliceConstantForMinimumAmount * UInt64(account.appsTotalSchema?.byteSliceCount ?? 0)
        let extraPagesAmount = minimumTransactionMicroAlgosLimit * UInt64(account.appsTotalExtraPages ?? 0)

        let applicationRelatedMinimumAmount = createdAppAmount +
            localStateAmount +
            totalSchemaValueAmount +
            byteSliceAmount +
            extraPagesAmount

        let minimumAmount = (minimumTransactionMicroAlgosLimit * UInt64(assetCount)) +
            applicationRelatedMinimumAmount +
            calculatedFee

        return minimumAmount
    }
}

protocol TransactionFeeCalculatorDelegate: AnyObject {
    func transactionFeeCalculator(_ transactionFeeCalculator: TransactionFeeCalculator, didFailedWith minimumAmount: UInt64)
}
