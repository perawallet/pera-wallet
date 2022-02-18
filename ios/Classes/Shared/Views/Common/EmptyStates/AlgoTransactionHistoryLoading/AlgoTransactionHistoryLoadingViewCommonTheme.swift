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
//   AlgoTransactionHistoryLoadingViewCommonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlgoTransactionHistoryLoadingViewCommonTheme: AlgoTransactionHistoryLoadingViewTheme {

    var titleViewCorner: LayoutMetric
    var titleViewSize: LayoutSize
    var titleMargin: LayoutMargins

    var balanceViewCorner: LayoutMetric
    var balanceViewSize: LayoutSize
    var balanceViewMargin: LayoutMargins

    var currencyViewCorner: LayoutMetric
    var currencyViewSize: LayoutSize
    var currencyViewMargin: LayoutMargins

    var rewardsContainerCorner: Corner
    var rewardsContainerBorder: Border
    var rewardsContainerFirstShadow: MacaroonUIKit.Shadow
    var rewardsContainerSecondShadow: MacaroonUIKit.Shadow
    var rewardsContainerThirdShadow: MacaroonUIKit.Shadow
    var rewardsContainerSize: LayoutSize
    var rewardsContainerMargin: LayoutMargins
    var rewardsImageViewBackgroundColor: UIColor
    var rewardsImageViewSize: LayoutSize
    var rewardsImageViewCorner: LayoutMetric
    var rewardsImageViewMargin: LayoutMargins

    var rewardsTitleViewCorner: LayoutMetric
    var rewardsTitleViewSize: LayoutSize
    var rewardsTitleViewMargin: LayoutMargins

    var rewardsSubtitleViewCorner: LayoutMetric
    var rewardsSubtitleViewSize: LayoutSize
    var rewardsSubtitleViewMargin: LayoutMargins
    var rewardsSupplementaryViewImage: ImageStyle
    var rewardsSupplementaryViewMargin: LayoutMargins

    init(
        _ family: LayoutFamily
    ) {

        self.titleViewCorner = 4
        self.titleMargin = (24, .noMetric, .noMetric, .noMetric)
        self.titleViewSize = (100, 20)

        self.balanceViewCorner = 4
        self.balanceViewMargin = (12, .noMetric, .noMetric, .noMetric)
        self.balanceViewSize = (109, 44)

        self.currencyViewCorner = 4
        self.currencyViewMargin = (12, .noMetric, .noMetric, .noMetric)
        self.currencyViewSize = (59, 20)

        self.rewardsContainerCorner = Corner(radius: 4)
        self.rewardsContainerBorder = Border(color: AppColors.SendTransaction.Shadow.first.uiColor, width: 1)

        self.rewardsContainerFirstShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        self.rewardsContainerSecondShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        self.rewardsContainerThirdShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.third.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.rewardsContainerSize = (.noMetric, 72)
        self.rewardsContainerMargin = (32, .noMetric, 65, .noMetric)
        self.rewardsImageViewBackgroundColor =  AppColors.Shared.Helpers.positive.uiColor.withAlphaComponent(0.05)
        self.rewardsImageViewCorner = 20
        self.rewardsImageViewSize = (40, 40)
        self.rewardsImageViewMargin = (.noMetric, 20, .noMetric, .noMetric)

        self.rewardsTitleViewCorner = 4
        self.rewardsTitleViewMargin = (14, 16, .noMetric, .noMetric)
        self.rewardsTitleViewSize = (50, 20)

        self.rewardsSubtitleViewCorner = 4
        self.rewardsSubtitleViewMargin = (4, 16, .noMetric, .noMetric)
        self.rewardsSubtitleViewSize = (109, 20)

        self.rewardsSupplementaryViewImage = [
            .image("icon-info-gray")
        ]
        self.rewardsSupplementaryViewMargin = (.noMetric, .noMetric, .noMetric, 20)
    }
}
