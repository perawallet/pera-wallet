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

//   DiscoverSearchListNotFoundViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct DiscoverSearchListNotFoundViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentVerticalEdgeInsets: LayoutVerticalPaddings
    var icon: ImageStyle
    var iconSize: CGSize
    var iconCorner: Corner
    var spacingBetweenIconAndTitle: CGFloat
    var title: TextStyle

    init(_ family: LayoutFamily) {
        self.contentVerticalEdgeInsets = (8, 8)
        self.icon = [
            .backgroundColor(Colors.Discover.helperGray.uiColor.withAlphaComponent(0.1)),
            .contentMode(.center),
            .tintColor(Colors.Discover.textGrayLighter)
        ]
        self.iconSize = .init(width: 48, height: 48)
        self.iconCorner = 16
        self.spacingBetweenIconAndTitle = 20
        self.title = [
            .textAlignment(.center),
            .textColor(Colors.Discover.textMain),
            .textOverflow(FittingText())
        ]
    }
}
