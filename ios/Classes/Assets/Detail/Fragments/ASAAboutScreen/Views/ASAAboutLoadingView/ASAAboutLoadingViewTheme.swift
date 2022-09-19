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

//   ASAAboutLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASAAboutLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentEdgeInsets: NSDirectionalEdgeInsets
    var statisticsTitleSize: LayoutSize
    var spacingBetweenStatisticsTitleAndValue: LayoutMetric
    var statisticsItemTitleSize: LayoutSize
    var spacingBetweenStatisticsItemTitleAndValue: CGFloat
    var statisticsItemValueSize: LayoutSize
    var spacingBetweenStatisticsItems: CGFloat
    var spacingBetweenStatisticsAndAbout: CGFloat
    var aboutTitleSize: LayoutSize
    var spacingBetweenAboutTitleAndValue: LayoutMetric
    var aboutItemTitleSize: LayoutSize
    var aboutItemValueSize: LayoutSize
    var spacingBetweenAboutItems: CGFloat
    var spacingBetweenAboutAndDescription: CGFloat
    var descriptionTitleSize: LayoutSize
    var spacingBetweenDescriptionTitleAndValue: CGFloat
    var descriptionValueHeight: CGFloat
    var spacingBetweenDescriptionValueAndAccessory: CGFloat
    var descriptionAccessorySize: LayoutSize
    var corner: Corner
    var separator: Separator
    var spacingBetweenSectionAndSeparator: CGFloat

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentEdgeInsets = .init(top: 36, leading: 24, bottom: 8, trailing: 24)
        self.statisticsTitleSize = (80, 20)
        self.spacingBetweenStatisticsTitleAndValue = 24
        self.statisticsItemTitleSize = (60, 20)
        self.spacingBetweenStatisticsItemTitleAndValue = 4
        self.statisticsItemValueSize = (70, 20)
        self.spacingBetweenStatisticsItems = 12
        self.spacingBetweenStatisticsAndAbout = 72
        self.aboutTitleSize = (90, 20)
        self.spacingBetweenAboutTitleAndValue = 24
        self.aboutItemTitleSize = (60, 24)
        self.aboutItemValueSize = (90, 24)
        self.spacingBetweenAboutItems = 20
        self.corner = Corner(radius: 4)
        self.separator = Separator(color: Colors.Layer.grayLighter, position: .bottom((24, 24)))
        self.spacingBetweenSectionAndSeparator = 36
        self.spacingBetweenAboutAndDescription = 72
        self.descriptionTitleSize = (95, 20)
        self.spacingBetweenDescriptionTitleAndValue = 24
        self.descriptionValueHeight = 60
        self.spacingBetweenDescriptionValueAndAccessory = 4
        self.descriptionAccessorySize = (70, 24)
    }
}
