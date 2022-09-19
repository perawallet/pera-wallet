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

//   CollectibleListInfoWithFilterViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleListInfoWithFilterViewTheme:
    StyleSheet,
    LayoutSheet {
    let backgroundColor: Color
    let minimumHorizontalSpacing: LayoutMetric

    let info: TextStyle
    let infoMinWidthRatio: LayoutMetric
    let filterAction: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        backgroundColor = Colors.Defaults.background
        minimumHorizontalSpacing = 8

        info = [
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
        ]
        infoMinWidthRatio = 0.5

        filterAction = [
            .title(Self.getFilterActionTitle()),
            .titleColor([ .normal(Colors.Link.primary) ]),
            .icon([.normal("icon-filter-unselected"), .selected("icon-filter-selected") ])
        ]
    }
}

extension CollectibleListInfoWithFilterViewTheme {
    private static func getFilterActionTitle() -> EditText {
        return .attributedString(
            "collectible-filter-selection-title"
                .localized
                .bodyMedium(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}
