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
    let icon: AssetImage
    let verifiedIcon: UIImage?
    let title: String?
    let subtitle: String?
    let primaryAccessory: String?
    let secondaryAccessory: String?
    let currencyAmount: Decimal
    let asset: Asset?
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
            bindSecondaryAccessory(preview.secondaryAccessory)
            return
        }

        /// <todo>
        /// We should think about the draft approach. (e.g Create container views for each case.)
        if let standardAssetPreviewAddition = model as? StandardAssetPreviewAdditionDraft {
            bindAssetID(standardAssetPreviewAddition)
            bindVerifiedIcon(standardAssetPreviewAddition)
            bindTitle(standardAssetPreviewAddition)
            bindImage(standardAssetPreviewAddition)
            bindSubtitle(standardAssetPreviewAddition)
            bindPrimaryAccessory(standardAssetPreviewAddition)
            return
        }

        if let collectibleAssetPreviewAddition = model as? CollectibleAssetPreviewAdditionDraft {
            bindAssetID(collectibleAssetPreviewAddition)
            bindVerifiedIcon(collectibleAssetPreviewAddition)
            bindTitle(collectibleAssetPreviewAddition)
            bindImage(collectibleAssetPreviewAddition)
            bindSubtitle(collectibleAssetPreviewAddition)
            bindPrimaryAccessory(collectibleAssetPreviewAddition)
        }

        if let collectibleAssetSelectionDraft = model as? CollectibleAssetPreviewSelectionDraft {
            bindAssetID(collectibleAssetSelectionDraft)
            bindVerifiedIcon(collectibleAssetSelectionDraft)
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
    private mutating func bindAssetImageView(
        _ image: AssetImage
    ) {
        assetImageViewModel = AssetImageLargeViewModel(
            image: image
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
    
    private mutating func bindPrimaryAccessory(
        _ accessory: String?
    ) {
        guard let accessory = accessory else {
            return
        }
        
        let font = Fonts.DMMono.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        primaryAccessory = .attributedString(
            accessory
                .attributed([
                    .textColor(AppColors.Components.Text.main.uiColor),
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

    private mutating func bindSecondaryAccessory(_ accessory: String?) {
        guard let accessory = accessory else {
            return
        }
        
        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        secondaryAccessory = .attributedString(
            accessory
                .attributed([
                    .textColor(AppColors.Components.Text.grayLighter.uiColor),
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
        _ assetAddition: StandardAssetPreviewAdditionDraft
    ) {
        assetID = assetAddition.asset.id
    }

    private mutating func bindVerifiedIcon(
        _ assetAddition: StandardAssetPreviewAdditionDraft
    ) {
        let icon = assetAddition.asset.presentation.isVerified ? img("icon-verified-shield") : nil

        bindVerifiedIcon(icon)
    }

    private mutating func bindImage(
        _ assetAddition: StandardAssetPreviewAdditionDraft
    ) {
        bindAssetImageView(
            .url(
                nil,
                title: assetAddition.asset.presentation.name
            )
        )
    }

    private mutating func bindTitle(
        _ assetAddition: StandardAssetPreviewAdditionDraft
    ) {
        bindTitle(assetAddition.asset.presentation.name)
    }

    private mutating func bindSubtitle(
        _ assetAddition: StandardAssetPreviewAdditionDraft
    ) {
        bindSubtitle(assetAddition.asset.presentation.unitName)
    }

    private mutating func bindPrimaryAccessory(
        _ assetAddition: StandardAssetPreviewAdditionDraft
    ) {
        let accessory =  String(assetAddition.asset.id)

        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.18

        primaryAccessory = .attributedString(
            accessory
                .attributed([
                    .textColor(AppColors.Components.Text.gray),
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
        _ assetAddition: CollectibleAssetPreviewAdditionDraft
    ) {
        assetID = assetAddition.asset.id
    }

    private mutating func bindVerifiedIcon(
        _ assetAddition: CollectibleAssetPreviewAdditionDraft
    ) {
        let icon = assetAddition.asset.presentation.isVerified ? img("icon-verified-shield") : nil

        bindVerifiedIcon(icon)
    }

    private mutating func bindImage(
        _ assetAddition: CollectibleAssetPreviewAdditionDraft
    ) {
        let asset = assetAddition.asset

        bindAssetImageView(
            .url(
                asset.thumbnailImage,
                title: asset.presentation.name
            )
        )
    }

    private mutating func bindTitle(
        _ assetAddition: CollectibleAssetPreviewAdditionDraft
    ) {
        bindTitle(assetAddition.asset.presentation.name)
    }

    private mutating func bindSubtitle(
        _ assetAddition: CollectibleAssetPreviewAdditionDraft
    ) {
        bindSubtitle(assetAddition.asset.presentation.unitName)
    }

    private mutating func bindPrimaryAccessory(
        _ assetAddition: CollectibleAssetPreviewAdditionDraft
    ) {
        let accessory =  String(assetAddition.asset.id)

        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.18

        primaryAccessory = .attributedString(
            accessory
                .attributed([
                    .textColor(AppColors.Components.Text.gray),
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
        bindAssetImageView(
            .url(asset.thumbnailImage, title: asset.name)
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
        bindSecondaryAccessory(String(asset.id))
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetID(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        assetID = draft.asset.id
    }

    private mutating func bindVerifiedIcon(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        let icon = draft.asset.presentation.isVerified ? img("icon-verified-shield") : nil

        bindVerifiedIcon(icon)
    }

    private mutating func bindImage(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        bindAssetImageView(
            .url(draft.asset.thumbnailImage, title: draft.asset.name)
        )
    }

    private mutating func bindTitle(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        bindTitle(draft.asset.name)
    }

    private mutating func bindSubtitle(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        bindSubtitle("ID \(draft.asset.id)")
    }

    private mutating func bindPrimaryAccessory(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        let asset = draft.asset

        let formatter = draft.currencyFormatter
        formatter.formattingContext = draft.currencyFormattingContext ?? .listItem
        formatter.currency = nil

        let amount = formatter.format(asset.amountWithFraction)

        bindPrimaryAccessory(amount)
    }

    private mutating func bindSecondaryAccessory(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        guard let currencyValue = draft.currency.primaryValue else {
            bindSecondaryAccessory(nil)
            return
        }

        let asset = draft.asset

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(asset)

            let formatter = draft.currencyFormatter
            formatter.formattingContext = draft.currencyFormattingContext ?? .listItem
            formatter.currency = rawCurrency

            if amount > 0 {
                let value = formatter.format(amount)
                bindSecondaryAccessory(value)
            } else {
                bindSecondaryAccessory(nil)
            }
        } catch {
            bindSecondaryAccessory(nil)
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

struct CollectibleAssetPreviewSelectionDraft {
    let asset: CollectibleAsset
    let currency: CurrencyProvider
    let currencyFormatter: CurrencyFormatter
    let currencyFormattingContext: CurrencyFormattingContext?

    init(
        asset: CollectibleAsset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        currencyFormattingContext: CurrencyFormattingContext? = nil
    ) {
        self.asset = asset
        self.currency = currency
        self.currencyFormatter = currencyFormatter
        self.currencyFormattingContext = currencyFormattingContext
    }
}

struct StandardAssetPreviewAdditionDraft {
    let asset: StandardAsset
}

struct CollectibleAssetPreviewAdditionDraft {
    let asset: CollectibleAsset
}
