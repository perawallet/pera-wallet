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
//   AccountTypeViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct AccountTypeViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let detail: TextStyle

    let badge: TextStyle
    let badgeCorner: Corner
    let badgeContentEdgeInsets: LayoutPaddings
    let badgeHorizontalEdgeInsets: NSDirectionalHorizontalEdgeInsets

    let iconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric
    let minimumInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        self.detail = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.gray),
            .textAlignment(.left),
            .isInteractable(false)
        ]

        self.badge = [
            .textColor(Colors.Helpers.positive),
            .font(Typography.captionBold()),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.positiveLighter)
        ]
        self.badgeCorner = Corner(radius: 8)
        self.badgeContentEdgeInsets =  (3, 6, 3, 6)
        self.badgeHorizontalEdgeInsets = .init(
            leading: 8,
            trailing: 24
        )

        self.iconSize = (40, 40)
        self.horizontalInset = 24
        self.verticalInset = 24
        self.minimumInset = 2
    }
}
