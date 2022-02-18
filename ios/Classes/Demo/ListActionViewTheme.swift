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
//   ListActionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ListActionViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: ImageStyle
    var iconContentEdgeInsets: LayoutOffset
    var contentMinHeight: LayoutMetric
    var contentVerticalPaddings: LayoutVerticalPaddings
    var title: TextStyle
    var subtitle: TextStyle
    var spacingBetweenTitleAndSubtitle: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        self.icon = [
            .contentMode(.left),
            .isInteractable(false)
        ]
        self.iconContentEdgeInsets = (20, 0)
        self.contentMinHeight = 36
        self.contentVerticalPaddings = (12, 12)
        self.title = [
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText()),
            .isInteractable(false)
        ]
        self.subtitle = [
            .textColor(AppColors.Components.Text.gray)
        ]
        self.spacingBetweenTitleAndSubtitle = 2
    }
}
