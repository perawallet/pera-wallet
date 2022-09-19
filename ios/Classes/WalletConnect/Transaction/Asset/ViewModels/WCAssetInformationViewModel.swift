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
    private(set) var title: String?
    private(set) var name: String?
    private(set) var nameColor: Color?
    private(set) var assetId: String?
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
        guard let asset = asset else {
            name = "ALGO"
            nameColor = Colors.Text.main
            return
        }

        name = asset.naming.name

        let nameColor: Color =
            asset.verificationTier.isSuspicious
            ? Colors.Helpers.negative
            : Colors.Text.main

        self.nameColor = nameColor

        assetId = "\(asset.id)"
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
