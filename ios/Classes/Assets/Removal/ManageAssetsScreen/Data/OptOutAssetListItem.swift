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

//   OptOutAssetListItem.swift

import Foundation

struct OptOutAssetListItem: Hashable {
    /// <todo>
    /// Maybe we should keep only what we need.
    let model: Asset
    let viewModel: OptOutAssetListItemViewModel

    init(item: AssetItem) {
        self.model = item.asset
        self.viewModel = OptOutAssetListItemViewModel(item: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
        hasher.combine(viewModel.content?.title?.primaryTitle?.string)
        hasher.combine(viewModel.content?.title?.secondaryTitle?.string)
        hasher.combine(viewModel.content?.primaryValue?.string)
        hasher.combine(viewModel.content?.secondaryValue?.string)
    }

    static func == (
        lhs: OptOutAssetListItem,
        rhs: OptOutAssetListItem
    ) -> Bool {
        return
            lhs.model.id == rhs.model.id &&
            lhs.viewModel.content?.title?.primaryTitle?.string == rhs.viewModel.content?.title?.primaryTitle?.string &&
            lhs.viewModel.content?.title?.secondaryTitle?.string == rhs.viewModel.content?.title?.secondaryTitle?.string &&
            lhs.viewModel.content?.primaryValue?.string == rhs.viewModel.content?.primaryValue?.string &&
            lhs.viewModel.content?.secondaryValue?.string == rhs.viewModel.content?.secondaryValue?.string
    }
}
