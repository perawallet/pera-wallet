// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleMediaAudioPreviewViewModel.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CollectibleMediaAudioPreviewViewModel: ViewModel {
    private(set) var placeholder: ImagePlaceholder?
    private(set) var url: URL?
    private(set) var overlayImage: UIImage?

    init(
        asset: CollectibleAsset,
        accountCollectibleStatus: AccountCollectibleStatus,
        media: Media
    ) {
        bindPlaceholder(asset)
        bindURL(media)
        bindOverlayImage(asset, accountCollectibleStatus)
    }
}

extension CollectibleMediaAudioPreviewViewModel {
    private mutating func bindPlaceholder(_ asset: CollectibleAsset) {
        let placeholder = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))
        
        self.placeholder = getPlaceholder(placeholder)
    }
    
    private mutating func bindURL(_ media: Media) {
        if media.type != .audio {
            self.url = nil
            return
        }
        
        self.url = media.downloadURL
    }
    
    private mutating func bindOverlayImage(
        _ asset: CollectibleAsset,
        _ accountCollectibleStatus: AccountCollectibleStatus
    ) {
        switch accountCollectibleStatus {
        case .notOptedIn,
             .optingOut,
             .optingIn,
             .owned:
            overlayImage = nil
        case .optedIn:
            overlayImage = "overlay-bg".uiImage
        }
    }
}

extension CollectibleMediaAudioPreviewViewModel {
    private func getPlaceholder(_ aPlaceholder: String) -> ImagePlaceholder {
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
