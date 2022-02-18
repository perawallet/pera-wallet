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
//  AssetDetailTitleViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AssetDetailTitleViewModel: ViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var assetAbbreviationForImage: String?
    
    init(assetDetail: AssetInformation? = nil) {
        bindTitle(assetDetail)
        bindImage(assetDetail)
    }
}

extension AssetDetailTitleViewModel {
    private func bindImage(_ assetDetail: AssetInformation?) {
        if let assetDetail = assetDetail {
            if let assetName = assetDetail.name,
               !assetName.isEmptyOrBlank {
                assetAbbreviationForImage = TextFormatter.assetShortName.format(assetName)
            } else {
                assetAbbreviationForImage = TextFormatter.assetShortName.format("title-unknown".localized)
            }
        } else {
            image = "icon-algo-circle-green".uiImage
        }
    }

    private func bindTitle(_ assetDetail: AssetInformation?) {
        if let assetDetail = assetDetail {
            if let assetName = assetDetail.name,
               !assetName.isEmptyOrBlank {
                title = assetName
            } else {
                title = "title-unknown".localized
            }
        } else {
            title = "ALGO"
        }
    }
}
