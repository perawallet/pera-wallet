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
//  AssetDisplayViewModel.swift

import UIKit

class AssetDisplayViewModel {
    private(set) var isVerified: Bool = false
    private(set) var name: String?
    private(set) var code: String?
    private(set) var codeColor: UIColor?
    private(set) var codeFont: UIFont?

    init(assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            setIsVerified(from: assetDetail)

            let displayNames = assetDetail.getDisplayNames()
            setName(from: displayNames)
            setCode(from: displayNames)
            setCodeFont(from: displayNames)
            setCodeColor(from: displayNames)
        }
    }

    private func setIsVerified(from assetDetail: AssetDetail) {
        isVerified = assetDetail.isVerified
    }

    private func setName(from displayNames: (String, String?)) {
        if !displayNames.0.isUnknown() {
            name = displayNames.0
        }
    }

    private func setCode(from displayNames: (String, String?)) {
        if displayNames.0.isUnknown() {
            code = displayNames.0
        } else {
            code = displayNames.1
        }
    }

    private func setCodeFont(from displayNames: (String, String?)) {
        if displayNames.0.isUnknown() {
            codeFont = UIFont.font(withWeight: .semiBoldItalic(size: 40.0))
        }
    }

    private func setCodeColor(from displayNames: (String, String?)) {
        if displayNames.0.isUnknown() {
            codeColor = Colors.General.unknown
        }
    }
}
