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
//   WCSingleTransactionRequestMiddleViewTheme.swift

import Foundation
import MacaroonUIKit

struct WCSingleTransactionRequestMiddleViewTheme:
    LayoutSheet,
    StyleSheet {
    let verticalStackViewSpacing: LayoutMetric
    let horizontalStackViewHeight: LayoutMetric
    let horizontalStackViewSpacing: LayoutMetric
    let titleLabel: TextStyle
    let subtitleLabel: TextStyle
    let iconHeight: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.verticalStackViewSpacing = 4
        self.horizontalStackViewHeight = 50
        self.horizontalStackViewSpacing = 8
        self.iconHeight = 24
        self.titleLabel = [
            .textOverflow(SingleLineText()),
            .textAlignment(.center),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(36))
        ]
        self.subtitleLabel = [
            .textOverflow(MultilineText(numberOfLines: 2)),
            .textAlignment(.center),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15))
        ]
    }
}
