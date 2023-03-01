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

struct CollectibleMediaStandardImagePreviewViewModel: CollectibleMediaImagePreviewViewModel {
    var image: ImageSource?
    var overlayImage: UIImage?
    var is3DModeActionHidden: Bool = false
    var isFullScreenActionHidden: Bool = false

    init(
        imageSize: CGSize,
        asset: CollectibleAsset,
        accountCollectibleStatus: AccountCollectibleStatus,
        media: Media?
    ) {
        bindImage(
            imageSize: imageSize,
            asset: asset,
            media: media
        )

        bindOverlayImage(asset, accountCollectibleStatus)
        bindIs3DModeActionHidden(asset)
        bindIsFullScreenBadgeHidden(asset)
    }
}

extension CollectibleMediaStandardImagePreviewViewModel {
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

            image = DefaultURLImageSource(
                url: prismURL,
                shape: .rounded(12),
                placeholder: getPlaceholder(placeholder)
            )
            return
        }

        image = DefaultURLImageSource(
            url: nil,
            placeholder: getPlaceholder(placeholder)
        )
    }
}
