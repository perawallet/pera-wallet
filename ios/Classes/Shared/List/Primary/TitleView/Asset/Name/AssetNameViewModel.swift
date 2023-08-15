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

//   AssetNameViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetNameViewModel: PrimaryTitleViewModel {
    var primaryTitle: TextProvider?
    var primaryTitleAccessory: Image?
    var secondaryTitle: TextProvider?

    init(
        _ asset: Asset
    ) {
        bindPrimaryTitle(asset)
        bindPrimaryTitleAccessory(asset)
        bindSecondaryTitle(asset)
    }

    init(update: OptInBlockchainUpdate) {
        bindPrimaryTitle(update: update)
        bindPrimaryTitleAccessory(update: update)
        bindSecondaryTitle(update: update)
    }

    init(update: OptOutBlockchainUpdate) {
        bindPrimaryTitle(update: update)
        bindPrimaryTitleAccessory(update: update)
        bindSecondaryTitle(update: update)
    }
}

extension AssetNameViewModel {
    mutating func bindPrimaryTitle(
        _ asset: Asset
    ) {
        primaryTitle = getPrimaryTitle(
            assetName: asset.naming.name,
            assetVerificationTier: asset.verificationTier,
            isAssetDestroyed: asset.isDestroyed
        )
    }

    mutating func bindPrimaryTitleAccessory(
        _ asset: Asset
    ) {
        primaryTitleAccessory = getPrimaryTitleAccessory(asset.verificationTier)
    }

    mutating func bindSecondaryTitle(
        _ asset: Asset
    ) {
        secondaryTitle = getSecondaryTitle(asset.naming.unitName)
    }
}

extension AssetNameViewModel {
    mutating func bindPrimaryTitle(update: OptInBlockchainUpdate) {
        primaryTitle = getPrimaryTitle(
            assetName: update.assetName,
            assetVerificationTier: update.assetVerificationTier,
            isAssetDestroyed: update.isAssetDestroyed
        )
    }

    mutating func bindPrimaryTitleAccessory(update: OptInBlockchainUpdate) {
        primaryTitleAccessory = getPrimaryTitleAccessory(update.assetVerificationTier)
    }

    mutating func bindSecondaryTitle(update: OptInBlockchainUpdate) {
        secondaryTitle = getSecondaryTitle(update.assetUnitName)
    }
}

extension AssetNameViewModel {
    mutating func bindPrimaryTitle(update: OptOutBlockchainUpdate) {
        primaryTitle = getPrimaryTitle(
            assetName: update.assetName,
            assetVerificationTier: update.assetVerificationTier,
            isAssetDestroyed: update.isAssetDestroyed
        )
    }

    mutating func bindPrimaryTitleAccessory(update: OptOutBlockchainUpdate) {
        primaryTitleAccessory = getPrimaryTitleAccessory(update.assetVerificationTier)
    }

    mutating func bindSecondaryTitle(update: OptOutBlockchainUpdate) {
        secondaryTitle = getSecondaryTitle(update.assetUnitName)
    }
}

extension AssetNameViewModel {
    private func getPrimaryTitle(
        assetName: String?,
        assetVerificationTier: AssetVerificationTier,
        isAssetDestroyed: Bool
    ) -> TextProvider {
        let aTitle = assetName.unwrapNonEmptyString() ?? "title-unknown".localized

        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        if assetVerificationTier.isSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        } else {
            attributes.insert(.textColor(Colors.Text.main))
        }

        let destroyedText = makeDestroyedAssetTextIfNeeded(isAssetDestroyed)
        let assetText = aTitle.attributed(attributes)
        let text = [ destroyedText, assetText ].compound(" ")
        return text
    }

    private func makeDestroyedAssetTextIfNeeded(_ isAssetDestroyed: Bool) -> NSAttributedString? {
        guard isAssetDestroyed else {
            return nil
        }

        let title = "title-deleted-with-parantheses".localized
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.negative))
        return title.attributed(attributes)
    }

    private func getPrimaryTitleAccessory(_ assetVerificationTier: AssetVerificationTier) -> Image? {
        switch assetVerificationTier {
        case .trusted: return "icon-trusted"
        case .verified: return  "icon-verified"
        case .unverified: return nil
        case .suspicious: return "icon-suspicious"
        }
    }

    private func getSecondaryTitle(_ assetUnitName: String?) -> TextProvider? {
        return assetUnitName?.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
