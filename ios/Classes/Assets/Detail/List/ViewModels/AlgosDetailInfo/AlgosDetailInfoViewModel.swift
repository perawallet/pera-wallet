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
//   AlgosDetailInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgosDetailInfoViewModel:
    ViewModel,
    Hashable {
    private(set) var title: TextProvider?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?
    private(set) var rewardsInfo: RewardInfoViewModel?
    private(set) var isBuyAlgoAvailable: Bool = false

    init(
        account: Account,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindPrimaryValue(
            account: account,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue(
            account: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindRewardsInfo(
            account: account,
            currencyFormatter: currencyFormatter
        )
        bindIsBuyAlgoAvailable(account)
    }
}

extension AlgosDetailInfoViewModel {
    mutating func bindTitle() {
        title = "accounts-transaction-your-balance"
            .localized
            .bodyRegular(hasMultilines: false)
    }

    mutating func bindPrimaryValue(
        account: Account,
        currencyFormatter: CurrencyFormatter
    ) {
        let amount = account.amount.toAlgos

        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let text = currencyFormatter.format(amount)
        primaryValue = text?.largeTitleMonoRegular(hasMultilines: false)
    }

    mutating func bindSecondaryValue(
        account: Account,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        do {
            guard let fiatCurrencyValue = currency.fiatValue else {
                secondaryValue = nil
                return
            }

            let fiatRawCurrency = try fiatCurrencyValue.unwrap()

            let algoAmount = account.amount.toAlgos
            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchangeAlgo(amount: algoAmount)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = fiatRawCurrency

            let text = currencyFormatter.format(amount)
            secondaryValue = text?.bodyMonoRegular(hasMultilines: false)
        } catch {
            secondaryValue = nil
        }
    }

    mutating func bindRewardsInfo(
        account: Account,
        currencyFormatter: CurrencyFormatter
    ) {
        rewardsInfo = RewardInfoViewModel(
            account: account,
            currencyFormatter: currencyFormatter
        )
    }

    mutating func bindIsBuyAlgoAvailable(
        _ account: Account
    ) {
        isBuyAlgoAvailable = !account.isWatchAccount()
    }
}

extension AlgosDetailInfoViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(primaryValue?.string)
        hasher.combine(secondaryValue?.string)
        hasher.combine(rewardsInfo)
        hasher.combine(isBuyAlgoAvailable)
    }

    static func == (
        lhs: AlgosDetailInfoViewModel,
        rhs: AlgosDetailInfoViewModel
    ) -> Bool {
        return
            lhs.primaryValue?.string == rhs.primaryValue?.string &&
            lhs.secondaryValue?.string == rhs.secondaryValue?.string &&
            lhs.rewardsInfo == rhs.rewardsInfo &&
            lhs.isBuyAlgoAvailable == rhs.isBuyAlgoAvailable
    }
}
