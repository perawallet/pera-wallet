// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCV1SessionBadgeViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCV1SessionBadgeViewTheme:
    StyleSheet,
    LayoutSheet {
    let badge: TextStyle
    let badgeCorner: Corner
    let badgeContentEdgeInsets: LayoutPaddings
    let spacingBetweenBadgeAndInfo: LayoutMetric
    let info: TextStyle

    init(_ family: LayoutFamily) {
        self.badge = [
            .textColor(Colors.Text.gray),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.badgeCorner = Corner(radius: 14)
        self.badgeContentEdgeInsets =  (3, 6, 3, 6)
        self.spacingBetweenBadgeAndInfo = 8
        self.info = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
    }
}
