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

//   ErrorScreenTheme.swift

import MacaroonUIKit
import UIKit

struct ErrorScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let iconBackground: ViewStyle
    let iconBackgroundCorner: Corner
    let icon: ImageStyle
    let spacingBetweenIconAndTitle: LayoutMetric
    let iconSize: LayoutSize
    let title: TextStyle
    let titleCenterOffset: LayoutMetric
    let titleHorizontalInset: LayoutMetric
    let detail: TextStyle
    let detailHorizontalInset: LayoutMetric
    let spacingBetweenTitleAndDetail: LayoutMetric
    let primaryAction: ButtonStyle
    let minimumSpacingBetweenDetailAndPrimaryAction: LayoutMetric
    let secondaryAction: ButtonStyle
    let spacingBetweenActions: LayoutMetric
    let actionContentEdgeInsets: LayoutPaddings
    let actionEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.iconBackground = [
            .backgroundColor(Colors.Helpers.negative)
        ]
        self.iconBackgroundCorner = Corner(radius: 30)
        self.icon = [
            .image("icon-close-36")
        ]
        self.spacingBetweenIconAndTitle = 24
        self.iconSize = (60, 60)
        self.title = [
            .textColor(Colors.Text.main),
            .textAlignment(.center),
            .textOverflow(FittingText())
        ]
        self.titleCenterOffset = -40
        self.titleHorizontalInset = 80
        self.detail = [
            .textColor(Colors.Text.gray),
            .textAlignment(.center),
            .textOverflow(FittingText())
        ]
        self.detailHorizontalInset = 40
        self.spacingBetweenTitleAndDetail = 12
        self.primaryAction = [
            .title("swap-confirm-title".localized),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
            ])
        ]
        self.minimumSpacingBetweenDetailAndPrimaryAction = 12
        self.secondaryAction = [
            .title("swap-confirm-title".localized),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
        self.spacingBetweenActions = 12
        self.actionContentEdgeInsets = (16, 0, 16, 0)
        self.actionEdgeInsets = (12, 24, 16, 24)
    }
}
