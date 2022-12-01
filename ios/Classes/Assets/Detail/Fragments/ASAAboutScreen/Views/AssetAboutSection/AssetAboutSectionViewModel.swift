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

//   AssetAboutSectionViewModel.swift

import Foundation
import MacaroonUIKit

final class AssetAboutSectionViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var items: [AssetAboutSectionItem] = []

    init(asset: Asset) {
        bindTitle(asset: asset)
    }

    func addItem(
        _ item: AssetAboutSectionItem
    ) {
        items.append(item)
    }
}

extension AssetAboutSectionViewModel {
    func bindTitle(asset: Asset) {
        title = getAboutTitle(
            param: asset.naming.name.unwrapNonEmptyString() ?? "title-unknown".localized
        )
    }
}

extension AssetAboutSectionViewModel {
    func getAboutTitle(
        param: String,
        textColor: Color = Colors.Text.grayLighter
    ) -> TextProvider {
        var attributes: TextAttributeGroup = Typography.footnoteHeadingMediumAttributes(
            lineBreakMode: .byTruncatingTail
        )
        
        attributes.insert(.textColor(textColor))
        
        return "title-about-with-param"
            .localized(params: param.uppercased())
            .attributed(
                attributes
            )
    }
}
