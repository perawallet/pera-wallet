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
//   BannerViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BannerViewTheme: LayoutSheet, StyleSheet {
    let contentPaddings: LayoutPaddings

    var backgroundShadow: MacaroonUIKit.Shadow?

    let icon: ImageStyle
    let iconContentEdgeInsets: LayoutOffset
    let iconSize: LayoutSize

    var title: TextStyle

    var message: TextStyle
    let messageContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        contentPaddings = (16, 16, 16, 16)

        backgroundShadow =
        MacaroonUIKit.Shadow(
            color: AppColors.Shared.Helpers.negative.uiColor,
            opacity: 0.2,
            offset: (0, 8),
            radius: 20,
            fillColor: AppColors.Shared.Helpers.negative.uiColor,
            cornerRadii: (12, 12),
            corners: .allCorners
        )

        icon = [
            .contentMode(.left),
        ]
        iconContentEdgeInsets = (12, 0)
        iconSize = (24, 24)
        
        title = [
            .textOverflow(FittingText()),
            .textColor(AppColors.Shared.System.background)
        ]
        message = [
            .textOverflow(FittingText()),
            .textColor(AppColors.Shared.System.background)
        ]
        messageContentEdgeInsets = (4, 0, 0, 0)
    }
}

extension BannerViewTheme {
    mutating func configureForInfo() {
        backgroundShadow =
        MacaroonUIKit.Shadow(
            color: rgba(0.0, 0.0, 0.0, 0.1),
            opacity: 1,
            offset: (0, 8),
            radius: 20,
            fillColor: Colors.Background.secondary,
            cornerRadii: (12, 12),
            corners: .allCorners
        )

        title = title.modify([ .textColor(AppColors.Components.Text.main) ])
        message = message.modify([ .textColor(AppColors.Components.Text.main) ])
    }
}
