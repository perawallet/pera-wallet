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

//   CollectibleDetailNameViewModel.swift

import MacaroonUIKit

struct CollectibleDetailNameViewModel: PrimaryTitleViewModel {
    var primaryTitle: TextProvider?
    var primaryTitleAccessory: Image?
    var secondaryTitle: TextProvider?

    init(
        _ asset: CollectibleAsset
    ) {
        bindPrimaryTitle(asset)
        bindSecondaryTitle(asset)
    }
}

extension CollectibleDetailNameViewModel {
    mutating func bindPrimaryTitle(
        _ asset: CollectibleAsset
    ) {
        let name = asset.title ?? asset.name ?? asset.id.stringWithHashtag
        primaryTitle = name.bodyLargeMedium(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindSecondaryTitle(
        _ asset: CollectibleAsset
    ) {
        guard let collectionName = asset.collection?.name,
              !collectionName.isEmptyOrBlank else {
            return
        }

        secondaryTitle =  collectionName.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
