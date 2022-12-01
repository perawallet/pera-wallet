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

//   LoadingScreenTheme.swift

import MacaroonUIKit
import UIKit

struct LoadingScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let imageBackground: ViewStyle
    let imageSize: LayoutSize
    let imagePaddings: LayoutPaddings
    let imageBackgroundCorner: Corner
    let spacingBetweenImageAndTitle: LayoutMetric
    let title: TextStyle
    let titleCenterOffset: LayoutMetric
    let titleHorizontalInset: LayoutMetric
    let detail: TextStyle
    let detailHorizontalInset: LayoutMetric
    let spacingBetweenTitleAndDetail: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.imageBackground = [
            .backgroundColor(Colors.Button.Helper.background)
        ]
        self.imageSize = (60, 60)
        self.imagePaddings = (1,1,1,1)
        self.imageBackgroundCorner = Corner(radius: imageSize.h / 2)
        self.spacingBetweenImageAndTitle = 24
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
            .textAlignment(.center)
        ]
        self.titleCenterOffset = -40
        self.titleHorizontalInset = 60
        self.detail = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
            .textAlignment(.center)
        ]
        self.detailHorizontalInset = 40
        self.spacingBetweenTitleAndDetail = 12
    }
}
