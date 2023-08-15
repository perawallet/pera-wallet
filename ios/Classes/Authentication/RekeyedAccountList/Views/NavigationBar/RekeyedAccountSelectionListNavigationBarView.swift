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

//   RekeyedAccountSelectionListNavigationBarView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class RekeyedAccountSelectionListNavigationBarView:
    View,
    MacaroonUIKit.NavigationBarLargeTitleView {
    var title: EditText?

    var scrollEdgeOffset: CGFloat {
        return bounds.height - titleView.frame.maxY
    }

    private lazy var iconView = UIImageView()
    private lazy var titleView = UILabel()

    func customize(_ theme: RekeyedAccountSelectionListNavigationBarViewTheme) {
        addIcon(theme)
        addTitle(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: RekeyedAccountSelectionListNavigationBarViewModel?) {
        if let icon = viewModel?.icon?.uiImage {
            iconView.image = icon
        } else {
            iconView.removeFromSuperview()
        }

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.attributedText = nil
            titleView.text = nil
        }
    }
}

extension RekeyedAccountSelectionListNavigationBarView {
    private func addIcon(_ theme: RekeyedAccountSelectionListNavigationBarViewTheme) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addTitle(_ theme: RekeyedAccountSelectionListNavigationBarViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.titleTopMargin
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
