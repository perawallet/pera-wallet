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
//   TransactionResultScreen+Theme.swift


import Foundation
import MacaroonUIKit

extension TransactionResultScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: Color
        let successIcon: ImageStyle
        let titleLabel: TextStyle
        let subtitleLabel: TextStyle
        let successIconSize: LayoutSize
        let successIconCenterYInset: LayoutMetric
        let subtitleTopOffset: LayoutMetric
        let titleTopOffset: LayoutMetric
        let titleLeadingInset: LayoutMetric
        let subtitleLeadingInset: LayoutMetric

        init(_ family: LayoutFamily) {
            backgroundColor = Colors.Defaults.background
            successIcon = [
                .image("icon-approval-check")
            ]
            titleLabel = [
                .textColor(Colors.Text.main),
                .font(Fonts.DMSans.medium.make(19)),
                .textAlignment(.center),
                .textOverflow(FittingText())
            ]
            subtitleLabel = [
                .textColor(Colors.Text.gray),
                .font(Fonts.DMSans.regular.make(15)),
                .textAlignment(.center),
                .textOverflow(FittingText())
            ]
            successIconSize = (48, 48)
            successIconCenterYInset = -60
            titleTopOffset = 36
            subtitleTopOffset = 12
            titleLeadingInset = 24
            subtitleLeadingInset = 24
        }
    }
}
