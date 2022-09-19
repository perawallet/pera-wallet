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
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct CollectibleListItemViewModel:
    ViewModel,
    Hashable {
    private(set) var assetID: AssetID?
    private(set) var image: ImageSource?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var mediaType: MediaType?
    private(set) var topLeftBadge: UIImage?
    private(set) var bottomLeftBadge: UIImage?
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

extension CollectibleListItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(assetID)
        hasher.combine(title)
        hasher.combine(subtitle)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.assetID == rhs.assetID &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle
    }
}

extension CollectibleListItemViewModel {
    mutating func bind<T>(
        imageSize: CGSize,
        model: T
    ) {
        if let asset = model as? CollectibleAsset {
            bindAssetID(asset)
            bindImage(imageSize: imageSize, asset: asset)
            bindTitle(asset)
            bindSubtitle(asset)
            bindMediaType(asset)
            bindTopLeftBadge(asset)
            bindBottomLeftBadge(asset)
            bindPendingTitle()
            return
        }
    }
}

extension CollectibleListItemViewModel {
    private mutating func bindAssetID(
        _ asset: CollectibleAsset
    ) {
        assetID = getAssetID(asset)
    }

    private mutating func bindImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) {
        image = getImage(imageSize: imageSize, asset: asset)
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        title = getTitle(asset)
    }

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        subtitle = getSubtitle(asset)
    }

    private mutating func bindTopLeftBadge(
        _ asset: CollectibleAsset
    ) {
        topLeftBadge = getTopLeftBadge(asset)
    }

    private mutating func bindBottomLeftBadge(
        _ asset: CollectibleAsset
    ) {
        if !asset.isOwned {
            bottomLeftBadge = "badge-warning".uiImage.template
        } else if !asset.mediaType.isSupported {
            bottomLeftBadge = "badge-warning".uiImage.template
        }
    }

    private mutating func bindMediaType(
        _ asset: CollectibleAsset
    ) {
        mediaType = getMediaType(asset)
    }

    private mutating func bindPendingTitle() {
        pendingTitle = .attributedString(
            "collectible-list-item-pending-title"
                .localized
                .footnoteMedium(lineBreakMode: .byTruncatingTail)
        )
    }
}

extension CollectibleListItemViewModel {
    func getAssetID(
        _ asset: CollectibleAsset
    ) -> AssetID? {
        return asset.id
    }

    func getImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) -> ImageSource? {
        let placeholder = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        if let thumbnailImage = asset.thumbnailImage {
            let prismURL = PrismURL(baseURL: thumbnailImage)
                .setExpectedImageSize(imageSize)
                .build()

            return PNGImageSource(
                url: prismURL,
                shape: .rounded(4),
                placeholder: getPlaceholder(placeholder)
            )
        }

        let imageSource =
        PNGImageSource(
            url: nil,
            placeholder: getPlaceholder(placeholder)
        )

        return imageSource
    }

    func getTitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        guard let collectionName = asset.collectionName,
              !collectionName.isEmptyOrBlank else {
                  return nil
              }

        return .attributedString(
            collectionName
                .footnoteRegular()
        )
    }

    func getSubtitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        let subtitle = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        return .attributedString(
            subtitle
                .bodyRegular()
        )
    }

    func getTopLeftBadge(
        _ asset: CollectibleAsset
    ) -> UIImage? {
        switch asset.mediaType {
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

    func getMediaType(
        _ asset: CollectibleAsset
    ) -> MediaType? {
        return asset.mediaType
    }

    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> ImagePlaceholder {
        let placeholderText: EditText = .attributedString(
            aPlaceholder
                .footnoteRegular(
                    alignment: .center
                )
        )

        return ImagePlaceholder(
            image: nil,
            text: placeholderText
        )
    }
}
