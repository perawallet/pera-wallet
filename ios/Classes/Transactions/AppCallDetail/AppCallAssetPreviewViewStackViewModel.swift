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

//   AppCallAssetPreviewViewStackViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AppCallAssetPreviewViewStackViewModel:
    ViewModel {
    private(set) var assets: [AppCallAssetPreviewViewModel]?
    private(set) var showMoreActionTitle: EditText?

    var requiresShowMoreAction: Bool {
        return showMoreActionTitle != nil
    }

    private let maxAssetsCountToDisplay = 2

    init(
        assets: [Asset]
    ) {
        bindAssets(assets)
        bindShowMoreActionTitle(assets)
    }
}

extension AppCallAssetPreviewViewStackViewModel {
    mutating func bindAssets(
        _ assets: [Asset]
    ) {
        self.assets =
        assets.prefix(maxAssetsCountToDisplay).map(AppCallAssetPreviewViewModel.init)
    }

    mutating func bindShowMoreActionTitle(
        _ assets: [Asset]
    ) {
        let moreAssetCount = assets.count.advanced(by: -maxAssetsCountToDisplay)

        guard moreAssetCount > .zero else {
            return
        }

        self.showMoreActionTitle = .attributedString(
            "title-show-more-assets".localized(
                params: "\(moreAssetCount)"
            )
            .bodyMedium()
        )
    }
}
