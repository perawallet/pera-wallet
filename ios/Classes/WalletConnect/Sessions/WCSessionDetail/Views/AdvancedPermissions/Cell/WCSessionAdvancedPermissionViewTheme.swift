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

//   WCSessionAdvancedPermissionViewTheme.swift

import Foundation
import UIKit
import MacaroonUIKit

struct WCSessionAdvancedPermissionViewTheme: PrimaryTitleViewTheme {
    let primaryTitle: TextStyle
    let primaryTitleAccessory: ImageStyle
    let primaryTitleAccessoryContentEdgeInsets: LayoutOffset
    let secondaryTitle: TextStyle
    let spacingBetweenPrimaryAndSecondaryTitles: LayoutMetric

    init(_ family: LayoutFamily) {
        self.primaryTitle = [
            .textColor(Colors.Text.gray),
        ]
        self.primaryTitleAccessory = []
        self.primaryTitleAccessoryContentEdgeInsets = (0, 0)
        self.secondaryTitle = [ .textColor(Colors.Text.main) ]
        self.spacingBetweenPrimaryAndSecondaryTitles = 8
    }
}
