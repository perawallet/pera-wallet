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
//   AccountPreviewViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountPreviewViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: ImageStyle
    var iconContentEdgeInsets: LayoutOffset
    var contentMinWidthRatio: LayoutMetric
    var title: TextStyle
    var subtitle: TextStyle
    var primaryAccessory: TextStyle
    var secondaryAccessory: TextStyle
    var accessoryIcon: ImageStyle
    var accessoryIconContentEdgeInsets: LayoutOffset
    var minSpacingBetweenContentAndAccessory: LayoutMetric
    var accessoryMinWidthRatio: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.icon = [
            .contentMode(.left)
        ]
        self.iconContentEdgeInsets = (16, 0)
        self.contentMinWidthRatio = 0.25
        self.accessoryMinWidthRatio = 0.35
        self.title = [
            .textColor(AppColors.Components.Text.main)
        ]
        self.subtitle = [
            .textColor(AppColors.Components.Text.grayLighter)
        ]
        self.primaryAccessory = [
            .textColor(AppColors.Components.Text.main)
        ]
        self.secondaryAccessory = [
            .textColor(AppColors.Components.Text.grayLighter)
        ]
        self.accessoryIcon = [
            .contentMode(.right)
        ]
        self.accessoryIconContentEdgeInsets = (8, 0)
        self.minSpacingBetweenContentAndAccessory = 8
    }
}
