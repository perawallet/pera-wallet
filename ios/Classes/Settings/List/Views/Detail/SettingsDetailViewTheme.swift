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
//   SettingsDetailViewTheme.swift

import Foundation
import MacaroonUIKit

struct SettingsDetailViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let title: PrimaryTitleViewTheme
    let detail: ImageStyle
    
    let imageSize: LayoutSize
    let titleOffset: LayoutMetric
    let titleInset: LayoutMetric
    let horizontalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = SettingsTitleViewTheme(family)
        self.detail = [
            .image("icon-list-arrow")
        ]
        
        self.imageSize = (24, 24)
        self.titleOffset = 16
        self.titleInset = 9
        self.horizontalInset = 24
    }
}

struct SettingsTitleViewTheme: PrimaryTitleViewTheme {
    let primaryTitle: TextStyle
    let primaryTitleAccessory: ImageStyle
    let primaryTitleAccessoryContentEdgeInsets: LayoutOffset
    let secondaryTitle: TextStyle
    let spacingBetweenPrimaryAndSecondaryTitles: LayoutMetric

    init(_ family: LayoutFamily) {
        self.primaryTitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.primaryTitleAccessory = []
        self.primaryTitleAccessoryContentEdgeInsets = (0, 0)
        self.secondaryTitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter)
        ]
        self.spacingBetweenPrimaryAndSecondaryTitles = 0
    }
}
