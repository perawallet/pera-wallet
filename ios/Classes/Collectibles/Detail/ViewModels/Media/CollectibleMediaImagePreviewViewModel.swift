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

protocol CollectibleMediaImagePreviewViewModel: ViewModel {
    var image: ImageSource? { get set }
    var displaysOffColorMedia: Bool { get set }
    var isFullScreenBadgeHidden: Bool { get set }
}

extension CollectibleMediaImagePreviewViewModel {
    mutating func bindDisplaysOffColorMedia(
        _ asset: CollectibleAsset,
        _ accountCollectibleStatus: AccountCollectibleStatus
    ) {
        switch accountCollectibleStatus {
        case .notOptedIn, .owned:
            displaysOffColorMedia = false
        case .optedIn:
            displaysOffColorMedia = true
        }
    }

    mutating func bindIsFullScreenBadgeHidden(
        _ asset: CollectibleAsset
    ) {
        isFullScreenBadgeHidden = !asset.mediaType.isSupported
    }

    func getPlaceholder(
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
