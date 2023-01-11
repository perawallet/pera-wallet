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

//   WCSessionListViewControllerTheme.swift

import Foundation
import MacaroonUIKit

struct WCSessionListViewControllerTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let disconnectAllAction: ButtonStyle
    let disconnectAllActionEdgeInsets: LayoutPaddings
    let disconnectAllActionMargins: LayoutMargins
    let disconnectAllActionCorner: Corner
    let spacingBetweenListAndDisconnectAllAction: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.disconnectAllAction = [
            .title("wallet-connect-session-disconnect-all-action".localized),
            .titleColor([
                .normal(Colors.Button.Secondary.text)
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.disconnectAllActionEdgeInsets = (16, 8, 16, 8)
        self.disconnectAllActionMargins = (.noMetric, 24, 12, 24)
        self.disconnectAllActionCorner = Corner(radius: 4)
        self.spacingBetweenListAndDisconnectAllAction = 16
    }
}
