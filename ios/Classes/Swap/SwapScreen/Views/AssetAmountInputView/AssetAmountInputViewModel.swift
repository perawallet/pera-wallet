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

//   AssetAmountInputViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

protocol AssetAmountInputViewModel: ViewModel {
    var imageSource: ImageSource? { get }
    var primaryValue: TextProvider? { get }
    var isInputEditable: Bool { get }
    var detail: TextProvider? { get }
}

extension AssetAmountInputViewModel {
    func getImageSource(_ asset: Asset) -> ImageSource {
        if asset.isAlgo {
            return AssetImageSource(
                asset: "icon-algo-circle-green-swap".uiImage
            )
        }

        let imageSize = CGSize(width: 40, height: 40)
        let prismURL = PrismURL(baseURL: asset.logoURL)?
            .setExpectedImageSize(imageSize)
            .setImageQuality(.normal)
            .build()

        let title = asset.naming.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.naming.name
        let placeholderText = TextFormatter.assetShortName.format(title)
        let placeholder = ImagePlaceholder.init(
            image: .init(asset: "asset-image-placeholder-border".uiImage),
            text: .string(placeholderText)
        )

        return PNGImageSource(
            url: prismURL,
            shape: .circle,
            placeholder: placeholder
        )
    }

    func getDetailValueForAlgo(
        value: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) -> TextProvider? {
        guard let amountUSDValue = value,
              let fiatCurrencyValue = currency.fiatValue else {
            return getDetailValue(text: "0.00")
        }

        do {
            let fiatRawCurrency = try fiatCurrencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amount = try exchanger.exchange(amount: amountUSDValue)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = fiatRawCurrency

            let text = currencyFormatter.format(amount)
            return getDetailValue(text: text)
        } catch {
            return nil
        }
    }

    func getDetailValueForAsset(
        _ asset: Asset,
        value: Decimal?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) -> TextProvider? {
        guard let amountUSDValue = value,
              let currencyValue = currency.primaryValue else {
            return getDetailValue(text: "0.00")
        }

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(amount: amountUSDValue)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let text = currencyFormatter.format(amount)
            return getDetailValue(text: text)
        } catch {
            return nil
        }
    }

    func getDetailValue(text: String?) -> TextProvider?  {
        if let text = text.unwrapNonEmptyString() {
            return "≈\(text)".footnoteRegular()
        } else {
            return nil
        }
    }
}
