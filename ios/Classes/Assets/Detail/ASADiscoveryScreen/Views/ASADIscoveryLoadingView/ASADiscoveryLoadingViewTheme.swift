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

//   ASADiscoveryLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADiscoveryLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var profile: ViewStyle
    var profileContentEdgeInsets: NSDirectionalEdgeInsets
    var iconSize: LayoutSize
    var iconCorner: Corner
    var spacingBetweenIconAndTitle: LayoutMetric
    var titleSize: LayoutSize
    var spacingBetweenTitleAndValue: LayoutMetric
    var valueSize: LayoutSize
    var about: ASAAboutLoadingViewTheme
    var corner: Corner

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.profile = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        self.profileContentEdgeInsets = .init(top: 50, leading: 24, bottom: 36, trailing: 24)
        self.iconSize = (40, 40)
        self.iconCorner = Corner(radius: iconSize.h / 2)
        self.spacingBetweenIconAndTitle = 20
        self.titleSize = (90, 20)
        self.spacingBetweenTitleAndValue = 8
        self.valueSize = (210, 36)
        self.about = ASAAboutLoadingViewTheme()
        self.corner = Corner(radius: 4)
    }
}
