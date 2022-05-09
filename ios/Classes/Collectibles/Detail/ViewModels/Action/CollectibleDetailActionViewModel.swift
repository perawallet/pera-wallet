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

//   CollectibleDetailActionViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleDetailActionViewModel:
    ViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var subtitle: EditText?

    init(
        asset: CollectibleAsset,
        account: Account?
    ) {
        bindTitle(asset)
        bindSubtitle(asset)
    }
}

extension CollectibleDetailActionViewModel {
    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        guard let collectionName = asset.collectionName,
              !collectionName.isEmptyOrBlank else {
                  return
              }

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        title = .attributedString(
            collectionName
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        let aSubtitle = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13

        subtitle = .attributedString(
            aSubtitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }
}
