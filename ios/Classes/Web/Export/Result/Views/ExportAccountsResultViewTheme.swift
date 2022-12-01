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

//   ExportAccountsResultViewTheme.swift

import Foundation
import MacaroonUIKit

struct ExportAccountsResultViewTheme: ResultViewTheme {
    let icon: ImageStyle
    let iconAlignment: ResultView.IconViewAlignment
    let spacingBetweenIconAndTitle: LayoutMetric
    let title: TextStyle
    let titleHorizontalMargins: LayoutHorizontalMargins
    let spacingBetweenTitleAndBody: LayoutMetric
    let body: TextStyle
    let bodyHorizontalMargins: LayoutHorizontalMargins

    init(
        _ family: LayoutFamily
    ) {
        self.icon = [ .contentMode(.left) ]
        self.iconAlignment = .leading(margin: 10)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main)
        ]
        self.titleHorizontalMargins = (24, 24)
        self.spacingBetweenIconAndTitle = 40
        self.body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
        self.spacingBetweenTitleAndBody = 22
        self.bodyHorizontalMargins = (24, 24)
    }
}
