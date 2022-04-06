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

//   CollectibleMediaImagePreviewViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct CollectibleMediaImagePreviewViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var isOwned: Bool = true

    init(
        imageSize: CGSize,
        asset: CollectibleAsset,
        media: Media?
    ) {
        bindImage(
            imageSize: imageSize,
            asset: asset,
            media: media
        )

        bindOwned(asset)
    }
}

extension CollectibleMediaImagePreviewViewModel {
    private mutating func bindImage(
        imageSize: CGSize,
        asset: CollectibleAsset,
        media: Media?
    ) {
        let placeholder = asset.title.fallback(asset.name.fallback("#\(String(asset.id))"))

        if let imageURL = media?.previewURL {
            let prismURL = PrismURL(baseURL: imageURL)
                .setExpectedImageSize(imageSize)
                .setImageQuality(.normal)
                .build()

            image = PNGImageSource(
                url: prismURL,
                shape: .rounded(4),
                placeholder: getPlaceholder(placeholder)
            )
            return
        }

        image = PNGImageSource(
            url: nil,
            placeholder: getPlaceholder(placeholder)
        )
    }

    private mutating func bindOwned(
        _ asset: CollectibleAsset
    ) {
        isOwned = asset.isOwned
    }
}

extension CollectibleMediaImagePreviewViewModel {
    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> ImagePlaceholder {
        let font = Fonts.DMSans.regular.make(19)
        let lineHeightMultiplier = 1.13

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
