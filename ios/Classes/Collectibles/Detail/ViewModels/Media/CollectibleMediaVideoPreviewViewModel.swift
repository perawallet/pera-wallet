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

struct CollectibleMediaVideoPreviewViewModel: ViewModel {
    private(set) var url: URL?
    private(set) var isOwned: Bool = true

    init(
        asset: CollectibleAsset,
        media: Media
    ) {
        bindURL(media)
        bindOwned(asset)
    }
}

extension CollectibleMediaVideoPreviewViewModel {
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
}
