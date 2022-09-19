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

//   ASAAboutScreenASACreatorSecondaryListItem.swift

import Foundation
import MacaroonUIKit

struct ASAAboutScreenASACreatorSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init(asset: Asset) {
        bindTitle()

        accessory = ASAAboutScreenASACreatorSecondaryListItemValueViewModel(asset: asset)
    }
}

extension ASAAboutScreenASACreatorSecondaryListItemViewModel {
    private mutating func bindTitle() {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))

        title =
            "asa-about-asa-creator"
                .localized
                .attributed(attributes)
    }
}

fileprivate struct ASAAboutScreenASACreatorSecondaryListItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init(asset: Asset) {
        bindTitle(asset: asset)
    }
}

extension ASAAboutScreenASACreatorSecondaryListItemValueViewModel {
    private mutating func bindTitle(asset: Asset) {
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.positive))

        title =
            asset.creator!
                .address
                .shortAddressDisplay
                .attributed(attributes)
    }
}
