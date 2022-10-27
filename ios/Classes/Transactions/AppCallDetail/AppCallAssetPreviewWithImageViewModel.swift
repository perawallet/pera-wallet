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

//   AppCallAssetPreviewWithImageViewModel.swift

import Foundation
import MacaroonUIKit

struct AppCallAssetPreviewWithImageViewModel:
    ViewModel {
    private(set) var icon: PrimaryImageViewModel?
    private(set) var content: AppCallAssetPreviewViewModel?

    init(
        asset: Asset
    ) {
        bindIcon(asset)
        bindContent(asset)
    }
}

extension AppCallAssetPreviewWithImageViewModel {
    mutating func bindIcon(
        _ asset: Asset
    ) {
        let title = asset.naming.name.isNilOrEmpty ?
        "title-unknown".localized
        : asset.naming.name

        icon = AssetImageLargeViewModel(
            image: .url(
                nil,
                title: title
            )
        )
    }

    mutating func bindContent(
        _ asset: Asset
    ) {
        content = AppCallAssetPreviewViewModel(
            asset: asset
        )
    }
}
