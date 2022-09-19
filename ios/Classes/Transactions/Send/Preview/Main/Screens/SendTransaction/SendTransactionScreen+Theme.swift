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
//   SendTransactionScreen+Theme.swift


import Foundation
import MacaroonUIKit
import UIKit

extension SendTransactionScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: UIColor
        let nextButtonStyle: ButtonTheme
        let disabledValueLabelStyle: TextStyle
        let valueLabelStyle: TextStyle
        let currencyValueLabelStyle: TextStyle
        let accountContainerCorner: Corner
        let accountContainerBorder: Border
        let accountContainerFirstShadow: MacaroonUIKit.Shadow
        let accountContainerSecondShadow: MacaroonUIKit.Shadow
        let accountContainerThirdShadow: MacaroonUIKit.Shadow

        let accountContainerHeight: LayoutMetric
        let defaultLeadingInset: LayoutMetric
        let defaultBottomInset: LayoutMetric
        let accountPaddings: LayoutPaddings
        let nextButtonHeight: LayoutMetric
        let numpadBottomInset: LayoutMetric
        let buttonsSpacing: LayoutMetric
        let buttonsBottomInset: LayoutMetric
        let buttonsLeadingInset: LayoutMetric
        let buttonsHeight: LayoutMetric
        let labelsContainerHeight: LayoutMetric
        let labelsContainerBottomInset: LayoutMetric

        init(_ family: LayoutFamily) {
            backgroundColor = Colors.Defaults.background.uiColor
            nextButtonStyle = ButtonPrimaryTheme(family)
            valueLabelStyle = [
                .textColor(Colors.Text.main),
                .font(Fonts.DMMono.regular.make(36)),
                .textAlignment(.center),
                .textOverflow(SingleLineFittingText())
            ]
            currencyValueLabelStyle = [
                .textColor(Colors.Text.gray),
                .font(Fonts.DMMono.regular.make(15)),
                .textAlignment(.center),
                .textOverflow(SingleLineFittingText())
            ]
            disabledValueLabelStyle = [
                .textColor(Colors.Text.grayLighter),
                .font(Fonts.DMMono.regular.make(36)),
                .textAlignment(.center),
                .textOverflow(SingleLineFittingText())
            ]

            accountContainerCorner = Corner(radius: 4)
            accountContainerBorder = Border(color: Colors.Shadows.Cards.shadow1.uiColor, width: 1)

            accountContainerFirstShadow = MacaroonUIKit.Shadow(
                color: Colors.Shadows.Cards.shadow1.uiColor,
                fillColor: Colors.Defaults.background.uiColor,
                opacity: 1,
                offset: (0, 2),
                radius: 4,
                cornerRadii: (4, 4),
                corners: .allCorners
            )

            accountContainerSecondShadow = MacaroonUIKit.Shadow(
                color: Colors.Shadows.Cards.shadow2.uiColor,
                fillColor: Colors.Defaults.background.uiColor,
                opacity: 1,
                offset: (0, 2),
                radius: 4,
                cornerRadii: (4, 4),
                corners: .allCorners
            )

            accountContainerThirdShadow = MacaroonUIKit.Shadow(
                color: Colors.Shadows.Cards.shadow3.uiColor,
                fillColor: Colors.Defaults.background.uiColor,
                opacity: 1,
                offset: (0, 0),
                radius: 0,
                cornerRadii: (4, 4),
                corners: .allCorners
            )

            accountContainerHeight = 75
            defaultLeadingInset = 24
            defaultBottomInset = -24 * verticalScale
            accountPaddings = (14, 20, 14, 20)
            nextButtonHeight = 52 * verticalScale
            numpadBottomInset = -16
            buttonsSpacing = 10
            buttonsBottomInset = -42 * verticalScale
            buttonsLeadingInset = 110
            buttonsHeight = 28
            labelsContainerHeight = 80
            labelsContainerBottomInset = -20
        }
    }
}
