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

//   SwapSummaryAccountViewTheme.swift

import MacaroonUIKit
import UIKit

struct SwapSummaryAccountViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let iconSize: LayoutSize
    let minimumSpacingBetweenTitleAndIcon: LayoutMetric
    let iconLeadingInset: LayoutMetric
    let detail: TextStyle
    let detailLeadingInset: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
            .text("title-account".localized),
            .font(Typography.bodyRegular())
        ]
        self.iconSize = (24, 24)
        self.minimumSpacingBetweenTitleAndIcon = 4
        self.iconLeadingInset = 124
        self.detail = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText(lineBreakMode: .byTruncatingMiddle)),
        ]
        self.detailLeadingInset = 12
    }
}
