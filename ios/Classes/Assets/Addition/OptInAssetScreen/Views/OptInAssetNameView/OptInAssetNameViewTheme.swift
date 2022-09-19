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

//   OptInAssetNameViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

/// <todo>
/// Just one of these themes is enough to cover all, i.e. TransferAssetBalanceNameViewTheme etc.
struct OptInAssetNameViewTheme: PrimaryTitleViewTheme {
    var primaryTitle: TextStyle
    var primaryTitleAccessory: ImageStyle
    var primaryTitleAccessoryContentEdgeInsets: LayoutOffset
    var secondaryTitle: TextStyle
    var spacingBetweenPrimaryAndSecondaryTitles: LayoutMetric

    init(_ family: LayoutFamily) {
        self.primaryTitle = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineFittingText())
        ]
        self.primaryTitleAccessory = [
            .contentMode(.right),
        ]
        self.primaryTitleAccessoryContentEdgeInsets = (8, 0)
        self.secondaryTitle = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineFittingText())
        ]
        self.spacingBetweenPrimaryAndSecondaryTitles = 4
    }
}
