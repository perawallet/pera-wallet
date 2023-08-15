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

//
//   WCAssetInformationViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCAssetInformationViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var name: EditText?
    private(set) var verificationTierIcon: UIImage?

    var isAlgo: Bool {
        asset == nil
    }

    private let asset: Asset?

    init(title: String?, asset: Asset?) {
        self.title = title
        self.asset = asset
        bindName()
        bindVerificationTierIcon()
    }

    private func bindName() {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)

        guard let asset = asset else {
            attributes.insert(.textColor(Colors.Text.main))
            name = .attributedString("ALGO".attributed(attributes))
            return
        }

        let aTitle = asset.naming.name

        if asset.verificationTier.isSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        } else {
            attributes.insert(.textColor(Colors.Text.main))
        }

        let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
        let assetText = aTitle?.attributed(attributes)
        let assetIDText = "\(asset.id)".attributed(attributes)
        let text = [ destroyedText, assetText, assetIDText ].compound(" ")

        self.name = .attributedString(text)
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

    private func bindVerificationTierIcon() {
        if isAlgo {
           verificationTierIcon = "icon-trusted".uiImage
            return
        }

        guard let asset = asset else {
            return
        }

        switch asset.verificationTier {
        case .trusted: self.verificationTierIcon = "icon-trusted".uiImage
        case .verified: self.verificationTierIcon = "icon-verified".uiImage
        case .unverified: self.verificationTierIcon = nil
        case .suspicious: self.verificationTierIcon = "icon-suspicious".uiImage
        }
    }
}
