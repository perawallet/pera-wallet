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

//   SelectAssetListItemViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct SelectAssetListItemViewModel:
    PrimaryListItemViewModel,
    Hashable {
    var imageSource: ImageSource?
    var title: PrimaryTitleViewModel?
    var primaryValue: TextProvider?
    var secondaryValue: TextProvider?
    var asset: Asset?

    init(
        item: AssetItem,
        account: Account
    ) {
        bindImageSource(item)
        bindTitle(item)
        bindPrimaryValue(
            item,
            account: account
        )
        bindSecondaryValue(
            item,
            account: account
        )

        asset = item.asset
    }

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title?.primaryTitle?.string)
        hasher.combine(title?.secondaryTitle?.string)
        hasher.combine(primaryValue?.string)
        hasher.combine(secondaryValue?.string)
        hasher.combine(asset?.id)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.title?.primaryTitle?.string == rhs.title?.primaryTitle?.string &&
            lhs.title?.secondaryTitle?.string == rhs.title?.secondaryTitle?.string &&
            lhs.primaryValue?.string == rhs.primaryValue?.string &&
            lhs.secondaryValue?.string == rhs.secondaryValue?.string &&
            lhs.asset?.id == rhs.asset?.id
    }
}

extension SelectAssetListItemViewModel {
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
        _ item: AssetItem,
        account: Account
    ) {
        if !account.isOptedIn(to: item.asset.id) {
            primaryValue = nil
            return
        }

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
        _ item: AssetItem,
        account: Account
    ) {
        let asset = item.asset

        if !account.isOptedIn(to: asset.id) {
            secondaryValue = nil
            return
        }

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem

        do {
            let exchanger: CurrencyExchanger
            if asset.isAlgo {
                guard let fiatRawCurrency = try item.currency.fiatValue?.unwrap() else {
                    secondaryValue = nil
                    return
                }

                exchanger = CurrencyExchanger(currency: fiatRawCurrency)

                formatter.currency = fiatRawCurrency
            } else {
                guard let currencyValue = item.currency.primaryValue else {
                    secondaryValue = nil
                    return
                }

                let rawCurrency = try currencyValue.unwrap()
                exchanger = CurrencyExchanger(currency: rawCurrency)

                formatter.currency = rawCurrency
            }

            let amount: Decimal
            if asset.isAlgo {
                amount = try exchanger.exchangeAlgo(amount: asset.decimalAmount)
            } else {
                amount = try exchanger.exchange(asset)
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

extension SelectAssetListItemViewModel {
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
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        )
        return ImagePlaceholder(
            image: .init(asset: placeholderImage),
            text: placeholderText
        )
    }
}
