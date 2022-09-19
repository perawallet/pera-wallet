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

//   AccountQuickActionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountQuickActionsViewTheme:
    StyleSheet,
    LayoutSheet {
    var maxContentHorizontalInsets: LayoutHorizontalPaddings
    var spacingBetweenActions: LayoutMetric
    var buyAlgoAction: AccountQuickActionViewTheme
    var sendAction: AccountQuickActionViewTheme
    var addressAction: AccountQuickActionViewTheme
    var moreAction: AccountQuickActionViewTheme

    init(
        _ family: LayoutFamily
    ) {
        self.maxContentHorizontalInsets = (12, 12)
        self.spacingBetweenActions = 5

        var buyAlgoAction = AccountQuickActionViewTheme(family)
        buyAlgoAction.icon = "buy-algo-icon"
        buyAlgoAction.title = "quick-actions-buy-algo-title".localized
        self.buyAlgoAction = buyAlgoAction

        var sendAction = AccountQuickActionViewTheme(family)
        sendAction.icon = "send-icon"
        sendAction.title = "quick-actions-send-title".localized
        self.sendAction = sendAction

        var addressAction = AccountQuickActionViewTheme(family)
        addressAction.icon = "address-icon"
        addressAction.title = "quick-actions-address-title".localized
        self.addressAction = addressAction

        var moreAction = AccountQuickActionViewTheme(family)
        moreAction.icon = "more-icon"
        moreAction.title = "quick-actions-more-title".localized
        self.moreAction = moreAction
    }
}

struct AccountQuickActionViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: Image? {
        didSet { style.icon = icon.unwrap { [ .normal($0) ] } }
    }
    var title: String? {
        didSet { style.title = title }
    }

    private(set) var style: ButtonStyle

    let width: CGFloat

    static let spacingBetweenIconAndTitle: CGFloat = 15

    init(
        _ family: LayoutFamily
    ) {
        self.width = 64
        self.style = [
            .font(Fonts.DMSans.regular.make(13)),
            .titleColor([ .normal(Colors.Text.main) ])
        ]
    }
}
