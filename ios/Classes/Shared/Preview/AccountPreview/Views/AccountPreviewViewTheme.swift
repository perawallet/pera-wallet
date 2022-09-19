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
    var iconSize: LayoutSize
    var horizontalPadding: LayoutMetric
    var contentMinWidthRatio: LayoutMetric
    var namePreviewView: AccountNamePreviewViewTheme
    var primaryAccessory: TextStyle
    var secondaryAccessory: TextStyle
    var accessoryIcon: ImageStyle
    var accessoryIconContentEdgeInsets: LayoutOffset

    init(
        _ family: LayoutFamily
    ) {
        self.icon = [
            .contentMode(.scaleAspectFit)
        ]
        self.iconSize = (40, 40)
        self.horizontalPadding = 16
        self.contentMinWidthRatio = 0.25
        var namePreviewViewTheme = AccountNamePreviewViewTheme()
        namePreviewViewTheme.configureForAccountPreviewView()
        self.namePreviewView = namePreviewViewTheme
        self.primaryAccessory = [
            .textColor(Colors.Text.main)
        ]
        self.secondaryAccessory = [
            .textColor(Colors.Text.grayLighter)
        ]
        self.accessoryIcon = [
            .contentMode(.right)
        ]
        self.accessoryIconContentEdgeInsets = (8, 0)
    }
}
