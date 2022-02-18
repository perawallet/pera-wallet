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
//  AssetDisplayViewModel.swift

import UIKit
import MacaroonUIKit

final class AssetDisplayViewModel: PairedViewModel {
    private(set) var isVerified: Bool = false
    private(set) var name: String?
    private(set) var code: String?

    init(_ model: AssetInformation?) {
        if let assetDetail = model {
            bindIsVerified(assetDetail)

            let displayNames = assetDetail.getDisplayNames()
            bindName(displayNames)
            bindCode(displayNames)
        }
    }
}

extension AssetDisplayViewModel {
    private func bindIsVerified(_ assetDetail: AssetInformation) {
        isVerified = assetDetail.isVerified
    }

    private func bindName(_ displayNames: (String, String?)) {
        if !displayNames.0.isUnknown() {
            name = displayNames.0
        }
    }

    private func bindCode(_ displayNames: (String, String?)) {
        if displayNames.0.isUnknown() {
            code = displayNames.0
        } else {
            code = displayNames.1
        }
    }
}
