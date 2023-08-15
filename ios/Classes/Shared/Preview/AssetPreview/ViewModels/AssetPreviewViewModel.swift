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
import MacaroonURLImage
import Prism
import UIKit

struct AssetPreviewModel {
    let icon: AssetImage
    let verificationTier: AssetVerificationTier
    let title: String?
    let subtitle: String?
    let primaryAccessory: String?
    let secondaryAccessory: String?
    let currencyAmount: Decimal
    let asset: Asset?
}

/// <todo> Use new list item structure
struct AssetPreviewViewModel:
    BindableViewModel,
    Hashable {
    private(set) var assetID: AssetID?
    private(set) var imageSource: ImageSource?
    private(set) var verificationTierIcon: UIImage?
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
            bindTitle(
                title: preview.title,
                isAssetSuspicious: preview.verificationTier.isSuspicious,
                isAssetDestroyed: preview.asset?.isDestroyed ?? false
            )
            bindImageSource(preview.asset)
            bindVerificationTierIcon(preview.verificationTier)
            bindSubtitle(preview.subtitle)
            bindPrimaryAccessory(preview.primaryAccessory)
            bindSecondaryAccessory(preview.secondaryAccessory)
            return
        }
    }
}

extension AssetPreviewViewModel {
    private mutating func bindImageSource(
        _ asset: Asset?
    ) {
        guard let asset = asset else {
            imageSource = nil
            return
        }

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
    
    private mutating func bindVerificationTierIcon(
        _ verificationTier: AssetVerificationTier
    ) {
        self.verificationTierIcon = getVerificationTierIcon(verificationTier)
    }
    
    private mutating func bindTitle(
        title: String?,
        isAssetSuspicious: Bool,
        isAssetDestroyed: Bool
    ) {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        if isAssetSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        } else {
            attributes.insert(.textColor(Colors.Text.main))
        }

        let aTitle = title.unwrapNonEmptyString() ?? "title-unknown".localized

        let destroyedText = makeDestroyedAssetTextIfNeeded(isAssetDestroyed)
        let assetText = aTitle.attributed(attributes)
        let text = [ destroyedText, assetText ].compound(" ")

        self.title = .attributedString(text)
    }

    private func makeDestroyedAssetTextIfNeeded(_ isAssetDestroyed: Bool) -> NSAttributedString? {
        guard isAssetDestroyed else {
            return nil
        }

        let title = "title-deleted-with-parantheses".localized
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.negative))
        return title.attributed(attributes)
    }

    private mutating func bindSubtitle(_ subtitle: String?) {
        guard let subtitle = subtitle else {
            return
        }

        self.subtitle = .attributedString(
            subtitle
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
    
    private mutating func bindPrimaryAccessory(
        _ accessory: String?
    ) {
        guard let accessory = accessory else {
            return
        }

        var attributes = Typography.bodyMonoRegularAttributes(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
        attributes.formUnion([ .textColor(Colors.Text.main) ])

        primaryAccessory = .attributedString(
            accessory
                .attributed(
                    attributes
                )
        )
    }

    private mutating func bindSecondaryAccessory(_ accessory: String?) {
        guard let accessory = accessory else {
            return
        }
        

        var attributes = Typography.footnoteMonoRegularAttributes(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
        attributes.formUnion([ .textColor(Colors.Text.grayLighter) ])
        
        secondaryAccessory = .attributedString(
            accessory
                .attributed(
                    attributes
                )
        )
    }
}

extension AssetPreviewViewModel {
    func getPlaceholder(
        _ asset: Asset
    ) -> ImagePlaceholder? {
        let title =
            asset.naming.name.isNilOrEmpty
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
            image: AssetImageSource(asset: placeholderImage),
            text: placeholderText
        )
    }
}

extension AssetPreviewViewModel {
    private func getVerificationTierIcon(
        _ verificationTier: AssetVerificationTier
    ) -> UIImage? {
        switch verificationTier {
        case .trusted: return "icon-trusted".uiImage
        case .verified: return "icon-verified".uiImage
        case .unverified: return nil
        case .suspicious: return "icon-suspicious".uiImage
        }
    }
}

extension AssetPreviewViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(assetID)
        hasher.combine(verificationTierIcon)
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
        lhs.verificationTierIcon == rhs.verificationTierIcon &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.primaryAccessory == rhs.primaryAccessory &&
        lhs.secondaryAccessory == rhs.secondaryAccessory
    }
}
