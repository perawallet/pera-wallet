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

//   CollectiblesFilterSelectionViewControllerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectiblesFilterSelectionViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    let minimumHorizontalSpacing: LayoutMetric
    let background: ViewStyle
    let contentEdgeInsets: LayoutPaddings

    let title: TextStyle
    let titleTopPadding: LayoutMetric
    let titleMaxWidthRatio: LayoutMetric
    let titleMinHeight: LayoutMetric

    let description: TextStyle
    let descriptionTopMargin: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        minimumHorizontalSpacing = 8
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        contentEdgeInsets = (24, 24, 16, 24)

        title = [
            .text(Self.getTitle()),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        titleTopPadding = 20
        titleMaxWidthRatio = 0.7
        titleMinHeight = 32

        description = [
            .text(Self.getDescription()),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())

        ]
        descriptionTopMargin = 12
    }
}

extension CollectiblesFilterSelectionViewControllerTheme {
    private static func getTitle() -> EditText {
        return .attributedString(
            "collectible-filter-selection-toggle-title"
                .localized
                .bodyRegular()
        )
    }

    private static func getDescription() -> EditText {
        return .attributedString(
            "collectible-filter-selection-toggle-description"
                .localized
                .footnoteRegular()
        )
    }
}
