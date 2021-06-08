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
//   AlgoUSDAnalyticsFooterViewModel.swift

import Foundation

class AlgoUSDAnalyticsFooterViewModel {
    private(set) var balance: String?
    private(set) var value: String?

    init(account: Account, currency: Currency) {
        setBalance(from: account)
        setValue(from: account, and: currency)
    }

    private func setBalance(from account: Account) {
        balance = account.amount.toAlgos.toAlgosStringForLabel
    }

    private func setValue(from account: Account, and currency: Currency) {
        guard let currencyPrice = currency.price,
              let currencyPriceDoubleValue = Double(currencyPrice) else {
            return
        }

        let currencyAmountForAccount = account.amount.toAlgos * currencyPriceDoubleValue

        if let currencyValue = currencyAmountForAccount.toCurrencyStringForLabel {
            value = "\(currencyValue) \(currency.id)"
        }
    }
}
