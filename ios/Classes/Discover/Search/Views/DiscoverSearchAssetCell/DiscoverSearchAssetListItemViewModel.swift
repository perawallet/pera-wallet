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

//   DiscoverSearchAssetListItemViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import MacaroonUtils
import Prism
import UIKit

struct DiscoverSearchAssetListItemViewModel: PrimaryListItemViewModel {
    private(set) var imageSource: ImageSource?
    private(set) var title: PrimaryTitleViewModel?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?

    init(
        asset: AssetDecoration,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindImageSource(asset: asset)
        bindTitle(asset: asset)
        bindPrimaryValue(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue(asset: asset)
    }
}

extension DiscoverSearchAssetListItemViewModel {
    mutating func bindImageSource(asset: AssetDecoration) {
        let iconURL: URL?
        let iconShape: ImageShape
        if let collectibleInfo = asset.collectible {
            iconURL = collectibleInfo.thumbnailImage
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
        /// <todo>
        /// Find a better way of formatting name
        let title = asset.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.name
        let placeholderText = TextFormatter.assetShortName.format(title)
        let placeholder = ImagePlaceholder.init(
            image: .init(asset: "asset-image-placeholder-border".uiImage),
            text: .string(placeholderText)
        )
        imageSource = DefaultURLImageSource(url: url, shape: iconShape, placeholder: placeholder)
    }

    mutating func bindTitle(asset: AssetDecoration) {
        title = DiscoverSearchAssetNameListItemViewModel(asset: asset)
    }

    mutating func bindPrimaryValue(
        asset: AssetDecoration,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let currencyValue = currency.primaryValue else {
            primaryValue = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()
            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(asset)

            currencyFormatter.formattingContext = .listItem
            currencyFormatter.currency = rawCurrency

            let text = currencyFormatter.format(amount)
            primaryValue = text?.bodyMedium(
                alignment: .right,
                lineBreakMode: .byTruncatingTail
            )
        } catch {
            primaryValue = nil
        }
    }

    mutating func bindSecondaryValue(asset: AssetDecoration) {
        secondaryValue = nil
    }
}
