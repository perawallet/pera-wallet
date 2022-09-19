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
    private(set) var image: AssetImageSmallViewModel?
    private(set) var title: EditText?

    init(
        _ asset: Asset? = nil
    ) {
        bindImage(asset)
        bindTitle(asset)
    }
}

extension AssetDetailTitleViewModel {
    private func bindImage(
        _ asset: Asset?
    ) {
        if let asset = asset {
            image = AssetImageSmallViewModel(
                image: .url(nil, title: asset.naming.name)
            )
            return
        }

        image = AssetImageSmallViewModel(image: .algo)
    }

    private func bindTitle(
        _ asset: Asset?
    ) {
        if let asset = asset {
            if let assetName = asset.naming.name,
               !assetName.isEmptyOrBlank {
                title = getTitle(assetName)
            } else {
                title = getTitle("title-unknown".localized)
            }

            return
        }

        title = getTitle("ALGO")
    }
}

extension AssetDetailTitleViewModel {
    func getTitle(
        _ aTitle: String?
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        return .attributedString(
            aTitle
                .bodyMedium()
        )
    }
}
