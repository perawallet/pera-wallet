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

//   DiscoverSearchNextListErrorViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct DiscoverSearchNextListErrorViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentVerticalEdgeInsets: LayoutVerticalPaddings
    var body: TextStyle
    var spacingBetweenBodyAndRetryAction: CGFloat
    var retryAction: ButtonStyle
    var retryActionContentEdgeInsets: UIEdgeInsets

    init(_ family: LayoutFamily) {
        self.contentVerticalEdgeInsets = (20, 16)
        self.body = [
            .textAlignment(.center),
            .textColor(Colors.Discover.textGray),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenBodyAndRetryAction = 20
        self.retryAction = [
            .backgroundImage([
                .normal("primary-btn-bg"),
                .highlighted("primary-btn-bg-highlighted")
            ]),
            .font(Typography.footnoteMedium()),
            .title("title-try-again".localized),
            .titleColor([
                .normal(Colors.Discover.buttonPrimaryText)
            ])
        ]
        self.retryActionContentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
    }
}
