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
    var overlayImage: UIImage? { get set }
    var is3DModeActionHidden: Bool { get set }
    var isFullScreenActionHidden: Bool { get set }
}

extension CollectibleMediaImagePreviewViewModel {
    mutating func bindOverlayImage(
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

    mutating func bindIs3DModeActionHidden(
        _ asset: CollectibleAsset
    ) {
        is3DModeActionHidden = !asset.mediaType.isSupported
    }

    mutating func bindIsFullScreenBadgeHidden(
        _ asset: CollectibleAsset
    ) {
        isFullScreenActionHidden = !asset.mediaType.isSupported
    }
}

extension CollectibleMediaImagePreviewViewModel {
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
