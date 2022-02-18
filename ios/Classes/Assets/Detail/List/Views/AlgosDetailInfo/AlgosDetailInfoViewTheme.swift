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
//   AlgosDetailInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgosDetailInfoViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let yourBalanceTitleLabel: TextStyle
    let algosValueLabel: TextStyle
    let secondaryValueLabel: TextStyle
    let separator: Separator
    let rewardsInfoViewTheme: RewardsInfoViewTheme

    let topPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let algoImageViewSize: LayoutSize
    let algosValueLabelTopPadding: LayoutMetric
    let secondaryValueLabelTopPadding: LayoutMetric
    let minimumHorizontalInset: LayoutMetric
    let rewardsInfoViewTopPadding: LayoutMetric
    let bottomPadding: LayoutMetric
    let separatorPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)
        self.yourBalanceTitleLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
        ]
        self.algosValueLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(36)),
        ]
        self.secondaryValueLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMMono.regular.make(15)),
        ]
        self.rewardsInfoViewTheme = RewardsInfoViewTheme()
        self.topPadding = 24
        self.horizontalPadding = 24
        self.algoImageViewSize = (24, 24)
        self.minimumHorizontalInset = 4
        self.algosValueLabelTopPadding = 8
        self.rewardsInfoViewTopPadding = 32
        self.separatorPadding = 32
        self.bottomPadding = 32
        self.secondaryValueLabelTopPadding = 4
    }
}
