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

//   AssetListItemViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct AssetListItemViewModel: PrimaryListItemViewModel {
    private(set) var imageSource: ImageSource?
    private(set) var title: PrimaryTitleViewModel?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?

    init(_ item: AssetItem) {
        bindImageSource(item)
        bindTitle(item)
        bindPrimaryValue(item)
        bindSecondaryValue(item)
    }

    init(update: OptInBlockchainUpdate) {
        bindIcon(update)
        bindTitle(update)
        bindPrimaryValue(update)
    }

    init(update: OptOutBlockchainUpdate) {
        bindIcon(update)
        bindTitle(update)
        bindPrimaryValue(update)
    }
}

extension AssetListItemViewModel {
    mutating func bindImageSource(
        _ item: AssetItem
    ) {
        let asset = item.asset

        if asset.isAlgo {
            imageSource = AssetImageSource(asset: "icon-algo-circle".uiImage)
            return
        }

        let iconURL: URL?
        let iconShape: ImageShape

        if let collectibleAsset = asset as? CollectibleAsset {
            iconURL = collectibleAsset.thumbnailImage
            iconShape = .rounded(4)
        } else {
            iconURL = asset.logoURL
            iconShape = .circle
        }

        let size = CGSize(width: 40, height: 40)
        let url = PrismURL(baseURL: iconURL)?
            .setExpectedImageSize(size)
            .setImageQuality(.normal)
            .build()

        let placeholder = getPlaceholder(asset)

        imageSource = DefaultURLImageSource(
            url: url,
            shape: iconShape,
            placeholder: placeholder
        )
    }

    mutating func bindTitle(
        _ item: AssetItem
    ) {
        title = AssetNameViewModel(item.asset)
    }

    mutating func bindPrimaryValue(
        _ item: AssetItem
    ) {
        let asset = item.asset

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem
        if asset.isAlgo {
            formatter.currency = AlgoLocalCurrency()
        } else {
            formatter.currency = nil
        }

        let text = formatter.format(asset.decimalAmount)
        primaryValue = text?.bodyMedium(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating private func bindSecondaryValue(
        _ item: AssetItem
    ) {
        let amount: Decimal

        let asset = item.asset

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem

        do {
            let exchanger: CurrencyExchanger
            if asset.isAlgo {
                guard let fiatCurrencyValue = item.currency.fiatValue else {
                    secondaryValue = nil
                    return
                }

                let rawFiatCurrency = try fiatCurrencyValue.unwrap()
                exchanger = CurrencyExchanger(currency: rawFiatCurrency)
                amount = try exchanger.exchangeAlgo(amount: asset.decimalAmount)

                formatter.currency = rawFiatCurrency
            } else {
                guard let currencyValue = item.currency.primaryValue else {
                    secondaryValue = nil
                    return
                }

                let rawCurrency = try currencyValue.unwrap()
                exchanger = CurrencyExchanger(currency: rawCurrency)
                amount = try exchanger.exchange(asset)

                formatter.currency = rawCurrency
            }

            let text = formatter.format(amount)
            secondaryValue = text?.footnoteRegular(
                alignment: .right,
                lineBreakMode: .byTruncatingTail
            )
        } catch {
            secondaryValue = nil
        }
    }
}

extension AssetListItemViewModel {
    func getPlaceholder(
        _ asset: Asset
    ) -> ImagePlaceholder? {
        let title = asset.naming.name.isNilOrEmpty
            ? "title-unknown".localized
        : asset.naming.name

        let aPlaceholder = TextFormatter.assetShortName.format(title)

        guard let aPlaceholder = aPlaceholder else {
            return nil
        }

        let isCollectible = asset is CollectibleAsset
        let placeholderImage =
            isCollectible ?
            "placeholder-bg".uiImage :
            "asset-image-placeholder-border".uiImage
        let placeholderText: EditText = .attributedString(
            aPlaceholder
                .footnoteRegular(
                    alignment: .center
                )
        )
        return ImagePlaceholder(
            image: .init(asset: placeholderImage),
            text: placeholderText
        )
    }
}

extension AssetListItemViewModel {
    mutating func bindIcon(_ update: OptInBlockchainUpdate) {
        imageSource = AssetImageSource(asset: "asset-image-placeholder-border".uiImage)
    }

    mutating func bindTitle(_ update: OptInBlockchainUpdate) {
        title = AssetNameViewModel(update: update)
    }

    mutating func bindPrimaryValue(_ update: OptInBlockchainUpdate) {
        let statusText = "asset-add-confirmation-title".localized
        primaryValue = statusText.bodyRegular(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
    }
}

extension AssetListItemViewModel {
    mutating func bindIcon(_ update: OptOutBlockchainUpdate) {
        imageSource = AssetImageSource(asset: "asset-image-placeholder-border".uiImage)
    }

    mutating func bindTitle(_ update: OptOutBlockchainUpdate) {
        title = AssetNameViewModel(update: update)
    }

    mutating func bindPrimaryValue(_ update: OptOutBlockchainUpdate) {
        let statusText = "asset-removing-status".localized
        primaryValue = statusText.bodyRegular(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
    }
}
