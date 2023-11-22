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

//   WCSessionProfileViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct WCSessionProfileViewTheme:
    LayoutSheet,
    StyleSheet {
    let icon: URLImageViewStyleSheet & URLImageViewLayoutSheet
    let iconSize: LayoutSize
    let spacingBetweenIconAndTitle: LayoutMetric
    let title: TextStyle
    let spacingBetweenTitleAndLink: LayoutMetric
    let link: TextStyle
    let spacingBetweenLinkAndDescription: LayoutMetric
    let description: TextStyle

    init(_ family: LayoutFamily) {
        self.icon = URLImageViewAssetTheme(family)
        self.iconSize = (40, 40)
        self.spacingBetweenIconAndTitle = 14
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.spacingBetweenTitleAndLink = 8
        self.link = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Helpers.positive)
        ]
        self.spacingBetweenLinkAndDescription = 16
        self.description = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
    }
}
