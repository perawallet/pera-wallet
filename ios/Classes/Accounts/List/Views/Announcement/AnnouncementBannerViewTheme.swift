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
//   AnnouncmentBannerViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AnnouncementBannerViewTheme: StyleSheet, LayoutSheet {
    let container: ViewStyle
    let title: TextStyle
    let detail: TextStyle
    let dismiss: ButtonStyle
    let outerImage: ImageStyle
    let innerImage: ImageStyle

    let outerImageSize: LayoutSize
    let imageVerticalPadding: LayoutMetric
    let imageTrailingPadding: LayoutMetric
    let innerImageSize: LayoutSize
    let dismissButtonSize: LayoutSize
    let titleTopPadding: LayoutMetric
    let detailTopPadding: LayoutMetric
    let detailBottomPadding: LayoutMetric
    let titleHorizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.container = [
            .backgroundColor(AppColors.Components.Link.icon.uiColor),
        ]
        self.title = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(11)),
            .textColor(AppColors.Shared.System.background.uiColor.withAlphaComponent(0.6))
        ]
        self.detail = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Shared.System.background.uiColor)
        ]
        self.dismiss = [
            .icon([.normal("icon-close-20")])
        ]
        self.outerImage = [
            .contentMode(.scaleAspectFit)
        ]
        self.innerImage = [
            .contentMode(.scaleAspectFit)
        ]

        self.outerImageSize = LayoutSize(w: 88, h: 88)
        self.imageVerticalPadding = 14
        self.imageTrailingPadding = 28
        self.innerImageSize = LayoutSize(w: 48, h: 48)
        self.dismissButtonSize = LayoutSize(w: 40, h: 40)
        self.titleTopPadding = 22
        self.detailTopPadding = 4
        self.detailBottomPadding = 22
        self.titleHorizontalPadding = 24
    }
}
