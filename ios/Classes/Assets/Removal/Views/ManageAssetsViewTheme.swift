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
//   ManageAssetsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ManageAssetsViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let subtitle: TextStyle
    let collectionViewTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let titleTopPadding: LayoutMetric
    let subtitleTopPadding: LayoutMetric
    let cellSpacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(32)),
            .textColor(AppColors.Components.Text.main),
            .text("asset-remove-title".localized)
        ]
        self.subtitle = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(AppColors.Components.Text.gray),
            .text("asset-remove-subtitle".localized)
        ]
        self.collectionViewTopPadding = 40
        self.titleTopPadding = 2
        self.subtitleTopPadding = 16
        self.horizontalPadding = 24
        self.cellSpacing = 0
    }
}
