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

//   CollectibleGridItemViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct CollectibleGridItemViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var overlay: UIImage?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var topLeftBadgeCanvas: UIImage?
    private(set) var topLeftBadge: UIImage?
    private(set) var bottomLeftBadgeCanvas: UIImage?
    private(set) var bottomLeftBadge: UIImage?
    private(set) var amountCanvas: UIImage?
    private(set) var amount: EditText?
    private(set) var pendingTitle: EditText?

    init<T>(
        imageSize: CGSize,
        model: T
    ) {
        bind(
            imageSize: imageSize,
            model: model
        )
    }
}

extension CollectibleGridItemViewModel {
    mutating func bind<T>(
        imageSize: CGSize,
        model: T
    ) {
        if let item = model as? CollectibleAssetItem {
            bindImage(imageSize: imageSize, item: item)
            bindOverlay(item: item)
            bindAmount(item)
            bindTitle(item)
            bindSubtitle(item)
            bindTopLeftBadge(item)
            bindBottomLeftBadge(item)
            return
        }

        if let update = model as? OptInBlockchainUpdate {
            bindIcon(imageSize: imageSize, update: update)
            bindTitle(update)
            bindSubtitle(update)
            bindPendingTitle()
            return
        }

        if let update = model as? OptOutBlockchainUpdate {
            bindIcon(imageSize: imageSize, update: update)
            bindPrimaryTitle(update)
            bindSecondaryTitle(update)
            bindPendingTitle()
            return
        }

        if let update = model as? SendPureCollectibleAssetBlockchainUpdate {
            bindIcon(imageSize: imageSize, update: update)
            bindPrimaryTitle(update)
            bindSecondaryTitle(update)
            bindPendingTitle()
        }
    }
}

extension CollectibleGridItemViewModel {
    private mutating func bindAmount(
        _ item: CollectibleAssetItem
    ) {
        let asset = item.asset

        if asset.isPure || !asset.isOwned {
            amount = nil
            amountCanvas = nil
            return
        }
        
        let formatter = item.amountFormatter
        let formattedAmount =
            formatter
                .format(asset.decimalAmount)
                .unwrap { "x" + $0 }

        guard let formattedAmount else {
            amount = nil
            amountCanvas = nil
            return
        }

        amount = .attributedString(
            formattedAmount
                .footnoteBold(lineBreakMode: .byTruncatingTail)
        )

        amountCanvas = "badge-bg".uiImage
    }

    private mutating func bindImage(
        imageSize: CGSize,
        item: CollectibleAssetItem
    ) {
        image = getImage(imageSize: imageSize, asset: item.asset)
    }

    private mutating func bindOverlay(
        item: CollectibleAssetItem
    ) {
        overlay = !item.asset.isOwned ? "overlay-bg".uiImage : nil
    }

    private mutating func bindTitle(
        _ item: CollectibleAssetItem
    ) {
        title = getTitle(item.asset)
    }

    private mutating func bindSubtitle(
        _ item: CollectibleAssetItem
    ) {
        subtitle = getSubtitle(item.asset)
    }

    private mutating func bindTopLeftBadge(
        _ item: CollectibleAssetItem
    ) {
        topLeftBadge = getTopLeftBadge(item.asset)

        if topLeftBadge != nil {
            topLeftBadgeCanvas = "badge-bg".uiImage
        }
    }

    private mutating func bindBottomLeftBadge(
        _ item: CollectibleAssetItem
    ) {
        let account = item.account
        let asset = item.asset

        if account.authorization.isWatch {
            bottomLeftBadge = "badge-eye".uiImage
            bottomLeftBadgeCanvas = "badge-bg".uiImage
            return
        }

        if !asset.mediaType.isSupported || !asset.isOwned {
            bottomLeftBadge = "badge-warning".templateImage
            bottomLeftBadgeCanvas = "badge-bg".uiImage
            return
        }
    }

    private mutating func bindPendingTitle() {
        pendingTitle = .attributedString(
            "collectible-list-item-pending-title"
                .localized
                .footnoteBold(lineBreakMode: .byTruncatingTail)
        )
    }
}

extension CollectibleGridItemViewModel {
    func getImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) -> ImageSource? {
        let placeholder = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        if let thumbnailImage = asset.thumbnailImage {
            let prismURL = PrismURL(baseURL: thumbnailImage)
                .setExpectedImageSize(imageSize)
                .build()

            return DefaultURLImageSource(
                url: prismURL,
                shape: .rounded(4),
                placeholder: getPlaceholder(placeholder)
            )
        }

        let imageSource =
        DefaultURLImageSource(
            url: nil,
            placeholder: getPlaceholder(placeholder)
        )

        return imageSource
    }

    func getTitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        guard let collectionName = asset.collection?.name,
              !collectionName.isEmptyOrBlank else {
            return nil
        }

        return .attributedString(
            collectionName
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
        )
    }

    func getSubtitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        let subtitle = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        if asset.verificationTier.isSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        } else {
            attributes.insert(.textColor(Colors.Text.main))
        }

        let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
        let assetText = subtitle.attributed(attributes)
        let text = [ destroyedText, assetText ].compound(" ")

        return .attributedString(text)
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

    func getTopLeftBadge(
        _ asset: CollectibleAsset
    ) -> UIImage? {
        switch asset.mediaType {
        case .audio:
            return "badge-audio".uiImage
        case .video:
            return "badge-video".uiImage
        case .mixed:
            return "badge-mixed".uiImage
        case .unknown:
            return "badge-unknown".uiImage
        default:
            return nil
        }
    }

    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> ImagePlaceholder {
        let placeholderImage = AssetImageSource(asset: "placeholder-bg".uiImage)
        let placeholderText: EditText = .attributedString(
            aPlaceholder
                .footnoteRegular(
                    alignment: .center
                )
        )

        return ImagePlaceholder(
            image: placeholderImage,
            text: placeholderText
        )
    }
}

extension CollectibleGridItemViewModel {
    mutating func bindIcon(imageSize: CGSize, update: OptInBlockchainUpdate) {
        let placeholder = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag
        let url = update.collectibleAssetThumbnailImage.unwrap {
            PrismURL(baseURL: $0)
                .setExpectedImageSize(imageSize)
                .build()
         }
        image = DefaultURLImageSource(
            url: url,
            shape: url == nil ? .original : .rounded(4),
            placeholder: getPlaceholder(placeholder)
        )
    }

    mutating func bindTitle(_ update: OptInBlockchainUpdate) {
        let collectionName = update.collectibleAssetCollectionName.unwrapNonEmptyString()
        title = collectionName.unwrap {
            .attributedString(
                $0.footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
            )
        }
    }

    mutating func bindSubtitle(_ update: OptInBlockchainUpdate) {
        let subtitle = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag

        self.subtitle = .attributedString(
            subtitle
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
    }
}

extension CollectibleGridItemViewModel {
    mutating func bindIcon(imageSize: CGSize, update: OptOutBlockchainUpdate) {
        let placeholder = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag
        let url = update.collectibleAssetThumbnailImage.unwrap {
            PrismURL(baseURL: $0)
                .setExpectedImageSize(imageSize)
                .build()
         }
        image = DefaultURLImageSource(
            url: url,
            shape: url == nil ? .original : .rounded(4),
            placeholder: getPlaceholder(placeholder)
        )
    }

    mutating func bindPrimaryTitle(_ update: OptOutBlockchainUpdate) {
        let collectionName = update.collectibleAssetCollectionName.unwrapNonEmptyString()
        title = collectionName.unwrap {
            .attributedString(
                $0.footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
            )
        }
    }

    mutating func bindSecondaryTitle(_ update: OptOutBlockchainUpdate) {
        let subtitle = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag

        self.subtitle = .attributedString(
            subtitle
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
    }
}

extension CollectibleGridItemViewModel {
    mutating func bindIcon(imageSize: CGSize, update: SendPureCollectibleAssetBlockchainUpdate) {
        let placeholder = update.assetTitle ?? update.assetName ?? update.assetID.stringWithHashtag
        let url = update.assetThumbnailImage.unwrap {
            PrismURL(baseURL: $0)
                .setExpectedImageSize(imageSize)
                .build()
         }
        image = DefaultURLImageSource(
            url: url,
            shape: url == nil ? .original : .rounded(4),
            placeholder: getPlaceholder(placeholder)
        )
    }

    mutating func bindPrimaryTitle(_ update: SendPureCollectibleAssetBlockchainUpdate) {
        let collectionName = update.assetCollectionName.unwrapNonEmptyString()
        title = collectionName.unwrap {
            .attributedString(
                $0.footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
            )
        }
    }

    mutating func bindSecondaryTitle(_ update: SendPureCollectibleAssetBlockchainUpdate) {
        let subtitle = update.assetTitle ?? update.assetName ?? update.assetID.stringWithHashtag

        self.subtitle = .attributedString(
            subtitle
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
    }
}
