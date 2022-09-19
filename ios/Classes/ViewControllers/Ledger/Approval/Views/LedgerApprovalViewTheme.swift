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
//   LedgerApprovalViewTheme.swift

import MacaroonUIKit
import UIKit

struct LedgerApprovalViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle

    let lottie: String

    let cancelButtonTheme: ButtonTheme

    let verticalInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let titleTopInset: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(19)),
            .textAlignment(.center),
            .textOverflow(FittingText())
        ]
        self.description = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.center),
            .textOverflow(FittingText())
        ]
        self.lottie = UIApplication.shared.isDarkModeDisplay ? "dark-ledger" : "light-ledger" /// <todo>:  Should be handled also on view.

        self.cancelButtonTheme = ButtonSecondaryTheme()

        self.verticalInset = 32
        self.horizontalInset = 24
        self.topInset = 42
        self.titleTopInset = 28
        self.descriptionTopInset = 12
        self.bottomInset = 16
    }
}
