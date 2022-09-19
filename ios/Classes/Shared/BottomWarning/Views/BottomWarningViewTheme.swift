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
//   BottomWarningViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BottomWarningViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let image: ImageStyle
    let imageContentInsets: LayoutOffset
    let title: TextStyle
    let description: TextStyle
    let actionContentEdgeInsets: LayoutPaddings
    let actionCorner: Corner
    let primaryAction: ButtonStyle
    let secondaryAction: ButtonStyle
    let verticalInset: LayoutMetric
    let buttonInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.image = [
            .contentMode(.top)
        ]
        self.imageContentInsets = (0, 20)
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
        ]
        self.description = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
        self.actionContentEdgeInsets = (14, 24, 14, 24)
        self.actionCorner = Corner(radius: 4)
        self.primaryAction = [
            .titleColor(
                [.normal(Colors.Button.Primary.text)]
            ),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Primary.background)
        ]
        self.secondaryAction = [
            .titleColor(
                [.normal(Colors.Button.Secondary.text)]
            ),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.buttonInset = 16
        self.verticalInset = 32
        self.horizontalInset = 24
        self.topInset = 32
        self.descriptionTopInset = 12
        self.bottomInset = 16
    }
}
