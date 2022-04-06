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

//
//  AssetAdditionViewModel.swift

import UIKit

class AssetAdditionViewModel {
    private(set) var backgroundColor: UIColor?
    private(set) var assetDetail: AssetInformation?
    private(set) var actionColor: UIColor?
    private(set) var id: String?

    init(assetInformation: AssetInformation) {
        setBackgroundColor()
        setAssetDetail(from: assetInformation)
        setActionColor()
        setId(from: assetInformation)
    }

    private func setBackgroundColor() {
        backgroundColor = AppColors.Shared.System.background.uiColor
    }

    private func setAssetDetail(from assetInformation: AssetInformation) {
        self.assetDetail = assetInformation
    }

    private func setActionColor() {
        actionColor = AppColors.Components.Text.grayLighter.uiColor
    }

    private func setId(from assetInformation: AssetInformation) {
        id = "\(assetInformation.id)"
    }
}
