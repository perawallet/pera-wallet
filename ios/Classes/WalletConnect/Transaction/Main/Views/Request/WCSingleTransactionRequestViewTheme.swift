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
//   WCSingleTransactionRequestViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCSingleTransactionRequestViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let confirmButton: ButtonStyle
    let cancelButton: ButtonStyle
    let buttonEdgeInsets: LayoutPaddings
    let buttonHorizontalPadding: LayoutMetric
    let buttonBottomPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let confirmButtonWidthMultiplier: LayoutMetric
    let bottomHeight: LayoutMetric
    let bottomViewBottomOffset: LayoutMetric
    let separator: Separator

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.confirmButton = [
            .title("title-confirm".localized),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.cancelButton = [
            .title("title-cancel".localized),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
                .selected("components/buttons/secondary/bg-highlighted"),
                .disabled("components/buttons/secondary/bg-disabled")
            ])
        ]
        self.buttonEdgeInsets = (16, 8, 16, 8)
        self.buttonHorizontalPadding = 20
        self.buttonBottomPadding = 12
        self.horizontalPadding = 24
        self.confirmButtonWidthMultiplier = 2
        self.bottomHeight = 109
        self.bottomViewBottomOffset = -35
        self.separator = Separator(color: Colors.Layer.grayLighter.uiColor, size: 1)
    }
}
