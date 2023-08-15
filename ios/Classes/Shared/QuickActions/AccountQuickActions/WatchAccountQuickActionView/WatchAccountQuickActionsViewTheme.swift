// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WatchAccountQuickActionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WatchAccountQuickActionsViewTheme:
    StyleSheet,
    LayoutSheet {
    var spacingBetweenActions: LayoutMetric
    var actionWidth: LayoutMetric
    var actionSpacingBetweenIconAndTitle: LayoutMetric
    var copyAddressAction: ButtonStyle
    var showAddressAction: ButtonStyle
    var moreAction: ButtonStyle

    init(_ family: LayoutFamily) {
        self.spacingBetweenActions = 16
        self.actionSpacingBetweenIconAndTitle = 12
        self.actionWidth = 80
        self.copyAddressAction = [
            .icon(Self.makeActionIcon(icon: "copy-address-icon")),
            .title(Self.makeActionTitle(title: "title-copy-address-capitalized-sentence".localized))
        ]
        self.showAddressAction = [
            .icon(Self.makeActionIcon(icon: "address-icon")),
            .title(Self.makeActionTitle(title: "title-show-address-capitalized-sentence".localized))
        ]
        self.moreAction = [
            .icon(Self.makeActionIcon(icon: "more-icon")),
            .title(Self.makeActionTitle(title: "quick-actions-more-title".localized))
        ]
    }
}

extension WatchAccountQuickActionsViewTheme {
    private static func makeActionIcon(icon: Image) -> StateImageGroup {
        return [ .normal(icon), .highlighted(icon) ]
    }

    private static func makeActionTitle(title: String) -> Text {
        var attributes = Typography.footnoteRegularAttributes(alignment: .center)
        attributes.insert(.textColor(Colors.Text.main))
        return TextSet(title.attributed(attributes))
    }
}
