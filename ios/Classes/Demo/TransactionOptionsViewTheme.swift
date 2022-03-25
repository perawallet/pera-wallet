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
//   TransactionOptionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TransactionOptionsViewTheme:
    StyleSheet,
    LayoutSheet {
    var backgroundStart: ViewStyle
    var backgroundEnd: ViewStyle
    var content: ViewStyle
    var contentCorner: Corner
    var contentSafeAreaInsets: UIEdgeInsets
    var actionsMinHorizontalPaddings: LayoutHorizontalPaddings
    var actionsVerticalPaddings: LayoutVerticalPaddings
    var spacingBetweenActions: LayoutMetric
    var sendAction: ButtonStyle
    var receiveAction: ButtonStyle
    var buyAlgoAction: ButtonStyle
    
    init(
        _ family: LayoutFamily
    ) {
        let actionFont = Fonts.DMSans.medium.make(15)
        let actionTitleColor = AppColors.Components.Text.main
        
        self.backgroundStart = [
            .backgroundColor(UIColor.clear)
        ]
        self.backgroundEnd = [
            .backgroundColor(color("bottomOverlayBackground"))
        ]
        self.content = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        self.contentCorner = Corner(
            radius: 16,
            mask: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        )
        self.contentSafeAreaInsets = .zero
        self.actionsMinHorizontalPaddings = (8, 8)
        self.actionsVerticalPaddings = (60, 40)
        self.spacingBetweenActions = 52
        self.sendAction = [
            .font(actionFont),
            .icon([ .normal("tabbar-icon-send") ]),
            .title("title-send".localized),
            .titleColor([ .normal(actionTitleColor) ])
        ]
        self.receiveAction = [
            .font(actionFont),
            .icon([ .normal("tabbar-icon-receive") ]),
            .title("title-receive".localized),
            .titleColor([ .normal(actionTitleColor) ])
        ]
        self.buyAlgoAction = [
            .font(actionFont),
            .icon([ .normal("tabbar-icon-buy") ]),
            .title("moonpay-buy-button-title".localized),
            .titleColor([ .normal(actionTitleColor) ])
        ]
    }
}
