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

//   ASADetailProfileViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct ASADetailProfileViewModel: ASAProfileViewModel {
    private(set) var icon: ImageSource?
    private(set) var name: RightAccessorizedLabelModel?
    private(set) var titleSeparator: TextProvider?
    private(set) var id: TextProvider?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?

    init(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindIcon(asset: asset)
        bindName(asset: asset)
        bindTitleSeparator(asset: asset)
        bindID(asset: asset)
        bindPrimaryValue(
            asset: asset,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension ASADetailProfileViewModel {
    mutating func bindIcon(asset: Asset) {
        if asset.isAlgo {
            icon = AssetImageSource(asset: "icon-algo-circle".uiImage)
            return
        }

        let size = CGSize(width: 40, height: 40)
        let url = PrismURL(baseURL: asset.logoURL)?
            .setExpectedImageSize(size)
            .setImageQuality(.normal)
            .build()
        /// <todo>
        /// Find a better way of formatting name
        let title = asset.naming.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.naming.name
        let placeholderText = TextFormatter.assetShortName.format(title)
        let placeholderImage = placeholderText?.toPlaceholderImage(size: size)
        let placeholderAsset = AssetImageSource(asset: placeholderImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)
        icon = DefaultURLImageSource(url: url, shape: .circle, placeholder: placeholder)
    }

    mutating func bindName(asset: Asset) {
        name = ASAProfileNameViewModel(asset: asset)
    }

    mutating func bindTitleSeparator(asset: Asset) {
        if asset.isAlgo {
            titleSeparator = nil
        } else {
            titleSeparator = "  •  "
        }
    }

    mutating func bindID(asset: Asset) {
        if asset.isAlgo {
            id = nil
        } else {
            id = String(asset.id).footnoteRegular()
        }
    }

    mutating func bindPrimaryValue(
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        if asset.isAlgo {
            bindAlgoPrimaryValue(
                asset: asset,
                currencyFormatter: currencyFormatter
            )
        } else {
            bindAssetPrimaryValue(
                asset: asset,
                currencyFormatter: currencyFormatter
            )
        }
    }

    mutating func bindAlgoPrimaryValue(
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let text = currencyFormatter.format(asset.decimalAmount)
        bindPrimaryValue(text: text)
    }

    mutating func bindAssetPrimaryValue(
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = nil

        let amountText = currencyFormatter.format(asset.decimalAmount)
        let unitText =
            asset.naming.unitName.unwrapNonEmptyString() ?? asset.naming.name.unwrapNonEmptyString()
        let text = [ amountText, unitText ].compound(" ")
        bindPrimaryValue(text: text)
    }

    mutating func bindPrimaryValue(text: String?) {
        primaryValue = text?.titleSmallMedium()
    }

    mutating func bindSecondaryValue(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if asset.isAlgo {
            bindAlgoSecondaryValue(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        } else {
            bindAssetSecondaryValue(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        }
    }

    mutating func bindAlgoSecondaryValue(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let fiatCurrencyValue = currency.fiatValue else {
            secondaryValue = nil
            return
        }

        do {
            let fiatRawCurrency = try fiatCurrencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchangeAlgo(amount: asset.decimalAmount)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = fiatRawCurrency

            let text = currencyFormatter.format(amount)
            bindSecondaryValue(text: text)
        } catch {
            secondaryValue = nil
        }
    }

    mutating func bindAssetSecondaryValue(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let currencyValue = currency.primaryValue else {
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
            bindSecondaryValue(text: text)
        } catch {
            secondaryValue = nil
        }
    }

    mutating func bindSecondaryValue(text: String?) {
        if let text = text.unwrapNonEmptyString() {
            secondaryValue = text.bodyMedium()
        } else {
            secondaryValue = nil
        }
    }
}
