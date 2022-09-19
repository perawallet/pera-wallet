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

//   ASAAboutScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASAAboutScreenTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var loading: ASAAboutLoadingViewTheme
    var contextEdgeInsets: NSDirectionalEdgeInsets
    var statistics: AssetStatisticsSectionViewTheme
    var spacingBetweenStatisticsAndAbout: CGFloat
    var spacingBetweenSeparatorAndAbout: CGFloat
    var about: AssetAboutSectionViewTheme
    var spacingBetweenSectionsAndVerificationTier: CGFloat
    var verificationTier: AssetVerificationInfoViewTheme
    var spacingBetweenVerificationTierAndFirstSection: CGFloat
    var spacingBetweenVerificationTierAndSections: CGFloat
    var spacingBetweenSeparatorAndDescription: CGFloat
    var description: ShowMoreViewTheme
    var spacingBetweenSeparatorAndSocialMedia: CGFloat
    var socialMedia: AssetSocialMediaGroupedListItemButtonTheme
    var reportAction: ListItemButtonTheme
    var spacingBetweenSeparatorAndReportAction: CGFloat
    var spacingBetweenSectionsAndReportAction: CGFloat
    var sectionSeparator: Separator
    var spacingBetweenSections: CGFloat

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.loading = ASAAboutLoadingViewTheme()
        self.contextEdgeInsets = .init(top: 36, leading: 24, bottom: 8, trailing: 24)
        self.statistics = AssetStatisticsSectionViewTheme(family)
        self.spacingBetweenStatisticsAndAbout = 62
        self.spacingBetweenSeparatorAndAbout = 26
        self.about = AssetAboutSectionViewTheme(family)
        self.spacingBetweenSectionsAndVerificationTier = 22
        self.verificationTier = AssetVerificationInfoViewTheme(family)
        self.spacingBetweenVerificationTierAndFirstSection = 24
        self.spacingBetweenVerificationTierAndSections = 60
        self.spacingBetweenSeparatorAndDescription = 36
        self.description = ShowMoreViewTheme(numberOfLinesLimit: 4, family: family)
        self.spacingBetweenSeparatorAndSocialMedia = 36
        self.socialMedia = AssetSocialMediaGroupedListItemButtonTheme(family)

        var reportAction = ListItemButtonTheme(family)
        reportAction.configureForAssetSocialMediaView()
        self.reportAction = reportAction
        self.spacingBetweenSeparatorAndReportAction = 26
        self.spacingBetweenSectionsAndReportAction = 62

        self.sectionSeparator = Separator(color: Colors.Layer.grayLighter, position: .top((0, 0)))
        self.spacingBetweenSections = 72
    }
}
