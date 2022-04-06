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
//   AssetPreviewViewModel.swift

import MacaroonUIKit
import UIKit

struct AssetPreviewModel {
    let icon: AssetImage?
    let verifiedIcon: UIImage?
    let title: String?
    let subtitle: String?
    let primaryAccessory: String?
    let secondaryAccessory: String?
}

struct AssetPreviewViewModel:
    BindableViewModel,
    Hashable {
    private(set) var assetID: AssetID?
    private(set) var assetImageViewModel: AssetImageViewModel?
    private(set) var verifiedIcon: UIImage?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var primaryAccessory: EditText?
    private(set) var secondaryAccessory: EditText?

    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension AssetPreviewViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let preview = model as? AssetPreviewModel {
            bindTitle(preview.title)
            bindAssetImageView(preview.icon)
            bindVerifiedIcon(preview.verifiedIcon)
            bindSubtitle(preview.subtitle)
            bindPrimaryAccessory(preview.primaryAccessory)
            bindSecondAccessory(preview.secondaryAccessory)
            return
        }

        if let collectibleAsset = model as? CollectibleAsset {
            bindAssetID(collectibleAsset)
            bindTitle(collectibleAsset)
            bindImage(collectibleAsset)
            bindSubtitle(collectibleAsset)
            bindSecondAccessory(collectibleAsset)
            return
        }

        if let collectibleAssetSelectionDraft = model as? CollectibleAssetSelectionDraft {
            bindAssetID(collectibleAssetSelectionDraft)
            bindTitle(collectibleAssetSelectionDraft)
            bindImage(collectibleAssetSelectionDraft)
            bindSubtitle(collectibleAssetSelectionDraft)
            bindPrimaryAccessory(collectibleAssetSelectionDraft)
            bindSecondaryAccessory(collectibleAssetSelectionDraft)
            return
        }
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetImageView(_ image: AssetImage?) {
        let assetAbbreviationForImage = TextFormatter.assetShortName.format(title?.string)
        
        assetImageViewModel = AssetImageLargeViewModel(
            image: image,
            assetAbbreviatedName: assetAbbreviationForImage
        )
    }
    
    private mutating func bindVerifiedIcon(_ image: UIImage?) {
        self.verifiedIcon = image
    }
    
    private mutating func bindTitle(_ title: String?) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        self.title = .attributedString(
            (title.isNilOrEmpty ? "title-unknown".localized : title!)
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }
    
    private mutating func bindSubtitle(_ subtitle: String?) {
        guard let subtitle = subtitle else {
            return
        }
        
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        self.subtitle = .attributedString(
            subtitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }
    
    private mutating func bindPrimaryAccessory(_ accessory: String?) {
        guard let accessory = accessory else {
            return
        }
        
        let font = Fonts.DMMono.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        primaryAccessory = .attributedString(
            accessory
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.right)
                    ])
                ])
        )
    }

    private mutating func bindSecondAccessory(_ accessory: String?) {
        guard let accessory = accessory else {
            return
        }
        
        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        secondaryAccessory = .attributedString(
            accessory
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.right)
                    ])
                ])
        )
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetID(
        _ asset: CollectibleAsset
    ) {
        assetID = asset.id
    }

    private mutating func bindImage(
        _ asset: CollectibleAsset
    ) {
        var assetImage: AssetImage?

        if let thumbnailImage = asset.thumbnailImage {
            assetImage = .url(thumbnailImage)
        }

        let name = asset.name

        assetImageViewModel = AssetImageLargeViewModel(
            image: assetImage,
            assetAbbreviatedName: TextFormatter.assetShortName.format(
                (name.isNilOrEmpty ? "title-unknown".localized : name!)
            )
        )
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        bindTitle(asset.name)
    }

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        bindSubtitle(asset.unitName)
    }

    private mutating func bindSecondAccessory(
        _ asset: CollectibleAsset
    ) {
        bindSecondAccessory(String(asset.id))
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetID(
        _ draft: CollectibleAssetSelectionDraft
    ) {
        assetID = draft.asset.id
    }

    private mutating func bindImage(
        _ draft: CollectibleAssetSelectionDraft
    ) {
        var assetImage: AssetImage?

        if let thumbnailImage = draft.asset.thumbnailImage {
            assetImage = .url(thumbnailImage)
        }

        let name = draft.asset.name

        assetImageViewModel = AssetImageLargeViewModel(
            image: assetImage,
            assetAbbreviatedName: TextFormatter.assetShortName.format(
                (name.isNilOrEmpty ? "title-unknown".localized : name!)
            )
        )
    }

    private mutating func bindTitle(
        _ draft: CollectibleAssetSelectionDraft
    ) {
        bindTitle(draft.asset.name)
    }

    private mutating func bindSubtitle(
        _ draft: CollectibleAssetSelectionDraft
    ) {
        bindSubtitle("ID \(draft.asset.id)")
    }

    private mutating func bindPrimaryAccessory(
        _ draft: CollectibleAssetSelectionDraft
    ) {
        let asset = draft.asset

        let amount = asset.amount
            .assetAmount(fromFraction: asset.decimals)
            .abbreviatedFractionStringForLabel(fraction: asset.decimals)

        bindPrimaryAccessory(amount)
    }

    private mutating func bindSecondaryAccessory(
        _ draft: CollectibleAssetSelectionDraft
    ) {
        let asset = draft.asset

        guard let currency = draft.currency,
              let assetUSDValue = asset.usdValue,
              let currencyUSDValue = currency.usdValue else {
            return
        }

        let currencyValue =
        assetUSDValue *
        asset.amount.assetAmount(fromFraction: asset.decimals) *
        currencyUSDValue

        if currencyValue > 0 {
            bindPrimaryAccessory(
                currencyValue.abbreviatedCurrencyStringForLabel(with: currency.symbol)
            )
        }
    }
}

extension AssetPreviewViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(assetID)
        hasher.combine(assetImageViewModel?.image)
        hasher.combine(verifiedIcon)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(primaryAccessory)
        hasher.combine(secondaryAccessory)
    }

    static func == (
        lhs: AssetPreviewViewModel,
        rhs: AssetPreviewViewModel
    ) -> Bool {
        return lhs.assetID == rhs.assetID &&
        lhs.assetImageViewModel?.image == rhs.assetImageViewModel?.image &&
        lhs.verifiedIcon == rhs.verifiedIcon &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.primaryAccessory == rhs.primaryAccessory &&
        lhs.secondaryAccessory == rhs.secondaryAccessory
    }
}

struct CollectibleAssetSelectionDraft {
    let currency: Currency?
    let asset: CollectibleAsset
}
