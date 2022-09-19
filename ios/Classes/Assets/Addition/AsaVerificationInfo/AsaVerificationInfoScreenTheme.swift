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

//   VerificationInfoViewController+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AsaVerificationInfoScreenTheme:
    LayoutSheet,
    StyleSheet {
    let illustration: ImageStyle
    let illustrationMaxHeight: LayoutMetric
    let illustrationMinHeight: LayoutMetric

    let closeAction: ButtonStyle
    let closeActionSize: LayoutSize
    let closeActionTopInset: LayoutMetric
    let closeActionLeadingInset: LayoutMetric

    let title: TextStyle
    let titleTopInset: LayoutMetric
    let titleHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets

    let body: TextStyle
    let bodyHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    let spacingBetweenTitleAndBody: LayoutMetric

    let primaryAction: ButtonStyle
    let primaryActionContentEdgeInsets: UIEdgeInsets
    let primaryActionEdgeInsets: NSDirectionalEdgeInsets

    init(
        _ family: LayoutFamily
    ) {
        self.illustration = [
            .backgroundColor(Colors.Defaults.background),
            .image("verification-info-illustration"),
            .contentMode(.scaleAspectFill)
        ]
        self.illustrationMaxHeight = 204
        self.illustrationMinHeight = 119

        let closeActionIcon = "icon-close"
            .uiImage
            .withRenderingMode(.alwaysTemplate)
        self.closeAction = [
            .icon([
                .normal(closeActionIcon)
            ]),
            .tintColor(Colors.Text.main)
        ]
        self.closeActionSize = (40, 40)
        self.closeActionTopInset = 10
        self.closeActionLeadingInset = 12

        self.title = [
            .textColor(Colors.Text.main),
        ]
        self.titleTopInset = 40
        self.titleHorizontalEdgeInsets = .init(leading: 24, trailing: 24)

        self.body = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.bodyHorizontalEdgeInsets = .init(leading: 24, trailing: 24)
        self.spacingBetweenTitleAndBody = 16

        self.primaryAction = [
            .title("title-learn-more".localized),
            .titleColor([
                .normal(Colors.Text.main)
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
                .selected("components/buttons/secondary/bg-selected")
            ])
        ]
        self.primaryActionContentEdgeInsets = .init(top: 14, left: 0, bottom: 14, right: 0)
        self.primaryActionEdgeInsets = .init(top: 36, leading: 24, bottom: 16, trailing: 24)
    }
}
