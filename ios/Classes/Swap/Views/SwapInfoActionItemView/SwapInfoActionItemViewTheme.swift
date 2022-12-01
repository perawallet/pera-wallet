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

//   SwapInfoActionItemViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapInfoActionItemViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let infoActionContentEdgeInsets: UIEdgeInsets
    let detail: TextStyle
    let detailMaxWidthRatio: CGFloat
    let minimumSpacingBetweenInfoActionAndDetail: LayoutMetric
    let detailActionSize: LayoutSize
    let detailActionContentEdgeInsets: UIEdgeInsets

    init(
        _ family: LayoutFamily
    ) {
        self.title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.infoActionContentEdgeInsets = UIEdgeInsets((0, 6, 0, 6))
        self.detail = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
        self.detailMaxWidthRatio = 0.65
        self.minimumSpacingBetweenInfoActionAndDetail = 12
        self.detailActionSize = (32, 32)
        self.detailActionContentEdgeInsets = UIEdgeInsets((6, 12, 6, 0))
    }
}
