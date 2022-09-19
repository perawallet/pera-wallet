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
//   ChartTimeFrameSelectionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgoPriceChartTimeFrameSelectionViewTheme:
    StyleSheet,
    LayoutSheet {
    var option: ButtonStyle
    var spacingBetweenOptions: LayoutMetric
    var selection: ViewStyle
    var selectionCorner: Corner
    var selectionMaxWidth: LayoutMetric
    var loadingCorner: Corner

    init(
        _ family: LayoutFamily
    ) {
        self.option = [
            .font(Fonts.DMSans.medium.make(13)),
            .titleColor(
                [
                    .normal(Colors.Text.grayLighter),
                    .highlighted(Colors.Text.main),
                    .selected(Colors.Text.main),
                ]
            )
        ]
        self.spacingBetweenOptions = 16
        self.selection = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.selectionCorner = 4
        self.selectionMaxWidth = 52
        self.loadingCorner = 4
    }
}
