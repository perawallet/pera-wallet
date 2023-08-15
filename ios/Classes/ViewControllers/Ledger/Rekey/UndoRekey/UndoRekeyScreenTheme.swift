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

//   UndoRekeyScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct UndoRekeyScreenTheme:
    LayoutSheet,
    StyleSheet {
    var background: ViewStyle
    var navigationBarEdgeInset: LayoutPaddings
    var spacingBetweenTitleAndBody: LayoutMetric
    var body: TextStyle
    var bodyHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    var spacingBetweenBodyAndSummary: LayoutMetric
    var summary: RekeyInfoViewTheme
    var summaryHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets
    var spacingBetweenInformationItems: LayoutMetric
    var informationContentEdgeInsets: NSDirectionalEdgeInsets
    var primaryAction: ButtonStyle
    var primaryActionContentEdgeInsets: UIEdgeInsets
    var primaryActionEdgeInsets: NSDirectionalEdgeInsets

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.navigationBarEdgeInset = (8, 24, .noMetric, 24)
        self.spacingBetweenTitleAndBody = 16
        self.body = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.bodyHorizontalEdgeInsets = .init(
            leading: 24,
            trailing: 24
        )
        self.spacingBetweenBodyAndSummary = 40
        self.summary = RekeyInfoViewTheme(family)
        self.summaryHorizontalEdgeInsets = .init(
            leading: 24,
            trailing: 24
        )
        self.spacingBetweenInformationItems = 12
        self.informationContentEdgeInsets = .init(
            top: 36,
            leading: 24,
            bottom: 0,
            trailing: 24
        )
        self.primaryAction = [
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
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
        self.primaryActionEdgeInsets = .init(
            top: 30,
            leading: 24,
            bottom: 16,
            trailing: 24
        )
    }
}
