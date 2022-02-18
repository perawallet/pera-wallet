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
//   BottomWarningViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BottomWarningViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle
    let mainButtonTheme: ButtonTheme
    let secondaryButtonTheme: ButtonTheme

    let verticalInset: LayoutMetric
    let buttonInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let titleTopInset: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText()),
        ]
        self.description = [
            .textColor(AppColors.Components.Text.gray),
            .textOverflow(FittingText()),
        ]

        self.mainButtonTheme = ButtonPrimaryTheme()
        self.secondaryButtonTheme = ButtonSecondaryTheme()

        self.buttonInset = 16
        self.verticalInset = 32
        self.horizontalInset = 24
        self.topInset = 32
        self.titleTopInset = 20
        self.descriptionTopInset = 12
        self.bottomInset = 16
    }
}
