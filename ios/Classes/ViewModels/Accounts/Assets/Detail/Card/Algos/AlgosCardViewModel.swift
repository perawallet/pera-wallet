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
//  AlgosCardViewModel.swift

import UIKit

class AlgosCardViewModel {
    
    private(set) var totalAmount: String?
    private(set) var algosAmount: String?
    private(set) var reward: String?
    private(set) var currency: String?
    private(set) var analyticsContainerViewModel: AlgosCardAnalyticsContainerViewModel?
    
    init(account: Account, currency: Currency?) {
        setTotalAmount(from: account)
        setCurrency(from: account, and: currency)
        setAlgosAmount(from: account)
        setReward(from: account)
        setAnalyticsContainerViewModel(from: currency)
    }
    
    private func setCurrency(from account: Account, and currency: Currency?) {
        guard let currentCurrency = currency,
              let price = currentCurrency.price,
              let priceDoubleValue = Double(price) else {
            return
        }
        
        let currencyAmountForAccount = account.amount.toAlgos * priceDoubleValue
        
        if let currencyValue = currencyAmountForAccount.toCurrencyStringForLabel {
            self.currency = currencyValue + " " + currentCurrency.id
        }
    }

    private func setTotalAmount(from account: Account) {
        totalAmount = account.amount.toAlgos.toAlgosStringForLabel
    }

    private func setAlgosAmount(from account: Account) {
        algosAmount = account.amountWithoutRewards.toAlgos.toAlgosStringForLabel
    }

    private func setReward(from account: Account) {
        reward = account.pendingRewards.toAlgos.toExactFractionLabel(fraction: 6)
    }

    private func setAnalyticsContainerViewModel(from currency: Currency?) {
        analyticsContainerViewModel = AlgosCardAnalyticsContainerViewModel(currency: currency)
    }
}
