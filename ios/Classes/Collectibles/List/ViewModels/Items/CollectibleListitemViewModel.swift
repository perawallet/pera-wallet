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

import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

protocol CollectibleListItemViewModel: ViewModel {
    var assetID: AssetID? { get }
    var image: ImageSource? { get }
    var title: EditText? { get }
    var subtitle: EditText? { get }
    var mediaType: MediaType? { get }
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

        let size: ImageSize

        if imageSize.width <= 0 ||
            imageSize.height <= 0 {
            size = .original
        } else {
            size = .resize(imageSize, .aspectFit)
        }

        if let thumbnailImage = asset.thumbnailImage {
            let prismURL = PrismURL(baseURL: thumbnailImage)
                .setExpectedImageSize(imageSize)
                .setImageQuality(.normal)
                .setResizeMode(.fit)
                .build()

            return PNGImageSource(
                url: prismURL,
                size: size,
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

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        return .attributedString(
            collectionName
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    func getSubtitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        let subtitle = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            subtitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
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
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        let placeholderText: EditText = .attributedString(
            aPlaceholder.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(.center),
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )

        return ImagePlaceholder(
            image: nil,
            text: placeholderText
        )
    }
}

fileprivate extension AssetID {
    var stringWithHashtag: String {
        "#".appending(String(self))
    }
}
