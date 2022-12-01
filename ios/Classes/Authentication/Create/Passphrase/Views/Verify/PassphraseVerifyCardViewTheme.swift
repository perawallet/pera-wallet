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
            .backgroundColor(Colors.Defaults.background)
        ]
        self.horizontalPadding = 24
        
        self.headerLabel = [
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.gray)
        ]
        
        self.containerViewTopPadding = 12

        self.containerViewFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.containerViewSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.containerViewThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        
        self.stackViewSpacing = 8
        
        self.mnemonicLabelCorner = Corner(radius: 2)
        self.mnemonicLabelContentInset = (10, 0, 10, 0)
        self.mnemonicLabel = [
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
        ]
        
        self.activeColor = Colors.Layer.grayLighter.uiColor
        self.deactiveColor = Colors.Defaults.background.uiColor
    }
}
