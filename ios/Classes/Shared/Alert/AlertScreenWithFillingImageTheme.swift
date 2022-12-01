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

//   AlertScreenWithFillingImageTheme.swift

import Foundation
import MacaroonUIKit

struct AlertScreenWithFillingImageTheme:
    AlertScreenTheme {
    let contextEdgeInsets: LayoutPaddings
    let image: ImageStyle
    let imageEdgeInsets: LayoutPaddings
    let newBadge: TextStyle
    let newBadgeCorner: Corner
    let newBadgeContentEdgeInsets: LayoutPaddings
    let newBadgeEdgeInsets: LayoutPaddings
    let title: TextStyle
    let titleEdgeInsets: LayoutPaddings
    let body: TextStyle
    let bodyEdgeInsets: LayoutPaddings
    let actionSpacing: LayoutMetric
    let actionsEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.contextEdgeInsets = (0, 0, 24, 0)
        self.image = [
            .contentMode(.scaleAspectFill)
        ]
        self.imageEdgeInsets = (0, 0, 0, 0)
        self.newBadge = [
            .text("title-new-uppercased".localized),
            .textColor(Colors.Helpers.positive),
            .font(Typography.captionBold()),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.positiveLighter)
        ]
        self.newBadgeCorner = Corner(radius: 8)
        self.newBadgeContentEdgeInsets =  (1, 5, 1, 5)
        self.newBadgeEdgeInsets = (9, 24, 9, 24)
        self.title = [
            .textOverflow(MultilineText(numberOfLines: 4)),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.titleEdgeInsets = (32, 24, .noMetric, 24)
        self.body = [
            .textOverflow(MultilineText(numberOfLines: 5)),
            .textColor(Colors.Text.gray),
            .font(Typography.footnoteRegular())
        ]
        self.bodyEdgeInsets = (12, 24, 0, 24)
        self.actionSpacing = 12
        self.actionContentEdgeInsets = (16, 24, 16, 24)
        self.actionsEdgeInsets = (8, 24, 32, 24)
    }
}
