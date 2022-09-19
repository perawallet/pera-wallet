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

//   CollectibleExternalSourceViewTheme.swift

import MacaroonUIKit

struct CollectibleExternalSourceViewTheme:
    StyleSheet,
    LayoutSheet {
    let backgroundColor: Color
    let icon: ImageStyle
    let title: TextStyle

    let iconSize: LayoutSize
    let verticalInset: LayoutMetric
    let titleHorizontalPadding: LayoutMetric
    let actionSize: LayoutSize

    init(
        _ family: LayoutFamily
    ) {
        self.backgroundColor = Colors.Defaults.background
        self.icon = [
            .contentMode(.scaleAspectFit)
        ]
        self.title = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main)
        ]

        self.iconSize = LayoutSize(w: 24, h: 24)
        self.verticalInset = 18
        self.titleHorizontalPadding = 12
        self.actionSize = LayoutSize(w: 40, h: 40)
    }
}
