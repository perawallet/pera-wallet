// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AssetAdditionViewModel.swift

import UIKit

class AssetAdditionViewModel {
    private(set) var backgroundColor: UIColor?
    private(set) var assetDetail: AssetDetail?
    private(set) var actionColor: UIColor?
    private(set) var id: String?

    init(assetSearchResult: AssetSearchResult) {
        setBackgroundColor()
        setAssetDetail(from: assetSearchResult)
        setActionColor()
        setId(from: assetSearchResult)
    }

    private func setBackgroundColor() {
        backgroundColor = Colors.Background.secondary
    }

    private func setAssetDetail(from assetSearchResult: AssetSearchResult) {
        assetDetail = AssetDetail(searchResult: assetSearchResult)
    }

    private func setActionColor() {
        actionColor = Colors.Text.tertiary
    }

    private func setId(from assetSearchResult: AssetSearchResult) {
        id = "\(assetSearchResult.id)"
    }
}
