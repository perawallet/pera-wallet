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

//   OptInAssetNameViewModel.swift

import Foundation
import MacaroonUIKit

/// <todo>
/// Just one of these view models is enough to cover all, i.e. TransferAssetBalanceNameViewModel etc.
struct OptInAssetNameViewModel: PrimaryTitleViewModel {
    private(set) var primaryTitle: TextProvider?
    private(set) var primaryTitleAccessory: Image?
    private(set) var secondaryTitle: TextProvider?

    init(asset: AssetDecoration) {
        bindPrimaryTitle(asset: asset)
        bindPrimaryTitleAccessory(asset: asset)
        bindSecondaryTitle(asset: asset)
    }
}

extension OptInAssetNameViewModel {
    mutating func bindPrimaryTitle(asset: AssetDecoration) {
        let title = asset.name.unwrapNonEmptyString() ?? "title-unknown".localized

        var attributes = Typography.titleSmallMediumAttributes(lineBreakMode: .byTruncatingTail)

        if asset.verificationTier.isSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        }

        let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
        let assetText = title.attributed(attributes)

        primaryTitle = [ destroyedText, assetText ].compound(" ")
    }

    private func makeDestroyedAssetTextIfNeeded(_ isAssetDestroyed: Bool) -> NSAttributedString? {
        guard isAssetDestroyed else {
            return nil
        }

        let title = "title-deleted-with-parantheses".localized
        var attributes = Typography.titleSmallMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.negative))
        return title.attributed(attributes)
    }

    mutating func bindPrimaryTitleAccessory(asset: AssetDecoration) {
        switch asset.verificationTier {
        case .trusted: primaryTitleAccessory = "icon-trusted"
        case .verified: primaryTitleAccessory = "icon-verified"
        case .unverified: primaryTitleAccessory = nil
        case .suspicious: primaryTitleAccessory = "icon-suspicious"
        }
    }

    mutating func bindSecondaryTitle(asset: AssetDecoration) {
        secondaryTitle = asset.unitName?.bodyRegular(lineBreakMode: .byTruncatingTail)
    }
}
