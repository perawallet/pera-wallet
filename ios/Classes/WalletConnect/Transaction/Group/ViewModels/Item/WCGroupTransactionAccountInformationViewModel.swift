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
//   WCGroupTransactionAccountInformationViewModel.swift

import Foundation

final class WCGroupTransactionAccountInformationViewModel {
    private(set) var accountNameViewModel: AccountNameViewModel?
    private(set) var isAlgos = true
    private(set) var isDisplayingDotSeparator = true
    private(set) var balance: String?
    private(set) var assetName: String?

    init(
        account: Account?,
        asset: Asset?,
        isDisplayingAmount: Bool,
        currencyFormatter: CurrencyFormatter
    ) {
        setAccountNameViewModel(from: account)
        setIsAlgos(from: asset, and: isDisplayingAmount)
        setBalance(
            from: account,
            and: asset,
            with: isDisplayingAmount,
            currencyFormatter: currencyFormatter
        )
        setAssetName(from: asset, and: isDisplayingAmount)
        setIsDisplayingDotSeparator(from: isDisplayingAmount)
    }

    private func setAccountNameViewModel(from account: Account?) {
        guard let account = account else {
            return
        }

        accountNameViewModel = AccountNameViewModel(account: account)
    }

    private func setIsAlgos(
        from asset: Asset?,
        and isDisplayingAmount: Bool
    ) {
        if !isDisplayingAmount {
            isAlgos = false
            return
        }

        isAlgos = asset == nil
    }

    private func setIsDisplayingDotSeparator(from isDisplayingAmount: Bool) {
        isDisplayingDotSeparator = isDisplayingAmount && balance != nil
    }

    private func setBalance(
        from account: Account?,
        and asset: Asset?,
        with isDisplayingAmount: Bool,
        currencyFormatter: CurrencyFormatter
    ) {
        if !isDisplayingAmount {
            return
        }

        guard let account = account,
              hasValidAmount(of: account, for: asset) else {
            return
        }

        if let asset = asset {
            /// <todo>
            /// Not sure we need this constraint, because the final number should be sent to the
            /// formatter unless the number itself is modified.
            var constraintRules = CurrencyFormattingContextRules()
            constraintRules.maximumFractionDigits = asset.decimals

            currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
            currencyFormatter.currency = nil

            balance = currencyFormatter.format(asset.amountWithFraction)
            return
        }

        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        balance = currencyFormatter.format(account.algo.amount.toAlgos)
    }

    private func setAssetName(
        from asset: Asset?,
        and isDisplayingAmount: Bool
    ) {
        if !isDisplayingAmount {
            return
        }

        if balance == nil {
            return
        }

        if let asset = asset {
            assetName = asset.naming.displayNames.secondaryName
        } else {
            assetName = "ALGO"
        }
    }

    private func hasValidAmount(
        of account: Account,
        for asset: Asset?
    ) -> Bool {
        guard let asset = asset else {
            return account.algo.amount > 0
        }

        return !asset.amountWithFraction.isZero
    }
}
