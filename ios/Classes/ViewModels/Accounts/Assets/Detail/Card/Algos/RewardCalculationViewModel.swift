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
//   RewardCalculationViewModel.swift

import UIKit

class RewardCalculationViewModel {
    private(set) var totalAmount: String?
    private(set) var currency: String?
    private(set) var rewardAmount: String?

    init(account: Account, calculatedRewards: Double, currency: Currency?) {
        setTotalAmount(from: account, and: calculatedRewards)
        setCurrency(from: account, and: currency, and: calculatedRewards)
        setRewardAmount(from: account, and: calculatedRewards)
    }

    private func setTotalAmount(from account: Account, and calculatedRewards: Double) {
        totalAmount = getTotalAmount(from: account, and: calculatedRewards).toAlgosStringForLabel
    }

    private func setCurrency(from account: Account, and currency: Currency?, and calculatedRewards: Double) {
        guard let currentCurrency = currency,
              let price = currentCurrency.price,
              let priceDoubleValue = Double(price) else {
            return
        }

        let currencyAmountForAccount = getTotalAmount(from: account, and: calculatedRewards) * priceDoubleValue

        if let currencyValue = currencyAmountForAccount.toCurrencyStringForLabel {
            self.currency = currencyValue + " " + currentCurrency.id
        }
    }

    private func setRewardAmount(from account: Account, and calculatedRewards: Double) {
        rewardAmount = getPendingRewards(from: account, and: calculatedRewards).toExactFractionLabel(fraction: 6)
    }

    private func getTotalAmount(from account: Account, and calculatedRewards: Double) -> Double {
        return account.amountWithoutRewards.toAlgos + getPendingRewards(from: account, and: calculatedRewards)
    }

    private func getPendingRewards(from account: Account, and calculatedRewards: Double) -> Double {
        return account.pendingRewards.toAlgos + calculatedRewards
    }
}
