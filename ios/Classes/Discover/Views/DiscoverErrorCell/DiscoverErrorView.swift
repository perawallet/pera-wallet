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

//   DiscoverErrorView.swift

import Foundation
import MacaroonUIKit
import UIKit

class DiscoverErrorView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .retry: TargetActionInteraction()
    ]

    private lazy var contentView = UIView()
    private lazy var iconView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var bodyView = Label()
    private lazy var retryActionView = UIButton()

    init(_ theme: DiscoverErrorViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension DiscoverErrorView {
    func bindData(_ viewModel: DiscoverErrorViewModel?) {
        iconView.image = viewModel?.icon?.uiImage

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let body = viewModel?.body {
            body.load(in: bodyView)
        } else {
            bodyView.text = nil
            bodyView.attributedText = nil
        }
    }

    static func calculatePreferredSize(
        _ viewModel: DiscoverErrorViewModel?,
        for theme: DiscoverErrorViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let iconSize = theme.iconSize
        let titleSize = viewModel?.title?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let bodySize = viewModel?.body?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredRetryActionHeight =
            (theme.retryAction.font?.uiFont.lineHeight ?? 0) +
            theme.retryActionContentEdgeInsets.vertical
        let retryActionHeight = max(preferredRetryActionHeight, theme.retryActionMinSize.height)
        let preferredHeight =
            theme.contentVerticalEdgeInsets.top +
            iconSize.height +
            theme.spacingBetweenIconAndTitle +
            titleSize.height +
            (bodySize.height == 0 ? 0 : theme.spacingBetweenTitleAndBody) +
            bodySize.height +
            theme.spacingBetweenBodyAndRetryAction +
            retryActionHeight +
            theme.contentVerticalEdgeInsets.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension DiscoverErrorView {
    private func addUI(_ theme: DiscoverErrorViewTheme) {
        addConten(theme)
    }

    private func addConten(_ theme: DiscoverErrorViewTheme) {
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
        addBody(theme)
        addRetryAction(theme)
    }

    private func addIcon(_ theme: DiscoverErrorViewTheme) {
        iconView.customizeAppearance(theme.icon)
        iconView.layer.draw(corner: theme.iconCorner)

        contentView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize((theme.iconSize.width, theme.iconSize.height))
            $0.centerX == 0
            $0.top == 0
        }
    }

    private func addTitle(_ theme: DiscoverErrorViewTheme) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addBody(_ theme: DiscoverErrorViewTheme) {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.contentEdgeInsets = (theme.spacingBetweenTitleAndBody, 0, 0, 0)
        bodyView.fitToVerticalIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addRetryAction(_ theme: DiscoverErrorViewTheme) {
        retryActionView.customizeAppearance(theme.retryAction)

        contentView.addSubview(retryActionView)
        retryActionView.contentEdgeInsets = theme.retryActionContentEdgeInsets
        retryActionView.snp.makeConstraints {
            $0.greaterThanSize((theme.retryActionMinSize.width, theme.retryActionMinSize.height))
            $0.centerX == 0
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndRetryAction
            $0.leading >= 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        startPublishing(
            event: .retry,
            for: retryActionView
        )
    }
}

extension DiscoverErrorView {
    enum Event {
        case retry
    }
}
