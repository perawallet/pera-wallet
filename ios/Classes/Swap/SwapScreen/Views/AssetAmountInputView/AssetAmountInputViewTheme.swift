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

//   AssetAmountInputViewTheme.swift

import MacaroonUIKit
import UIKit

struct AssetAmountInputViewTheme:
    StyleSheet,
    LayoutSheet {
    let icon: URLImageViewStyleLayoutSheet
    let iconSize: LayoutSize
    let contentHorizontalOffset: LayoutMetric
    let amountInput: TextInputStyle
    let shimmerCorner: Corner
    let amountInputShimmerSize: LayoutSize
    let amountContentEdgeInsets: LayoutPaddings
    let amountTextEdgeInsets: LayoutPaddings
    let detail: TextStyle
    let detailShimmerSize: LayoutSize

    init(
        placeholder: String,
        family: LayoutFamily
    ) {
        self.icon = URLImageViewAssetTheme()
        self.iconSize = (40, 40)
        self.contentHorizontalOffset = 16
        self.amountInput = [
            .font(Typography.bodyLargeMedium()),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .placeholder(placeholder),
            .placeholderColor(Colors.Text.grayLighter),
            .clearButtonMode(.never),
            .returnKeyType(.done),
            .keyboardType(.decimalPad),
            .autocapitalizationType(.none),
            .autocorrectionType(.no)
        ]
        self.shimmerCorner = Corner(radius: 4)
        self.amountInputShimmerSize = (68, 26)
        self.amountContentEdgeInsets = (0, 0, 0, 0)
        self.amountTextEdgeInsets = (0, 0, 0, 0)
        self.detail = [
            .textColor(Colors.Text.grayLighter),
            .textOverflow(SingleLineText())
        ]
        self.detailShimmerSize = (56, 20)
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
