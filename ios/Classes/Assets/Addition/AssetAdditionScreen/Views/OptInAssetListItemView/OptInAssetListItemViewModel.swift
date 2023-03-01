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

//   OptInAssetListItemViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct OptInAssetListItemViewModel: ViewModel {
    private(set) var icon: ImageSource?
    private(set) var title: OptInAssetNameListItemViewModel?

    init(asset: AssetDecoration) {
        bindIcon(asset: asset)
        bindTitle(asset: asset)
    }
}

extension OptInAssetListItemViewModel {
    mutating func bindIcon(asset: AssetDecoration) {
        let iconURL: URL?
        let iconShape: ImageShape
        if asset.isCollectible {
            iconURL = asset.collectible?.thumbnailImage
            iconShape = .rounded(4)
        } else {
            iconURL = asset.logoURL
            iconShape = .circle
        }

        let size = CGSize(width: 40, height: 40)
        let url = PrismURL(baseURL: iconURL)?
            .setExpectedImageSize(size)
            .setImageQuality(.normal)
            .build()
        /// <todo>
        /// Find a better way of formatting name
        let title = asset.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.name
        let placeholderText = TextFormatter.assetShortName.format(title)
        let placeholderImage =
            asset.isCollectible
            ? "placeholder-bg".uiImage
            : "asset-image-placeholder-border".uiImage
        let placeholder = ImagePlaceholder.init(
            image: .init(asset: placeholderImage),
            text: .string(placeholderText)
        )
        icon = DefaultURLImageSource(url: url, shape: iconShape, placeholder: placeholder)
    }

    mutating func bindTitle(asset: AssetDecoration) {
        title = OptInAssetNameListItemViewModel(asset: asset)
    }
}
