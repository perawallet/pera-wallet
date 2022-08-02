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
//   AssetDetailInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetDetailInfoViewModel:
    ViewModel,
    Hashable {
    private(set) var title: TextProvider?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?
    private(set) var name: TextProvider?
    private(set) var isVerified: Bool = false
    private(set) var id: TextProvider?

    init(
        asset: StandardAsset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindPrimaryValue(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindName(asset)
        bindIsVerified(asset)
        bindID(asset)
    }
}

extension AssetDetailInfoViewModel {
    mutating func bindTitle() {
        title = "accounts-transaction-your-balance"
            .localized
            .bodyRegular(hasMultilines: false)
    }

    mutating func bindPrimaryValue(
        asset: StandardAsset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let asset = asset else {
            primaryValue = nil
            return
        }

        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = nil

        let text = currencyFormatter.format(asset.decimalAmount)
        primaryValue = text?.largeTitleMonoRegular(hasMultilines: false)
    }

    mutating func bindSecondaryValue(
        asset: StandardAsset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard
            let asset = asset,
            let currencyValue = currency.primaryValue
        else {
            secondaryValue = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(asset)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let text = currencyFormatter.format(amount)
            secondaryValue = text?.bodyMonoRegular(hasMultilines: false)
        } catch {
            secondaryValue = nil
        }
    }

    mutating func bindName(
        _ asset: StandardAsset?
    ) {
        let text = asset?.presentation.displayNames.primaryName
        name = text?.bodyMedium(hasMultilines: false)
    }

    mutating func bindIsVerified(
        _ asset: StandardAsset?
    ) {
        isVerified = asset?.isVerified ?? false
    }

    mutating func bindID(
        _ asset: StandardAsset?
    ) {
        guard let asset = asset else {
            id = nil
            return
        }

        id = "asset-detail-id-title"
            .localized(params: "\(asset.id)")
            .bodyRegular(hasMultilines: false)
    }
}

extension AssetDetailInfoViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(primaryValue?.string)
        hasher.combine(secondaryValue?.string)
        hasher.combine(name?.string)
        hasher.combine(isVerified)
        hasher.combine(id?.string)
    }

    static func == (
        lhs: AssetDetailInfoViewModel,
        rhs: AssetDetailInfoViewModel
    ) -> Bool {
        return
            lhs.primaryValue?.string == rhs.primaryValue?.string &&
            lhs.secondaryValue?.string == rhs.secondaryValue?.string &&
            lhs.name?.string == rhs.name?.string &&
            lhs.isVerified == rhs.isVerified &&
            lhs.id?.string == rhs.id?.string
    }
}
