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

//   AssetPreviewWithActionViewTheme.swift

import Foundation
import MacaroonUIKit

struct AssetPreviewWithActionViewTheme:
    StyleSheet,
    LayoutSheet {
    let content: AssetPreviewViewTheme

    let actionIconSize: LayoutSize
    let actionCorner: Corner
    let actionFirstShadow: MacaroonUIKit.Shadow
    let actionSecondShadow: MacaroonUIKit.Shadow
    let actionThirdShadow: MacaroonUIKit.Shadow

    let minSpacingBetweenContentAndAction: LayoutMetric
    
    init(_ family: LayoutFamily) {
        content = AssetPreviewViewTheme()

        actionIconSize = (32, 32)
        actionCorner = Corner(radius: 4)
        actionFirstShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        actionSecondShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        actionThirdShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.third.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        minSpacingBetweenContentAndAction = 20
    }
}
