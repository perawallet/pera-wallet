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

//   AssetManagementItemViewTheme.swift

import Foundation
import MacaroonUIKit

struct AssetManagementItemViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: EditText?
    let manageButton: ButtonStyle
    let addButton: ButtonStyle
    let spacing: LayoutMetric
    
    init(_ family: LayoutFamily) {
        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23
        
        self.title = .attributedString(
            "accounts-title-assets"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
        
        self.manageButton = [
            .font(font),
            .title("asset-manage-button".localized),
            .icon([.normal("icon-asset-manage")]),
            .titleColor([.normal(AppColors.Components.Link.primary)])
        ]
        
        self.addButton = [
            .font(font),
            .title("transaction-detail-add".localized),
            .icon([.normal("icon-asset-add")]),
            .titleColor([.normal(AppColors.Components.Link.primary)])
        ]
        
        self.spacing = 16
    }
}
