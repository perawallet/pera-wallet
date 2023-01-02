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
//   ResultViewCommonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ResultViewCommonTheme: ResultViewTheme {
    var icon: ImageStyle
    var iconSize: CGSize?
    var title: TextStyle
    var titleTopMargin: LayoutMetric
    var body: TextStyle
    var bodyTopMargin: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.icon = [
            .adjustsImageForContentSizeCategory(true),
            .contentMode(.center)
        ]
        self.iconSize = nil
        self.title = [
            .font(Fonts.DMSans.medium.make(19)),
            .textAlignment(.center),
            .adjustsFontForContentSizeCategory(true),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main)
        ]
        self.titleTopMargin = 32
        self.body = [
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.center),
            .adjustsFontForContentSizeCategory(true),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
        self.bodyTopMargin = 16
    }
}
