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
//   OptionsContextViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct OptionsContextViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let titleLabel: TextStyle
    let subtitleLabel: TextStyle

    let horizontalInset: LayoutMetric
    let labelLeftInset: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.titleLabel = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main)
        ]
        self.subtitleLabel = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .font(Fonts.DMMono.regular.make(11)),
            .textColor(AppColors.Components.Text.gray)
        ]

        self.horizontalInset = 24
        self.labelLeftInset = 69
        self.verticalStackViewSpacing = 2
    }
}
