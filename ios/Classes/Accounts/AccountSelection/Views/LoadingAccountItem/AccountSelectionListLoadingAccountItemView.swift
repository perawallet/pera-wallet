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

//   AccountSelectionListLoadingAccountItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountSelectionListLoadingAccountItemView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var iconView = ShimmerView()
    private lazy var contentView = UIView()
    private lazy var titleView = ShimmerView()
    private lazy var subtitleView = ShimmerView()

    func customize(_ theme: AccountSelectionListLoadingAccountItemViewTheme) {
        addIcon(theme)
        addContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AccountSelectionListLoadingAccountItemView {
    private func addIcon(_ theme: AccountSelectionListLoadingAccountItemViewTheme) {
        iconView.draw(corner: theme.iconCorner)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addContent(_ theme: AccountSelectionListLoadingAccountItemViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndContent
            $0.bottom <= 0
            $0.trailing == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(_ theme: AccountSelectionListLoadingAccountItemViewTheme) {
        titleView.draw(corner: theme.corner)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.fitToSize(theme.titleSize)
        }
    }

    private func addSubtitle(_ theme: AccountSelectionListLoadingAccountItemViewTheme) {
        subtitleView.draw(corner: theme.corner)

        contentView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == titleView
            $0.bottom == 0
            $0.fitToSize(theme.subtitleSize)
        }
    }
}
