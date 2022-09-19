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

//   SendCollectibleViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit
import MacaroonURLImage

struct SendCollectibleViewTheme:
    StyleSheet,
    LayoutSheet {
    let contextViewContainerTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let image: URLImageViewStyleLayoutSheet
    let imageCorner: Corner
    let titleAndSubtitleContainerVerticalPaddings: LayoutVerticalPaddings
    let title: TextStyle
    let subtitle: TextStyle
    let subtitleTopPadding: LayoutMetric
    let imageMinHeight: LayoutMetric
    let actionViewTheme: SendCollectibleActionViewTheme

    init(
        _ family: LayoutFamily
    ) {
        contextViewContainerTopPadding = 56
        horizontalPadding = 24

        image = URLImageViewCollectibleListTheme()
        imageCorner = Corner(radius: 4)

        titleAndSubtitleContainerVerticalPaddings = (16, 16)

        title = [
            .textAlignment(.center),
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]

        subtitle = [
            .textAlignment(.center),
            .textColor(Colors.Text.white),
            .textOverflow(MultilineText(numberOfLines: 2)),
        ]

        subtitleTopPadding = 4
        imageMinHeight = 32
        actionViewTheme = SendCollectibleActionViewTheme()
    }
}
