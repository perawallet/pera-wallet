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
//   HomeLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomeLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var portfolioText: EditText
    var portfolioMargin: LayoutMargins
    var portfolioLoadingMargin: LayoutMargins
    var portfolioLoadingSize: LayoutSize

    var algoHoldingText: EditText
    var assetHoldingText: EditText
    var loadingCorner: Corner

    var holdingsContainerMargin: LayoutMargins
    var holdingsContainerHeight: LayoutMetric

    var algoImageBackground: UIColor
    var algoImageCornerRadius: LayoutMetric
    var algoImageTopInset: LayoutMetric
    var algoImageSize: LayoutSize
    var algoHoldingLoadingLeadingInset: LayoutMetric
    var algoHoldingLoadingSize: LayoutSize

    var accountsLabelStyle: TextStyle
    var accountsLabelMargin: LayoutMargins

    var accountLoadingMargin: LayoutMargins
    var accountLoadingHeight: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        self.portfolioText = .attributedString(
            "portfolio-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                    .textColor(AppColors.Components.Text.gray)
                ])
            )

        self.portfolioMargin = (8, 24, .noMetric, .noMetric)
        self.portfolioLoadingMargin = (18, .noMetric, .noMetric, .noMetric)
        self.portfolioLoadingSize = (128, 38)

        self.algoHoldingText = .attributedString(
            "portfolio-algo-holdings-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                    .textColor(AppColors.Components.Text.gray)
                ])
            )

        self.assetHoldingText = .attributedString(
            "portfolio-asset-holdings-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                    .textColor(AppColors.Components.Text.gray)
                ])
            )

        self.loadingCorner = Corner(radius: 4)

        self.holdingsContainerMargin = (80, 24, .noMetric, 24)
        self.holdingsContainerHeight = 60

        self.algoImageBackground = AppColors.Shared.Global.turquoise600.uiColor
        self.algoImageCornerRadius = 12
        self.algoImageTopInset = 13
        self.algoImageSize = (24, 24)
        self.algoHoldingLoadingLeadingInset = 12
        self.algoHoldingLoadingSize = (57, 20)

        self.accountsLabelStyle = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText()),
            .text("accounts-title".localized)
        ]
        self.accountsLabelMargin = (92, 24, .noMetric, 24)
        self.accountLoadingMargin = (4, 24, .noMetric, 24)
        self.accountLoadingHeight = 72
    }
}
