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

final class WCAssetInformationViewModel: ViewModel {
    private(set) var title: String?
    private(set) var name: String?
    private(set) var assetId: String?

    var isAlgo: Bool {
        asset == nil
    }

    var isVerified: Bool {
        isAlgo || (asset?.presentation.isVerified ?? false)
    }

    private let asset: Asset?

    init(title: String?, asset: Asset?) {
        self.title = title
        self.asset = asset
        setName()
    }

    private func setName() {
        guard let asset = asset else {
            name = "ALGO"
            return
        }

        name = asset.presentation.name
        assetId = "\(asset.id)"
    }
}
