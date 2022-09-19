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

//   CollectibleMediaErrorViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleMediaErrorViewModel:
    ViewModel,
    Hashable {
    private(set) var image: UIImage?
    private(set) var message: EditText?

    init(
        _ error: CollectibleMediaError
    ) {
        bindImage(error)
        bindMessage(error)
    }
}

extension CollectibleMediaErrorViewModel {
    private mutating func bindImage(
        _ error: CollectibleMediaError
    ) {
        image = error.image
    }

    private mutating func bindMessage(
        _ error: CollectibleMediaError
    ) {
        message = .attributedString(
            error.message
                .footnoteMedium()
        )
    }
}

enum CollectibleMediaError: Error {
    case unsupported
    case notOwner(isWatchAccount: Bool)

    var message: String {
        switch self {
        case .unsupported:
            return "collectible-detail-error-media-type".localized
        case .notOwner(let isWatchAccount):
            if isWatchAccount {
                return "collectible-detail-error-not-owner-watch-account".localized
            } else {
                return "collectible-detail-error-not-owner".localized
            }
        }
    }

    var image: UIImage {
        return "badge-warning".uiImage.template
    }
}
