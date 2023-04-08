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

//   SignWithLedgerProcessScreenTheme.swift

import Foundation
import MacaroonUIKit

struct SignWithLedgerProcessScreenTheme:
    LayoutSheet,
    StyleSheet {
    let progressTopInset: LayoutMetric
    let progressTintColor: Color
    let trackTintColor: Color
    let contextEdgeInsets: LayoutPaddings
    let titleTopInset: LayoutMetric
    let title: TextStyle
    let spacingBetweenTitleAndBody: LayoutMetric
    let body: TextStyle
    let action: ButtonStyle
    let spacingBetweenActionAndInfo: LayoutMetric
    let info: TextStyle
    let footerEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.progressTopInset = 8
        self.progressTintColor = Colors.Helpers.positive
        self.trackTintColor = Colors.Layer.grayLighter
        self.contextEdgeInsets = (58, 24, 28, 24)
        self.titleTopInset = 24
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.spacingBetweenTitleAndBody = 12
        self.body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular())
        ]
        self.action = [
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
        self.spacingBetweenActionAndInfo = 12
        self.info = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
        ]
        self.footerEdgeInsets = (8, 24, 16, 24)
        self.actionContentEdgeInsets = (16, 24, 16, 24)
    }
}
