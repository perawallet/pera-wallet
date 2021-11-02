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
//  MaximumBalanceWarningViewModel.swift

import UIKit

class MaximumBalanceWarningViewModel {
    private(set) var description: String?

    init(account: Account) {
        setDescription(from: account)
    }

    private func setDescription(from account: Account) {
        let minimumAmountForAccount = "\(calculateMininmumAmount(for: account).toAlgos)"

        if !account.isRekeyed() {
            description = "maximum-balance-standard-account-warning-description".localized(params: minimumAmountForAccount)
            return
        }

        description = "maximum-balance-warning-description".localized(params: minimumAmountForAccount)
    }

    private func calculateMininmumAmount(for account: Account) -> UInt64 {
        let params = UIApplication.shared.accountManager?.params
        let feeCalculator = TransactionFeeCalculator(transactionDraft: nil, transactionData: nil, params: params)
        let calculatedFee = params?.getProjectedTransactionFee() ?? Transaction.Constant.minimumFee
        let minimumAmountForAccount = feeCalculator.calculateMinimumAmount(
            for: account,
            with: .algosTransaction,
            calculatedFee: calculatedFee,
            isAfterTransaction: true
        ) - calculatedFee
        return minimumAmountForAccount
    }
}
