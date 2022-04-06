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

//   PassphraseVerifyCardViewTheme.swift

import MacaroonUIKit
import UIKit

struct PassphraseVerifyCardViewTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let horizontalPadding: LayoutMetric
    
    let headerLabel: TextStyle
    
    let containerViewTopPadding: LayoutMetric
    let containerViewCorner: Corner
    let containerViewFirstShadow: MacaroonUIKit.Shadow
    let containerViewSecondShadow: MacaroonUIKit.Shadow
    let containerViewThirdShadow: MacaroonUIKit.Shadow
    
    let stackViewSpacing: LayoutMetric
    
    let mnemonicLabelCorner: Corner
    let mnemonicLabelContentInset: LayoutPaddings
    let mnemonicLabel: TextStyle
    
    let activeColor: UIColor
    let deactiveColor: UIColor
    
    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        self.horizontalPadding = 24
        
        self.headerLabel = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray)
        ]
        
        self.containerViewTopPadding = 12
        self.containerViewCorner = Corner(radius: 4)
        self.containerViewFirstShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.containerViewSecondShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.containerViewThirdShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.third.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        
        self.stackViewSpacing = 8
        
        self.mnemonicLabelCorner = Corner(radius: 2)
        self.mnemonicLabelContentInset = (10, 0, 10, 0)
        self.mnemonicLabel = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
        ]
        
        self.activeColor = AppColors.Shared.Layer.grayLighter.uiColor
        self.deactiveColor = AppColors.Shared.System.background.uiColor
    }
}
