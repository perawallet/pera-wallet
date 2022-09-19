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
//   HomePortfolioViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomePortfolioViewTheme:
    StyleSheet,
    LayoutSheet {
    var title: TextStyle
    var titleTopPadding: LayoutMetric
    var infoAction: ButtonStyle
    var value: TextStyle
    var secondaryValue: TextStyle
    var spacingBetweenTitleAndInfoAction: LayoutMetric
    var spacingBetweenTitleAndValue: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        self.title = []
        self.titleTopPadding = 8
        self.infoAction = [
            .icon([ .normal("icon-info-20".templateImage) ])
        ]
        self.value = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.center)
        ]
        self.secondaryValue = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.center)
        ]
        self.spacingBetweenTitleAndInfoAction = 8
        self.spacingBetweenTitleAndValue = 8
    }
}
