// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupFileViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgorandSecureBackupFileViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var corner: Corner
    var iconFirstShadow: MacaroonUIKit.Shadow
    var iconSecondShadow: MacaroonUIKit.Shadow
    var iconThirdShadow: MacaroonUIKit.Shadow
    var iconBackgroundSize: LayoutSize
    var iconSize: LayoutSize
    var iconTopInset: LayoutMetric
    var iconAlignedTopInset: LayoutMetric
    var spacingBetweenIconAndTitle: LayoutMetric
    var title: TextStyle
    var spacingBetweenTitleAndSubtitle: LayoutMetric
    var subtitle: TextStyle
    var action: ButtonStyle
    var replaceAction: ButtonStyle
    var actionBottomInset: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Layer.grayLightest)
        ]
        self.corner = Corner(radius: 8)
        self.iconFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (22, 22),
            corners: .allCorners
        )
        self.iconSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (22, 22),
            corners: .allCorners
        )
        self.iconThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (22, 22),
            corners: .allCorners
        )
        self.iconBackgroundSize = (44, 44)
        self.iconSize = (24, 24)
        self.iconTopInset = 65
        self.iconAlignedTopInset = 36
        self.spacingBetweenIconAndTitle = 12
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenTitleAndSubtitle = 8
        self.subtitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.action = [
            .font(Typography.bodyMedium()),
            .titleColor([.normal(Colors.Helpers.positive)]),
            .title("algorand-secure-backup-import-backup-action-title".localized)
        ]
        self.replaceAction = [
            .font(Typography.bodyMedium()),
            .titleColor([.normal(Colors.Helpers.positive)]),
            .title("algorand-secure-backup-import-backup-action-replace-title".localized)
        ]
        self.actionBottomInset = 20
    }
}
