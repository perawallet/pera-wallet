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
//   LedgerAccountSelectionViewTheme.swift

import MacaroonUIKit
import UIKit

struct LedgerAccountSelectionViewTheme: StyleSheet, LayoutSheet {
    let image: ImageStyle
    let title: TextStyle
    let description: TextStyle
    let backgroundColor: Color

    let verifyButtonTheme: ButtonTheme

    let collectionViewMinimumLineSpacing: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let listContentInset: LayoutPaddings
    let titleLabelTopPadding: LayoutMetric
    let devicesListTopPadding: LayoutMetric
    let bottomInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let linearGradientHeight: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
        ]
        self.description = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .text("tutorial-description-ledger".bodyLargeMedium())
        ]
        self.image = [
            .image("icon-wallet"),
            .contentMode(.scaleAspectFit)
        ]
        self.verifyButtonTheme = ButtonPrimaryTheme()
        
        self.collectionViewMinimumLineSpacing = 16
        self.verticalStackViewTopPadding = 40
        self.verticalStackViewSpacing = 12
        self.titleLabelTopPadding = 24
        self.devicesListTopPadding = 30
        self.bottomInset = 16
        self.horizontalInset = 24
        let buttonHeight: LayoutMetric = 52
        let additionalLinearGradientHeightForButtonTop: LayoutMetric = 4
        self.linearGradientHeight = bottomInset + buttonHeight + additionalLinearGradientHeightForButtonTop
        self.listContentInset = (10, 0, linearGradientHeight + 16, 0)
    }
}
