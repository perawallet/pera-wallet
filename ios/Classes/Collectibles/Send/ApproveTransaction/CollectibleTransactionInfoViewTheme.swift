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

//   CollectibleTransactionInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleTransactionInfoViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let value: ButtonStyle

    let iconSize: LayoutSize
    let valueWidthRatio: LayoutMetric
    let buttonPadding: LayoutMetric
    let verticalPadding: LayoutMetric

    let separator: Separator

    init(
        _ family: LayoutFamily
    ) {
        self.title = [
            .textOverflow(FittingText()),
            .textColor(AppColors.Components.Text.gray)
        ]
        self.value = [
            .titleColor([.normal(AppColors.Components.Text.main.uiColor)])
        ]

        self.iconSize = (24, 24)
        self.valueWidthRatio = 0.45
        self.buttonPadding = 8
        self.verticalPadding = 16

        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter)
    }
}
