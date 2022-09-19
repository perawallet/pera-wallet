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

//   AssetSocialMediaGroupedListItemButtonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetSocialMediaGroupedListItemButtonTheme: GroupedListItemButtonTheme {
    let title: TextStyle
    let spacingBetweenTitleAndContent: LayoutMetric
    let contentSafeAreaInsets: UIEdgeInsets
    let contentPaddings: LayoutPaddings
    let spacingBetweenActions: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.title = [
             .textColor(Colors.Text.grayLighter),
         ]
        self.spacingBetweenTitleAndContent = 14
        self.contentPaddings = (0, 0, 0, 0)
        self.contentSafeAreaInsets = .zero
        self.spacingBetweenActions = 0
    }
}
