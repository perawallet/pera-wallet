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
//   ErrorViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ErrorViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: ImageStyle
    var iconContentEdgeInsets: LayoutOffset
    var message: TextStyle
    var separator: Separator
    var spacingBetweenMessageAndSeparator: LayoutMetric

    init(_ family: LayoutFamily) {
        self.icon = [
            .contentMode(.left)
        ]
        self.iconContentEdgeInsets = (8, 0)
        self.message = [
            .textColor(Colors.Helpers.negative),
            .textOverflow(FittingText())
        ]
        self.separator = Separator(color: Colors.Layer.grayLighter, size: 1)
        self.spacingBetweenMessageAndSeparator = 28
    }
}
