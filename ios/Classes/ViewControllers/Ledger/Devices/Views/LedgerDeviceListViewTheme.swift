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
//   LedgerDeviceListViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct LedgerDeviceListViewTheme: StyleSheet, LayoutSheet {
    let imageLight: String
    let imageDark: String
    let title: TextStyle
    let description: TextStyle
    let backgroundColor: Color
    let indicator: ImageStyle
    let collectionViewMinimumLineSpacing: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let listContentInset: LayoutPaddings
    let titleLabelTopPadding: LayoutMetric
    let devicesListTopPadding: LayoutMetric
    let indicatorViewTopPadding: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.imageLight = "light-ledger"
        self.imageDark = "dark-ledger"
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .text("ledger-device-list-looking".localized.bodyLargeMedium())
        ]
        self.description = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .text("ledger-device-list-body".localized.bodyRegular())
        ]
        if let i = img("loading-indicator") {
            self.indicator = [
                .image(i),
                .contentMode(.scaleAspectFill)
            ]
        } else {
            self.indicator = [
                .contentMode(.scaleAspectFill)
            ]
        }

        self.collectionViewMinimumLineSpacing = 20
        self.verticalStackViewTopPadding = 40
        self.verticalStackViewSpacing = 12
        self.listContentInset = (10, 0, 0, 0)
        self.titleLabelTopPadding = 24
        self.devicesListTopPadding = 30
        self.indicatorViewTopPadding = 60
        self.horizontalInset = 24
    }
}
