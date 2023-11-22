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
//   AccountNameViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol ImageWithTitleViewTheme: StyleSheet, LayoutSheet {
    var titleLabel: TextStyle { get }
    var horizontalPadding: LayoutMetric { get }
    var imageSize: LayoutSize { get }
    var imageBottomRightBadgePaddings: LayoutPaddings { get }
}

struct SwitchAccountNameViewTheme: ImageWithTitleViewTheme {
    let horizontalPadding: LayoutMetric
    let imageSize: LayoutSize
    let imageBottomRightBadgePaddings: LayoutPaddings

    var titleLabel: TextStyle {
        return [
            .textOverflow(SingleLineText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
    }

    init(_ family: LayoutFamily) {
        self.imageSize = (40, 40)
        self.horizontalPadding = 16
        self.imageBottomRightBadgePaddings = (20, 20, .noMetric, .noMetric)
    }
}

struct WCAccountNameViewSmallTheme: ImageWithTitleViewTheme {
    let horizontalPadding: LayoutMetric
    let imageSize: LayoutSize
    let imageBottomRightBadgePaddings: LayoutPaddings

    var titleLabel: TextStyle {
        return [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
    }

    init(_ family: LayoutFamily) {
        self.imageSize = (24, 24)
        self.horizontalPadding = 12
        self.imageBottomRightBadgePaddings = (10, 10, .noMetric, .noMetric)
    }
}
