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

//   WCSessionConnectionProfileViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct WCSessionConnectionProfileViewTheme:
    LayoutSheet,
    StyleSheet {
    let icon: URLImageViewStyleSheet & URLImageViewLayoutSheet
    let iconSize: LayoutSize
    let spacingBetweenIconAndTitle: LayoutMetric
    let title: TextStyle
    let spacingBetweenTitleAndLink: LayoutMetric

    init(_ family: LayoutFamily) {
        self.icon = URLImageViewAssetTheme(family)
        self.iconSize = (72, 72)
        self.spacingBetweenIconAndTitle = 16
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main)
        ]
        self.spacingBetweenTitleAndLink = 8
    }
}
