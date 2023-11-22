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

//   WCV1SessionBadgeView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCV1SessionBadgeView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var badgeView = Label()
    private lazy var infoView = UILabel()

    func customize(_ theme: WCV1SessionBadgeViewTheme) {
        addBadge(theme)
        addInfo(theme)
    }

    static func calculatePreferredSize(
        _ viewModel: WCV1SessionBadgeViewModel?,
        for theme: WCV1SessionBadgeViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))
        let badgeSize = viewModel.info?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let preferredHeight =
            theme.badgeContentEdgeInsets.top +
            badgeSize.height +
            theme.badgeContentEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) { }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) { }

    func bindData(_ viewModel: WCV1SessionBadgeViewModel?) {
        if let badge = viewModel?.badge {
            badge.load(in: badgeView)
        } else {
            badgeView.clearText()
        }

        if let info = viewModel?.info {
            info.load(in: infoView)
        } else {
            infoView.clearText()
        }
    }
}

extension WCV1SessionBadgeView {
    private func addBadge(_ theme: WCV1SessionBadgeViewTheme) {
        badgeView.customizeAppearance(theme.badge)
        badgeView.draw(corner: theme.badgeCorner)
        badgeView.contentEdgeInsets = theme.badgeContentEdgeInsets

        addSubview(badgeView)
        badgeView.fitToHorizontalIntrinsicSize()
        badgeView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addInfo(_ theme: WCV1SessionBadgeViewTheme) {
        infoView.customizeAppearance(theme.info)

        addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.leading == badgeView.snp.trailing + theme.spacingBetweenBadgeAndInfo
            $0.trailing == 0
            $0.centerY == badgeView
        }
    }
}
