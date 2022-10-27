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

//   AppCallTransactionAssetInformationViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AppCallTransactionAssetInformationViewModel:
    ViewModel {
    private(set) var title: EditText?
    private(set) var assetInfo: AppCallAssetPreviewViewStackViewModel?

    init(
        assets: [Asset]
    ) {
        bindTitle(assets)
        bindAssetInfo(assets)
    }
}

extension AppCallTransactionAssetInformationViewModel {
    mutating func bindTitle(
        _ assets: [Asset]
    ) {
        let aText: String = assets.count == 1
        ? "asset-title".localized
        : "assets-title".localized

        title = .attributedString(
            aText
                .bodyRegular()
        )
    }

    mutating func bindAssetInfo(
        _ assets: [Asset]
    ) {
        assetInfo = AppCallAssetPreviewViewStackViewModel(
            assets: assets
        )
    }
}
