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

//   TransactionAmountValidator.swift

import Foundation

extension Result where Success == Void {
    public static var success: Result { .success(()) }
}

typealias TransactionAmountValidation = Swift.Result<Void, TransactionAmountValidationError>

final class TransactionAmountValidator {
    private var account: Account
    private var transactionParams: TransactionParams?

    init(
        account: Account
    ) {
        self.account = account
    }
}

/// <mark>: API
extension TransactionAmountValidator {
    func setTransactionParams(_ params: TransactionParams?) {
        self.transactionParams = params
    }

    func validate(amount: Decimal, on asset: Asset?) -> TransactionAmountValidation {
        guard let transactionParams = transactionParams else {
            return .failure(.transactionParamsMissing)
        }

        guard let asset = asset else {
            return validateAlgo(amount: amount, with: transactionParams)
        }

        return validateAsset(asset, amount: amount, with: transactionParams)
    }

    func updateAccount(_ account: Account) {
        self.account = account
    }
}

extension TransactionAmountValidator {
    private func validateAlgo(
        amount: Decimal,
        with transactionParams: TransactionParams
    ) -> TransactionAmountValidation {
        let algoAmount = amount.toMicroAlgos
        let isMaxTransaction = self.isMaxTransaction(
            amount: amount,
            transactionParams: transactionParams,
            on: nil
        )

        if algoAmount > account.algo.amount {
            return .failure(.algo(.exceededLimit))
        }

        let requiredMinimumAmount = calculateMininmumAmount(using: transactionParams)

        if account.algo.amount < requiredMinimumAmount &+ minimumFee {
            return .failure(.algo(.lowBalance))
        }

        if isMaxTransaction {
            if account.hasParticipationKey() {
                return .failure(.algo(.participationKey))
            } else if !account.hasDifferentMinBalance {
                return .success
            }

            return .failure(.algo(.requiredMinimumBalance))
        }

        return .success

    }

    private func validateAsset(
        _ asset: Asset,
        amount: Decimal,
        with transactionParams: TransactionParams
    ) -> TransactionAmountValidation {
        let assetAmount = asset.amountWithFraction

        if assetAmount < amount {
            return .failure(.asset(.exceededLimit))
        }

        let requiredMinimumAmount = calculateMininmumAmount(using: transactionParams)

        if requiredMinimumAmount &+ minimumFee > account.algo.amount  {
            return .failure(.algo(.lowBalance))
        }

        return .success
    }
}

/// <mark>: Helpers
extension TransactionAmountValidator {
    private func isMaxTransaction(
        amount: Decimal,
        transactionParams: TransactionParams,
        on asset: Asset?
    ) -> Bool {
        guard let asset = asset else {
            let requiredMinimumAmount = calculateMininmumAmount(using: transactionParams)
            return Int(account.algo.amount) - Int(amount.toMicroAlgos) - Int(minimumFee) < Int(requiredMinimumAmount)
        }

        return asset.amount == amount.uint64Value
    }
}

/// <mark>: Minimum Balance Calculation
extension TransactionAmountValidator {
    private func calculateMininmumAmount(using transactionParams: TransactionParams) -> UInt64 {
        let feeCalculator = TransactionFeeCalculator(
            transactionDraft: nil,
            transactionData: nil,
            params: transactionParams
        )

        let calculatedFee = transactionParams.getProjectedTransactionFee()
        let minimumAmountForAccount = feeCalculator.calculateMinimumAmount(
            for: account,
               with: .algosTransaction,
               calculatedFee: calculatedFee,
               isAfterTransaction: true
        ) - calculatedFee
        return minimumAmountForAccount
    }
}
enum TransactionAmountValidationError: Error {
    case asset(TransactionAmountAssetError)
    case algo(TransactionAmountAlgoError)
    case transactionParamsMissing
    case unexpected // amount cannot be parsed correctly
}

enum TransactionAmountAssetError: Error {
    case exceededLimit
    case requiredMinimumBalance
}

enum TransactionAmountAlgoError: Error {
    case exceededLimit
    case participationKey
    case requiredMinimumBalance
    case lowBalance
}

