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
//   RekeyConfirmationViewTheme.swift

import MacaroonUIKit
import UIKit

struct RekeyConfirmationViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let backgroundColor: Color
    let infoImage: ImageStyle
    let feeTitle: TextStyle
    let lottie: String 

    let finalizeButtonTheme: ButtonTheme

    let horizontalPadding: LayoutMetric
    let titleTopPadding: LayoutMetric
    let bottomPadding: LayoutMetric
    let feeTitlePaddings: LayoutPaddings
    let rekeyOldTransitionViewTopPadding: LayoutMetric
    let loadingImageVerticalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(32)),
            .textColor(Colors.Text.main),
            .text("ledger-rekey-confirm-title".localized)
        ]
        if let i = img("icon-info-gray") {
            self.infoImage = [
                .image(i)
            ]
        } else {
            self.infoImage = []
        }
        self.feeTitle = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(13)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.lottie = UIApplication.shared.isDarkModeDisplay ? "dark-rekey" : "light-rekey" /// <todo>:  Should be handled also on view.
        self.finalizeButtonTheme = ButtonPrimaryTheme()

        self.titleTopPadding = 2
        self.horizontalPadding = 24
        self.feeTitlePaddings = (0, 52, 22, 0)
        self.bottomPadding = 16
        self.rekeyOldTransitionViewTopPadding = 105
        self.loadingImageVerticalPadding = 28
    }
}
