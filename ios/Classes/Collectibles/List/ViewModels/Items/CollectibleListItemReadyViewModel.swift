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

//   CollectibleListItemReadyViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

struct CollectibleListItemReadyViewModel:
    CollectibleListItemViewModel,
    Hashable {
    private(set) var assetID: AssetID?
    private(set) var image: ImageSource?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var mediaType: MediaType?
    private(set) var topLeftBadge: UIImage?
    private(set) var bottomLeftBadge: UIImage?

    init<T>(
        imageSize: CGSize,
        model: T
    ) {
        bind(
            imageSize: imageSize,
            model: model
        )
    }
}

extension CollectibleListItemReadyViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(assetID)
        hasher.combine(title)
        hasher.combine(subtitle)
    }

    static func == (
        lhs: CollectibleListItemReadyViewModel,
        rhs: CollectibleListItemReadyViewModel
    ) -> Bool {
        return lhs.assetID == rhs.assetID &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle
    }
}

extension CollectibleListItemReadyViewModel {
    mutating func bind<T>(
        imageSize: CGSize,
        model: T
    ) {
        if let asset = model as? CollectibleAsset {
            bindAssetID(asset)
            bindImage(imageSize: imageSize, asset: asset)
            bindTitle(asset)
            bindSubtitle(asset)
            bindMediaType(asset)
            bindTopLeftBadge(asset)
            bindBottomLeftBadge(asset)
            return
        }
    }
}

extension CollectibleListItemReadyViewModel {
    private mutating func bindAssetID(
        _ asset: CollectibleAsset
    ) {
        assetID = getAssetID(asset)
    }

    private mutating func bindImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) {
        image = getImage(imageSize: imageSize, asset: asset)
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        title = getTitle(asset)
    }

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        subtitle = getSubtitle(asset)
    }

    private mutating func bindTopLeftBadge(
        _ asset: CollectibleAsset
    ) {
        topLeftBadge = getTopLeftBadge(asset)
    }

    private mutating func bindBottomLeftBadge(
        _ asset: CollectibleAsset
    ) {
        if !asset.isOwned {
            bottomLeftBadge = "badge-warning".uiImage
            return
        }
    }

    private mutating func bindMediaType(
        _ asset: CollectibleAsset
    ) {
        mediaType = getMediaType(asset)
    }
}

extension CollectibleListItemReadyViewModel {
    mutating func bindBottomLeftBadgeForError() {
        bottomLeftBadge = "badge-error".uiImage
    }
}
