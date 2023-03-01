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

//   CollectibleFullScreenImageViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct CollectibleFullScreenImageViewModel: ViewModel {
    private(set) var image: UIImage?
    private(set) var imageSource: ImageSource?

    init(
        draft: CollectibleFullScreenImageDraft,
        expectedImageSize: CGSize
    ) {
        bindImage(
            draft
        )
        bindImageSource(
            draft,
            expectedImageSize: expectedImageSize
        )
    }
}

extension CollectibleFullScreenImageViewModel {
    private mutating func bindImage(
        _ draft: CollectibleFullScreenImageDraft
    ) {
        self.image = draft.image
    }

    private mutating func bindImageSource(
        _ draft: CollectibleFullScreenImageDraft,
        expectedImageSize: CGSize
    ) {
        let media = draft.media

        let url = getURL(
            for: media,
            expectedImageSize: expectedImageSize
        )

        let shape: ImageShape
        switch media.mediaExtension {
        case .gif: shape = .original
        case .webp: shape = .rounded(4)
        default: shape = .rounded(4)
        }

        let asset = AssetImageSource(asset: draft.image)
        let placeholder = ImagePlaceholder(image: asset, text: nil)

        imageSource = DefaultURLImageSource(
            url: url,
            shape: shape,
            placeholder: placeholder
        )
    }
}

extension CollectibleFullScreenImageViewModel {
    private func getURL(
        for media: Media,
        expectedImageSize: CGSize
    ) -> URL? {
        guard let imageURL = media.previewURL else {
            return nil
        }

        return PrismURL(baseURL: imageURL)
            .setExpectedImageSize(expectedImageSize)
            .setImageQuality(.normal)
            .build()
    }
}
