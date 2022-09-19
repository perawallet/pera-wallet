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

//   BadgeButton.swift

import Foundation
import UIKit
import MacaroonUIKit

enum BadgePosition {
    case topLeading(NSDirectionalEdgeInsets)
    case topTrailing(NSDirectionalEdgeInsets)
}

final class BadgeButton: MacaroonUIKit.Button {
    var isBadgeVisible: Bool = true {
        didSet {
            updateBadgeAppearance()
        }
    }

    private let badgePosition: BadgePosition
    private lazy var badgeView = MacaroonUIKit.BaseView()

    init(
        badgePosition: BadgePosition,
        _ layout: Button.Layout = .none
    ) {
        self.badgePosition = badgePosition
        super.init(layout)
    }

    func customize(theme: BadgeButtonTheme) {
        addBadgeView(theme)
    }

    private func addBadgeView(_ theme: BadgeButtonTheme) {
        badgeView.customizeAppearance(theme.style)
        badgeView.draw(corner: theme.corner)

        addSubview(badgeView)
        switch badgePosition {
        case .topTrailing(let edgeInsets):
            badgeView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(edgeInsets.trailing)
                make.top.equalToSuperview().inset(edgeInsets.top)
                make.size.equalTo(CGSize(theme.size))
            }
        case .topLeading(let edgeInsets):
            badgeView.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(edgeInsets.leading)
                make.top.equalToSuperview().inset(edgeInsets.top)
                make.size.equalTo(CGSize(theme.size))
            }
        }

        updateBadgeAppearance()
    }

    private func updateBadgeAppearance() {
        badgeView.isHidden = !isBadgeVisible
    }
}
