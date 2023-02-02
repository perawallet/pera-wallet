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

//   CollectibleDetailCreatorAccountItemViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleDetailCreatorAccountItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init(asset: CollectibleAsset) {
        bindTitle(asset)

        accessory = CollectibleDetailCreatorAccountItemValueViewModel(asset: asset)
    }
}

extension CollectibleDetailCreatorAccountItemViewModel {
    private mutating func bindTitle(_ asset: CollectibleAsset) {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))

        title =
            "collectible-detail-creator-account"
                .localized
                .attributed(attributes)
    }
}

fileprivate struct CollectibleDetailCreatorAccountItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init(asset: CollectibleAsset) {
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Link.primary))

        let creator = asset.creator!.address.shortAddressDisplay
        title = creator.attributed(attributes)
    }
}
