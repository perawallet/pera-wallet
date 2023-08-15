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

//   ASAProfileNameViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASAProfileNameViewModel: RightAccessorizedLabelModel {
    private(set) var text: TextProvider?
    private(set) var accessory: ImageProvider?

    init(asset: Asset) {
        bindText(asset: asset)
        bindAccessory(asset: asset)
    }
}

extension ASAProfileNameViewModel {
    mutating func bindText(asset: Asset) {
        let name = asset.naming.name.unwrapNonEmptyString() ?? "title-unknown".localized

        var attributes = Typography.footnoteRegularAttributes()
        if asset.verificationTier.isSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        } else {
            attributes.insert(.textColor(Colors.Text.gray))
        }

        let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
        let assetText = name.attributed(attributes)

        text = [ destroyedText, assetText ].compound(" ")
    }

    private func makeDestroyedAssetTextIfNeeded(_ isAssetDestroyed: Bool) -> NSAttributedString? {
        guard isAssetDestroyed else {
            return nil
        }

        let title = "title-deleted-with-parantheses".localized
        var attributes = Typography.footnoteMediumAttributes()
        attributes.insert(.textColor(Colors.Helpers.negative))
        return title.attributed(attributes)
    }

    mutating func bindAccessory(asset: Asset) {
        let icon: Image?
        switch asset.verificationTier {
        case .trusted: icon = "icon-trusted"
        case .verified: icon = "icon-verified"
        case .unverified: icon = nil
        case .suspicious: icon = "icon-suspicious"
        }
        accessory = icon?.uiImage
    }
}
