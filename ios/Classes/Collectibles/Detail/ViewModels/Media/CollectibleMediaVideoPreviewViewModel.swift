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

//   CollectibleMediaVideoPreviewViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

struct CollectibleMediaVideoPreviewViewModel: ViewModel {
    private(set) var placeholder: ImagePlaceholder?
    private(set) var url: URL?
    private(set) var isOwned: Bool = true
    private(set) var isFullScreenBadgeHidden: Bool = false

    init(
        asset: CollectibleAsset,
        media: Media
    ) {
        bindPlaceholder(asset)
        bindURL(media)
        bindOwned(asset)
        bindIsFullScreenBadgeHidden(asset)
    }
}

extension CollectibleMediaVideoPreviewViewModel {
    private mutating func bindPlaceholder(
        _ asset: CollectibleAsset
    ) {
        let placeholder = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        self.placeholder = getPlaceholder(placeholder)
    }

    private mutating func bindURL(
        _ media: Media
    ) {
        if media.type != .video {
            return
        }

        url = media.downloadURL
    }

    private mutating func bindOwned(
        _ asset: CollectibleAsset
    ) {
        isOwned = asset.isOwned
    }

    private mutating func bindIsFullScreenBadgeHidden(
        _ asset: CollectibleAsset
    ) {
        isFullScreenBadgeHidden = !asset.mediaType.isSupported
    }
}

extension CollectibleMediaVideoPreviewViewModel {
    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> ImagePlaceholder {
        let placeholderText: EditText = .attributedString(
            aPlaceholder
                .bodyLargeRegular(
                    alignment: .center
                )
        )

        return ImagePlaceholder(
            image: nil,
            text: placeholderText
        )
    }
}
