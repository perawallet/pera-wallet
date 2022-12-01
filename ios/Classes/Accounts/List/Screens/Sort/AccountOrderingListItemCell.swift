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

//   AccountOrderingListItemCell.swift

import UIKit
import MacaroonUIKit

final class AccountOrderingListItemCell:
    CollectionCell<AccountListItemView>,
    ViewModelBindable,
    ShadowDrawable {
    override class var contextPaddings: LayoutPaddings {
        return (14, 24, 14, 24)
    }

    var shadow: MacaroonUIKit.Shadow?
    var shadowLayer: CAShapeLayer = CAShapeLayer()

    static let theme: AccountListItemViewTheme = {
        var theme = AccountListItemViewTheme()
        theme.configureForAccountOrdering()
        return theme
    }()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        contextView.customize(Self.theme)

        draw(
            shadow: MacaroonUIKit.Shadow(
                color: Colors.Shadows.Cards.shadow2.uiColor,
                fillColor: Colors.Defaults.background.uiColor.withAlphaComponent(0.7),
                opacity: 1,
                offset: (0, 2),
                radius: 4,
                cornerRadii: (4, 4),
                corners: .allCorners
            )
        )

        shadowLayer.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        contextView.prepareForReuse()
        shadowLayer.isHidden = true
    }
}

fileprivate extension AccountListItemViewTheme {
    mutating func configureForAccountOrdering() {
        accessoryIcon = accessoryIcon.modify(
            [ .tintColor(Colors.Text.grayLighter) ]
        )
    }
}

extension AccountOrderingListItemCell {
    func recustomizeAppearanceOnMove(
        isMoving: Bool
    ) {
        shadowLayer.isHidden = !isMoving
    }
}
