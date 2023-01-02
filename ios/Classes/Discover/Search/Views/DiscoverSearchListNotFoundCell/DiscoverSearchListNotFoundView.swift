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

//   DiscoverSearchListNotFoundView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class DiscoverSearchListNotFoundView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var contentView = UIView()
    private lazy var iconView = UIImageView()
    private lazy var titleView = UILabel()

    init(_ theme: DiscoverSearchListNotFoundViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension DiscoverSearchListNotFoundView {
    func bindData(_ viewModel: DiscoverSearchListNotFoundViewModel?) {
        iconView.image = viewModel?.icon?.uiImage

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }
    }

    static func calculatePreferredSize(
        _ viewModel: DiscoverSearchListNotFoundViewModel?,
        for theme: DiscoverSearchListNotFoundViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let iconSize = theme.iconSize
        let titleSize = viewModel?.title?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight =
            theme.contentVerticalEdgeInsets.top +
            iconSize.height +
            theme.spacingBetweenIconAndTitle +
            titleSize.height +
            theme.contentVerticalEdgeInsets.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension DiscoverSearchListNotFoundView {
    private func addUI(_ theme: DiscoverSearchListNotFoundViewTheme) {
        addContent(theme)
    }

    private func addContent(_ theme: DiscoverSearchListNotFoundViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= theme.contentVerticalEdgeInsets.top
            $0.leading == 0
            $0.bottom <= theme.contentVerticalEdgeInsets.bottom
            $0.trailing == 0
        }

        addIcon(theme)
        addTitle(theme)
    }

    private func addIcon(_ theme: DiscoverSearchListNotFoundViewTheme) {
        iconView.customizeAppearance(theme.icon)
        iconView.layer.draw(corner: theme.iconCorner)

        contentView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize((theme.iconSize.width, theme.iconSize.height))
            $0.centerX == 0
            $0.top == 0
        }
    }

    private func addTitle(_ theme: DiscoverSearchListNotFoundViewTheme) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
