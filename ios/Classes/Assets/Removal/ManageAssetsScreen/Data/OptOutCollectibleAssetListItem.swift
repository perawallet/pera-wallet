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

//   OptOutCollectibleAssetListItem.swift

import Foundation

struct OptOutCollectibleAssetListItem: Hashable {
    let model: CollectibleAsset
    let viewModel: CollectibleListItemViewModel

    init(item: CollectibleAssetItem) {
        self.model = item.asset
        self.viewModel = CollectibleListItemViewModel(item: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
        hasher.combine(model.amount)
        hasher.combine(viewModel.primaryTitle?.string)
        hasher.combine(viewModel.secondaryTitle?.string)
    }

    static func == (
        lhs: OptOutCollectibleAssetListItem,
        rhs: OptOutCollectibleAssetListItem
    ) -> Bool {
        return
            lhs.model.id == rhs.model.id &&
            lhs.model.amount == rhs.model.amount &&
            lhs.viewModel.primaryTitle?.string == rhs.viewModel.primaryTitle?.string &&
            lhs.viewModel.secondaryTitle?.string == rhs.viewModel.secondaryTitle?.string
    }
}
