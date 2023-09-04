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
//   WCTransactionFullDappDetailViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCTransactionFullDappDetailViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let image: URLImageViewStyleLayoutSheet
    let imageSize: LayoutSize
    let imageCorner: Corner
    let title: TextStyle
    let description: TextStyle
    let primaryAction: ButtonStyle
    let primaryActionEdgeInsets: LayoutPaddings
    let verticalInset: LayoutMetric
    let buttonInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let titleTopInset: LayoutMetric
    let titleLeadingInset: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.image = URLImageViewNoStyleLayoutSheet(family)
        self.imageSize = (48, 48)
        self.imageCorner = Corner(radius: 24)
        self.title = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(19)),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("screenshot-title".localized)
        ]
        self.description = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("screenshot-description".localized)
        ]
        self.primaryAction = [
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.primaryActionEdgeInsets = (16, 8, 16, 8)
        self.buttonInset = 16
        self.verticalInset = 32
        self.horizontalInset = 24
        self.topInset = 34
        self.titleTopInset = 2
        self.titleLeadingInset = 20
        self.descriptionTopInset = 12
        self.bottomInset = 16
    }
}
