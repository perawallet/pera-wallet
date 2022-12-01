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

//   SwapAssetAmountViewTheme.swift

import MacaroonUIKit
import UIKit

struct SwapAssetAmountViewTheme:
    StyleSheet,
    LayoutSheet {
    var leftTitle: TextStyle
    var leftTitleMaxWidthRatio: CGFloat
    var rightTitle: TextStyle
    var spacingBetweenLeftAndRightTitles: LayoutMetric
    var spacingBetweenLeftTitleAndInputs: LayoutMetric
    var assetAmountInput: AssetAmountInputViewTheme
    var assetAmountInputMinWidthRatio: CGFloat
    var spacingBetweenAmountInputAndAssetSelection: LayoutMetric
    var assetSelection: SwapAssetSelectionViewTheme
    
    init(
        placeholder: String,
        family: LayoutFamily = .current
    ) {
        self.leftTitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.rightTitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenLeftAndRightTitles = 4
        self.leftTitleMaxWidthRatio = 0.2
        self.spacingBetweenLeftTitleAndInputs = 12
        self.assetAmountInput = AssetAmountInputViewTheme(
            placeholder: placeholder,
            family: family
        )
        self.assetAmountInputMinWidthRatio = 0.55
        self.spacingBetweenAmountInputAndAssetSelection = 8
        self.assetSelection = SwapAssetSelectionViewTheme()
    }

    init(
        _ family: LayoutFamily
    ) {
        self.init(
            placeholder: .empty,
            family: family
        )
    }
}
