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

//   ASADiscoveryProfileViewModel.swift

import CoreGraphics
import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct ASADiscoveryProfileViewModel: ASAProfileViewModel {
    private(set) var icon: ImageSource?
    private(set) var name: RightAccessorizedLabelModel?
    private(set) var titleSeparator: TextProvider?
    private(set) var id: TextProvider?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?

    init() {}

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
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        bindSecondaryValue()
    }
}

extension ASADiscoveryProfileViewModel {
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
            let amount = try exchanger.exchange(
                asset,
                amount: 1
            )

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let text = currencyFormatter.format(amount)
            primaryValue = text?.titleSmallMedium()
        } catch {
            primaryValue = nil
        }
    }

    mutating func bindSecondaryValue() {
        secondaryValue = nil
    }
}

