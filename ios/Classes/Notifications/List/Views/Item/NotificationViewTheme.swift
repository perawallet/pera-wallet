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
//   NotificationViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct NotificationViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let badgeImage: ImageStyle
    let notificationImage: URLImageViewStyleSheet & URLImageViewLayoutSheet
    let titleLabel: TextStyle
    let timeLabel: TextStyle
    let cellSpacing: LayoutMetric
    let topInset: LayoutMetric
    let collectionViewEdgeInsets: LayoutPaddings

    let badgeImageSize: LayoutSize
    let notificationImageSize: LayoutSize
    let badgeImageTopPadding: LayoutMetric
    let badgeImageHorizontalPaddings: LayoutHorizontalPaddings
    let notificationImageTopPadding: LayoutMetric
    let titleLabelLeadingPadding: LayoutMetric
    let timeLabelTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let titleLabelBottomPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.badgeImage = [
            .image("img-nc-item-badge")
        ]
        self.notificationImage = URLImageViewAssetTheme()
        self.titleLabel = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.timeLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13))
        ]

        self.badgeImageTopPadding = 36
        self.badgeImageHorizontalPaddings = (12, 8)
        self.notificationImageTopPadding = 16
        self.titleLabelLeadingPadding = 12
        self.timeLabelTopPadding = 4
        self.cellSpacing = 0
        self.collectionViewEdgeInsets = (0, 0, 20, 0)
        self.topInset = 10
        self.horizontalPadding = 24
        self.notificationImageSize = (40, 40)
        self.badgeImageSize = (4, 4)
        self.titleLabelBottomPadding = 37
    }
}
