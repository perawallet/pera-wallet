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

//   ASADetailQuickActionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADetailQuickActionsViewTheme:
    StyleSheet,
    LayoutSheet {
    var spacingBetweenActions: LayoutMetric
    var actionWidth: LayoutMetric
    var actionSpacingBetweenIconAndTitle: LayoutMetric
    var buyAction: ButtonStyle
    var swapAction: ButtonStyle
    var swapBadge: BadgeButtonTheme
    var swapBadgeEdgeInsets: NSDirectionalEdgeInsets
    var sendAction: ButtonStyle
    var receiveAction: ButtonStyle

    init(_ family: LayoutFamily) {
        self.spacingBetweenActions = 16
        self.actionSpacingBetweenIconAndTitle = 12
        self.actionWidth = 64
        self.buyAction = [
            .icon(Self.makeActionIcon(icon: "buy-algo-icon")),
            .title(Self.makeActionTitle(title: "quick-actions-buy-algo-title".localized))
        ]
        self.swapAction = [
            .icon(Self.makeActionIcon(icon: "swap-icon")),
            .title(Self.makeActionTitle(title: "title-swap".localized))
        ]
        self.swapBadge = BadgeButtonTheme()
        self.swapBadgeEdgeInsets = NSDirectionalEdgeInsets(
            top: 9,
            leading: 0,
            bottom: 0,
            trailing: 16
        )
        self.sendAction = [
            .icon(Self.makeActionIcon(icon: "send-icon")),
            .title(Self.makeActionTitle(title: "quick-actions-send-title".localized))
        ]
        self.receiveAction = [
            .icon(Self.makeActionIcon(icon: "receive-icon")),
            .title(Self.makeActionTitle(title: "quick-actions-receive-title".localized))
        ]
    }
}

extension ASADetailQuickActionsViewTheme {
    private static func makeActionIcon(icon: Image) -> StateImageGroup {
        return [ .normal(icon), .highlighted(icon) ]
    }

    private static func makeActionTitle(title: String) -> Text {
        var attributes = Typography.footnoteRegularAttributes(alignment: .center)
        attributes.insert(.textColor(Colors.Text.main))
        return TextSet(title.attributed(attributes))
    }
}
