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
    let title: TextStyle
    let description: TextStyle
    let backgroundColor: Color
    let indicator: ImageStyle

    let lottie: String

    let collectionViewMinimumLineSpacing: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let listContentInset: LayoutPaddings
    let titleLabelTopPadding: LayoutMetric
    let devicesListTopPadding: LayoutMetric
    let indicatorViewTopPadding: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.medium.make(19)),
            .textColor(Colors.Text.main),
            .text("ledger-device-list-looking".localized)
        ]
        self.description = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.gray),
            .text("tutorial-description-ledger".localized)
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

        self.lottie = UIApplication.shared.isDarkModeDisplay ? "dark-ledger" : "light-ledger" /// <todo>:  Should be handled also on view.

        self.collectionViewMinimumLineSpacing = 20
        self.verticalStackViewTopPadding = 56
        self.verticalStackViewSpacing = 12
        self.listContentInset = (10, 0, 0, 0)
        self.titleLabelTopPadding = 24
        self.devicesListTopPadding = 50
        self.indicatorViewTopPadding = 60
        self.horizontalInset = 24
    }
}
