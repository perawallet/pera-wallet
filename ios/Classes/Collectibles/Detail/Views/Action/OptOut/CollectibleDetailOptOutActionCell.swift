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

//   CollectibleDetailOptOutActionCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleDetailOptOutActionCell:
    CollectionCell<UIButton>,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]

    static let theme = CollectibleDetailOptOutActionCellTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let theme = Self.theme
        contextView.contentEdgeInsets = UIEdgeInsets(theme.contextEdgeInsets)
        contextView.customizeAppearance(theme.context)

        startPublishing(
            event: .performAction,
            for: contextView
        )
    }

    public static func calculatePreferredSize(
        for theme: CollectibleDetailOptOutActionCellTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let contextFontLineHeight = theme.contextFont.lineHeight
        let preferredHeight =
        theme.contextEdgeInsets.top +
        contextFontLineHeight +
        theme.contextEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleDetailOptOutActionCell {
    enum Event {
        case performAction
    }
}
