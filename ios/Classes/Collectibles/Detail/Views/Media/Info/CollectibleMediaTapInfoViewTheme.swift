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

//   CollectibleMediaTapInfoViewTheme.swift

import UIKit
import MacaroonUIKit

struct CollectibleMediaTapInfoViewTheme:
    StyleSheet,
    LayoutSheet {
    let image: ImageStyle
    let title: TextStyle

    let iconOffset: LayoutMetric
    let iconSize: LayoutSize

    init(
        _ family: LayoutFamily
    ) {
        image = [
            .image("icon-3d"),
            .contentMode(.scaleAspectFit)
        ]
        title = [
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .text(Self.getTitle())
        ]

        iconOffset = 8
        iconSize = (24, 24)
    }
}

extension CollectibleMediaTapInfoViewTheme {
    private static func getTitle() -> EditText {
        let font = Fonts.DMSans.medium.make(13)
        let lineHeightMultiplier = 1.18

        return .attributedString(
            "collectible-detail-tap-3D"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.left),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}
