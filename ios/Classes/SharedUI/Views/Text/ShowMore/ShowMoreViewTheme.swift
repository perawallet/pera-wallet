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

//   ShowMoreViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ShowMoreViewTheme:
    StyleSheet,
    LayoutSheet {
    var title: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    var body: TextStyle
    var bodyURLColor: Color
    var fullBodyOverflow: TextOverflow
    var truncatedBodyOverflow: TextOverflow
    var toggleTruncationAction: ButtonStyle
    var toggleTruncationActionContentEdgeInsets: UIEdgeInsets

    let numberOfLinesLimit: Int

    init(_ family: LayoutFamily) {
        self.init(
            numberOfLinesLimit: 4,
            family: family
        )
    }

    init(
        numberOfLinesLimit: Int,
        family: LayoutFamily = .current
    ) {
        self.numberOfLinesLimit = numberOfLinesLimit
        self.title = [
            .textColor(Colors.Text.grayLighter)
        ]
        self.spacingBetweenTitleAndBody = 24
        self.body = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        self.bodyURLColor = Colors.Link.primary
        self.fullBodyOverflow = FittingText()
        self.truncatedBodyOverflow = MultilineText(numberOfLines: numberOfLinesLimit)
        self.toggleTruncationAction = [
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Helpers.positive) ]),
            .title(
                TextSet(
                    "title-show-more".localized,
                    selected: "title-show-less".localized
                )
            )
        ]
        self.toggleTruncationActionContentEdgeInsets = .init(top: 6, left: 0, bottom: 2, right: 0)
    }
}
