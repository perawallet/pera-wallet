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

//   AccountSelectionListLoadingAccountItemViewTheme.swift

import Foundation
import MacaroonUIKit

struct AccountSelectionListLoadingAccountItemViewTheme:
    StyleSheet,
    LayoutSheet {
    let corner: Corner
    let iconSize: LayoutSize
    let iconCorner: Corner
    let spacingBetweenIconAndContent: LayoutMetric
    let titleSize: LayoutSize
    let spacingBetweenTitleAndSubtitle: LayoutMetric
    let subtitleSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.corner = Corner(radius: 4)
        self.iconSize = (40, 40)
        self.iconCorner = Corner(radius: iconSize.h / 2)
        self.spacingBetweenIconAndContent = 16
        self.titleSize = (94, 20)
        self.spacingBetweenTitleAndSubtitle = 8
        self.subtitleSize = (44, 16)
    }
}
