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
//   AlgoTransactionHistoryLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol AlgoTransactionHistoryLoadingViewTheme:
    StyleSheet,
    LayoutSheet {

    var titleViewCorner: LayoutMetric { get }
    var titleViewSize: LayoutSize { get }
    var titleMargin: LayoutMargins { get }

    var balanceViewCorner: LayoutMetric { get }
    var balanceViewSize: LayoutSize { get }
    var balanceViewMargin: LayoutMargins { get }

    var currencyViewCorner: LayoutMetric { get }
    var currencyViewSize: LayoutSize { get }
    var currencyViewMargin: LayoutMargins { get }

    var rewardsContainerCorner: Corner { get }
    var rewardsContainerBorder: Border { get }
    var rewardsContainerFirstShadow: MacaroonUIKit.Shadow { get }
    var rewardsContainerSecondShadow: MacaroonUIKit.Shadow { get }
    var rewardsContainerThirdShadow: MacaroonUIKit.Shadow { get }

    var rewardsContainerSize: LayoutSize { get }
    var rewardsContainerMargin: LayoutMargins { get }

    var rewardsImageViewBackgroundColor: UIColor { get }
    var rewardsImageViewCorner: LayoutMetric { get }
    var rewardsImageViewSize: LayoutSize { get }
    var rewardsImageViewMargin: LayoutMargins { get }

    var rewardsTitleViewCorner: LayoutMetric { get }
    var rewardsTitleViewSize: LayoutSize { get }
    var rewardsTitleViewMargin: LayoutMargins { get }

    var rewardsSubtitleViewCorner: LayoutMetric { get }
    var rewardsSubtitleViewSize: LayoutSize { get }
    var rewardsSubtitleViewMargin: LayoutMargins { get }

    var rewardsSupplementaryViewImage: ImageStyle { get }
    var rewardsSupplementaryViewMargin: LayoutMargins { get }

    var buyAlgoButtonTheme: ButtonTheme { get }
    var buyAlgoButtonMargin: LayoutMargins { get }
    var buyAlgoButtonHeight: LayoutMetric { get }
    
    var buyAlgoVisible: Bool { get }

}
