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

//   CollectibleListItemViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct CollectibleListItemViewModel: ViewModel {
    private(set) var icon: ImageSource?
    private(set) var iconBottomRightBadge: UIImage?
    private(set) var iconOverlayImage: UIImage?
    private(set) var primaryTitle: TextProvider?
    private(set) var primaryTitleAccessory: Image?
    private(set) var secondaryTitle: TextProvider?
    private(set) var amount: TextProvider?

    init(item: CollectibleAssetItem) {
        bindIcon(item)
        bindBottomRightBadge(item)
        bindPrimaryTitle(item)
        bindPrimaryTitleAccessory(item)
        bindSecondaryTitle(item)
        bindAmount(item)
    }

    init(update: OptInBlockchainUpdate) {
        bindIcon(update)
        bindPrimaryTitle(update)
        bindPrimaryTitleAccessory(update)
        bindSecondaryTitle(update)
    }

    init(update: OptOutBlockchainUpdate) {
        bindIcon(update)
        bindPrimaryTitle(update)
        bindPrimaryTitleAccessory(update)
        bindSecondaryTitle(update)
    }

    init(update: SendPureCollectibleAssetBlockchainUpdate) {
        bindIcon(update)
        bindPrimaryTitle(update)
        bindPrimaryTitleAccessory(update)
        bindSecondaryTitle(update)
    }
}

extension CollectibleListItemViewModel {
    mutating func bindIcon(_ item: CollectibleAssetItem) {
        let asset = item.asset

        let iconURL: URL? = asset.thumbnailImage
        let iconShape: ImageShape =  .rounded(4)

        let size = CGSize(width: 40, height: 40)
        let url = PrismURL(baseURL: iconURL)?
            .setExpectedImageSize(size)
            .setImageQuality(.normal)
            .build()
        /// <todo>
        /// Find a better way of formatting name
        let title = asset.naming.name.unwrapNonEmptyString() ?? "title-unknown".localized
        let placeholderImage = AssetImageSource(asset: "placeholder-bg".uiImage)
        let placeholderText = TextFormatter.assetShortName.format(title)
        let placeholder = ImagePlaceholder.init(
            image: placeholderImage,
            text: .string(placeholderText)
        )
        icon = PNGImageSource(url: url, shape: iconShape, placeholder: placeholder)
    }

    private mutating func bindBottomRightBadge(
        _ item: CollectibleAssetItem
    ) {
        let account = item.account
        let asset = item.asset

        if account.isWatchAccount() {
            iconBottomRightBadge = "circle-badge-eye".uiImage

            if !asset.isOwned {
                iconOverlayImage = "overlay-bg".uiImage
            }
            return
        }

        if !asset.isOwned {
            iconBottomRightBadge = "circle-badge-warning".uiImage
            iconOverlayImage = "overlay-bg".uiImage
            return
        }

        if !asset.mediaType.isSupported {
            iconBottomRightBadge = "circle-badge-warning".uiImage
            return
        }
    }

    mutating func bindPrimaryTitle(_ item: CollectibleAssetItem) {
        primaryTitle = getPrimaryTitle(
            assetName: item.asset.naming.name,
            assetVerificationTier: item.asset
            .verificationTier
        )
    }

    mutating func bindPrimaryTitleAccessory(_ item: CollectibleAssetItem) {
        primaryTitleAccessory = getPrimaryTitleAccessory(item.asset.verificationTier)
    }

    mutating func bindSecondaryTitle(_ item: CollectibleAssetItem) {
        secondaryTitle = getSecondaryTitle(item.asset.naming.unitName)
    }

    mutating func bindAmount(_ item: CollectibleAssetItem) {
        let asset = item.asset

        if asset.isPure || !asset.isOwned {
            amount = nil
            return
        }

        let formatter = item.amountFormatter
        let formattedAmount = formatter
            .format(asset.decimalAmount)
            .unwrap { "x" + $0 }

        guard let formattedAmount else {
            amount = nil
            return
        }

        let amountText: String

        if secondaryTitle != nil {
            let separator = " • "
            amountText = separator.appending(formattedAmount)
        } else {
            amountText = formattedAmount
        }

        amount = amountText.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}

extension CollectibleListItemViewModel {
    mutating func bindIcon(_ update: OptInBlockchainUpdate) {
        icon = AssetImageSource(asset: "placeholder-bg".uiImage)
    }

    mutating func bindPrimaryTitle(_ update: OptInBlockchainUpdate) {
        primaryTitle = getPrimaryTitle(
            assetName: update.assetName,
            assetVerificationTier: update.assetVerificationTier
        )
    }

    mutating func bindPrimaryTitleAccessory(_ update: OptInBlockchainUpdate) {
        primaryTitleAccessory = getPrimaryTitleAccessory(update.assetVerificationTier)
    }

    mutating func bindSecondaryTitle(_ update: OptInBlockchainUpdate) {
        secondaryTitle = getSecondaryTitle(update.assetUnitName)
    }

    mutating func bindTitle(_ update: OptInBlockchainUpdate) {
        secondaryTitle = getSecondaryTitle(update.assetUnitName)
    }
}

extension CollectibleListItemViewModel {
    mutating func bindIcon(_ update: OptOutBlockchainUpdate) {
        icon = AssetImageSource(asset: "placeholder-bg".uiImage)
    }

    mutating func bindPrimaryTitle(_ update: OptOutBlockchainUpdate) {
        primaryTitle = getPrimaryTitle(
            assetName: update.assetName,
            assetVerificationTier: update.assetVerificationTier
        )
    }

    mutating func bindPrimaryTitleAccessory(_ update: OptOutBlockchainUpdate) {
        primaryTitleAccessory = getPrimaryTitleAccessory(update.assetVerificationTier)
    }

    mutating func bindSecondaryTitle(_ update: OptOutBlockchainUpdate) {
        secondaryTitle = getSecondaryTitle(update.assetUnitName)
    }
}

extension CollectibleListItemViewModel {
    mutating func bindIcon(_ update: SendPureCollectibleAssetBlockchainUpdate) {
        icon = AssetImageSource(asset: "placeholder-bg".uiImage)
    }

    mutating func bindPrimaryTitle(_ update: SendPureCollectibleAssetBlockchainUpdate) {
        primaryTitle = getPrimaryTitle(
            assetName: update.assetName,
            assetVerificationTier: update.assetVerificationTier
        )
    }

    mutating func bindPrimaryTitleAccessory(_ update: SendPureCollectibleAssetBlockchainUpdate) {
        primaryTitleAccessory = getPrimaryTitleAccessory(update.assetVerificationTier)
    }

    mutating func bindSecondaryTitle(_ update: SendPureCollectibleAssetBlockchainUpdate) {
        secondaryTitle = getSecondaryTitle(update.assetUnitName)
    }
}

extension CollectibleListItemViewModel {
    private func getPrimaryTitle(
        assetName: String?,
        assetVerificationTier: AssetVerificationTier
    ) -> TextProvider {
        let title = assetName.unwrapNonEmptyString() ?? "title-unknown".localized

        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        if assetVerificationTier.isSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        } else {
            attributes.insert(.textColor(Colors.Text.main))
        }

        return title.attributed(attributes)
    }

    private func getPrimaryTitleAccessory(_ assetVerificationTier: AssetVerificationTier) -> Image? {
        switch assetVerificationTier {
        case .trusted: return "icon-trusted"
        case .verified: return  "icon-verified"
        case .unverified: return nil
        case .suspicious: return "icon-suspicious"
        }
    }

    private func getSecondaryTitle(_ assetUnitName: String?) -> TextProvider? {
        return assetUnitName?.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
