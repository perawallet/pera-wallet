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
//   TransactionOptionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TransactionOptionsViewTheme:
    StyleSheet,
    LayoutSheet {
    var backgroundStart: ViewStyle
    var backgroundEnd: ViewStyle
    var content: ViewStyle
    var contentCorner: Corner
    var contentSafeAreaInsets: UIEdgeInsets
    var contentPaddings: LayoutPaddings
    var spacingBetweenActions: LayoutMetric
    var action: ListItemButtonTheme

    init(
        _ family: LayoutFamily
    ) {
        self.backgroundStart = [
            .backgroundColor(UIColor.clear)
        ]
        self.backgroundEnd = [
            .backgroundColor(Colors.Backdrop.modalBackground.uiColor)
        ]
        self.content = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentCorner = Corner(
            radius: 16,
            mask: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        )
        self.contentPaddings = (32, 20, 44, 20)
        self.contentSafeAreaInsets = .zero
        self.spacingBetweenActions = 20
        var action = ListItemButtonTheme()
        action.configureForTransactionOptionsView()
        self.action = action
    }
}
