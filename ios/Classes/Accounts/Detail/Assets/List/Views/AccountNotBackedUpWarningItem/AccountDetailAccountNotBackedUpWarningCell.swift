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

//   AccountDetailAccountNotBackedUpWarningCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountDetailAccountNotBackedUpWarningCell:
    CollectionCell<ActionableBannerView>,
    ViewModelBindable,
    UIInteractable {
    override class var contextPaddings: LayoutPaddings {
        return (24, 24, 0, 24)
    }

    static let theme: ActionableBannerViewTheme = {
        var theme = ActionableBannerViewTheme()
        theme.corner = Corner(radius: 10)
        theme.contentPaddings = (10, 12, 10, .noMetric)
        theme.icon = [
            .contentMode(.topLeft),
            .tintColor(Colors.Defaults.background)
        ]
        theme.iconContentEdgeInsets = (8, 0)
        theme.actionHorizontalPaddings.trailing = 16
        theme.messageContentEdgeInsets = (0, 0, 0, 0)
        return theme
    }()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contextView.customize(Self.theme)
    }
}
