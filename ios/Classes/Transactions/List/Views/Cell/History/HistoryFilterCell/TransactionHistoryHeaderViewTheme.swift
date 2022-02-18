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
//   TransactionHistoryHeaderViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TransactionHistoryHeaderViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let titleLabel: TextStyle
    let shareButton: ButtonStyle

    let buttonSize: LayoutSize
    let buttonInset: LayoutMetric
    let horizontalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.titleLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15)),
        ]
        self.shareButton = [
            .icon([.normal("icon-share-gray")])
        ]
        self.buttonSize = (40, 40)
        self.buttonInset = 4
        self.horizontalInset = 24
    }
}
