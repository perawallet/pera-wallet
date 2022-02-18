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
//   AssetImageViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol AssetImageViewTheme: StyleSheet, LayoutSheet {
    var nameText: TextStyle { get }
    var border: Border { get }
    var corner: Corner { get }
}

struct AssetImageViewLargerTheme: AssetImageViewTheme {
    let nameText: TextStyle
    let border: Border
    let corner: Corner

    init(_ family: LayoutFamily) {
        self.nameText = [
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.border = Border(color: AppColors.Shared.Layer.grayLighter.uiColor, width: 1)
        self.corner = Corner(radius: 20)
    }
}

struct AssetImageViewSmallerTheme: AssetImageViewTheme {
    let nameText: TextStyle
    let border: Border
    let corner: Corner

    init(_ family: LayoutFamily) {
        self.nameText = [
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(10))
        ]
        self.border = Border(color: AppColors.Shared.Layer.grayLighter.uiColor, width: 1)
        self.corner = Corner(radius: 12)
    }
}
