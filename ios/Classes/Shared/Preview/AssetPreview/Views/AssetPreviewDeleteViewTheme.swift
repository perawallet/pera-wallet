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

//   AssetPreviewDeleteViewTheme.swift

import Foundation
import MacaroonUIKit

struct AssetPreviewDeleteViewTheme: StyleSheet, LayoutSheet {
    let imageSize: LayoutSize
    let horizontalPadding: LayoutMetric
    
    let primaryAssetTitle: TextStyle
    let secondaryAssetTitle: TextStyle
    let secondaryImageLeadingPadding: LayoutMetric
    
    let primaryAssetValue: TextStyle
    let secondaryAssetValue: TextStyle
    let assetValueTrailingPadding: LayoutMetric
    let assetValueVerticalPadding: LayoutMetric
    
    let button: ButtonStyle
    let buttonSize: LayoutSize
    let buttonCorner: Corner
    let buttonFirstShadow: MacaroonUIKit.Shadow
    let buttonSecondShadow: MacaroonUIKit.Shadow
    let buttonThirdShadow: MacaroonUIKit.Shadow
    
    init(_ family: LayoutFamily) {
        self.imageSize = (40, 40)
        self.horizontalPadding = 16
        
        self.primaryAssetTitle = [
            .font(Fonts.DMSans.regular.make(15)),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .textAlignment(.left)
        ]
        self.secondaryAssetTitle = [
            .font(Fonts.DMSans.regular.make(13)),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .textAlignment(.left)
        ]
        self.secondaryImageLeadingPadding = 8
        
        self.primaryAssetValue = [
            .font(Fonts.DMMono.regular.make(15)),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .textAlignment(.right)
        ]
        self.secondaryAssetValue = [
            .font(Fonts.DMSans.regular.make(13)),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .textAlignment(.right)
        ]
        self.assetValueTrailingPadding = 20
        self.assetValueVerticalPadding = 14
        
        self.button = [
            .icon([.normal("icon-asset-delete")]),
        ]
        self.buttonSize = (32, 32)
        self.buttonCorner = Corner(radius: 4)
        self.buttonFirstShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.buttonSecondShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.buttonThirdShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.third.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
    }
}
