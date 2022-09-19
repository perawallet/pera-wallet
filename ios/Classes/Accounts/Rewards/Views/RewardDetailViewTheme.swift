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
//   RewardDetailViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct RewardDetailViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let rewardsLabel: TextStyle
    let rewardsValueLabel: TextStyle
    let descriptionLabel: TextStyle
    let FAQLabel: TextStyle
    let separator: Separator

    let separatorTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let rewardsRateTitleLabelTopPadding: LayoutMetric
    let rewardsLabelTopPadding: LayoutMetric
    let rewardsLabelLeadingPadding: LayoutMetric
    let algoImageViewSize: LayoutSize
    let descriptionLabelTopPadding: LayoutMetric
    let FAQLabelTopPadding: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.separator = Separator(color: Colors.Layer.grayLighter, size: 1)
        self.rewardsLabel = [
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.gray),
        ]
        self.rewardsValueLabel = [
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
        ]
        self.descriptionLabel = [
            .textColor(Colors.Text.main),
            .isInteractable(true),
            .textOverflow(FittingText())
        ]
        self.FAQLabel = [
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.main),
            .isInteractable(true),
            .textOverflow(FittingText())
        ]

        self.separatorTopPadding = -68
        self.horizontalPadding = 24
        self.rewardsRateTitleLabelTopPadding = 28
        self.rewardsLabelLeadingPadding = 12
        self.rewardsLabelTopPadding = 10
        self.algoImageViewSize = (24, 24)
        self.descriptionLabelTopPadding = 65
        self.FAQLabelTopPadding = 12
        self.bottomInset = 16
    }
}
