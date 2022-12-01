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

//   SwapIntroductionScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapIntroductionScreenTheme:
    LayoutSheet,
    StyleSheet {
    let illustrationImageBackground: ImageStyle
    let illustrationImage: ImageStyle
    let illustrationImageMaxHeight: LayoutMetric
    let illustrationImageMinHeight: LayoutMetric

    let closeAction: ButtonStyle
    let closeActionSize: LayoutSize
    let closeActionTopInset: LayoutMetric
    let closeActionLeadingInset: LayoutMetric

    let title: TextStyle
    let titleTopInset: LayoutMetric
    let titleHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets

    let newBadge: TextStyle
    let newBadgeCorner: Corner
    let newBadgeContentEdgeInsets: LayoutPaddings
    let newBadgeHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    let newBadgeMaxWidthRatio: LayoutMetric

    let body: TextStyle
    let bodyHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    let spacingBetweenTitleAndBody: LayoutMetric

    let footerContentEdgeInsets: LayoutPaddings

    let poweredByTitle: TextStyle
    let poweredByTitleLeadingInset: LayoutMetric

    let primaryAction: ButtonStyle
    let primaryActionContentEdgeInsets: UIEdgeInsets
    let primaryActionTopInset: LayoutMetric

    let termsOfService: TextStyle
    let termsOfServiceTopInset: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.illustrationImageBackground = [
            .image("swap-introduction-illustration-background"),
            .contentMode(.scaleAspectFill)
        ]
        self.illustrationImage = [
            .image("swap-introduction-illustration"),
            .contentMode(.scaleAspectFill)
        ]
        self.illustrationImageMaxHeight = 274
        self.illustrationImageMinHeight = 132

        self.closeAction = [
            .icon([ .normal("icon-close".templateImage) ]),
            .tintColor(Colors.Text.white)
        ]
        self.closeActionSize = (40, 40)
        self.closeActionTopInset = 10
        self.closeActionLeadingInset = 12

        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
        self.titleTopInset = 40
        self.titleHorizontalEdgeInsets = .init(
            leading: 24,
            trailing: 24
        )

        self.newBadge = [
            .textColor(Colors.Helpers.positive),
            .font(Typography.footnoteBold()),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.positiveLighter)
        ]
        self.newBadgeCorner = Corner(radius: 8)
        self.newBadgeContentEdgeInsets =  (3, 6, 3, 6)
        self.newBadgeHorizontalEdgeInsets = .init(
            leading: 12,
            trailing: 24
        )
        self.newBadgeMaxWidthRatio = 0.5

        self.body = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.bodyHorizontalEdgeInsets = .init(
            leading: 24,
            trailing: 24
        )
        self.spacingBetweenTitleAndBody = 16

        self.footerContentEdgeInsets = (16, 24, 16, 24)

        self.poweredByTitle = [
            .textColor(Colors.Text.grayLighter),
            .textOverflow(SingleLineText())
        ]
        self.poweredByTitleLeadingInset = 10

        self.primaryAction = [
            .title("swap-introduction-primary-action-title".localized),
            .titleColor([
                .normal(Colors.Button.Primary.text)
            ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
            ])
        ]
        self.primaryActionContentEdgeInsets = .init(
            top: 16,
            left: 0,
            bottom: 16,
            right: 0
        )
        self.primaryActionTopInset = 16

        self.termsOfService = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
        self.termsOfServiceTopInset = 20
    }
}
