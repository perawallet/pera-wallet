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

//   ActionableBannerView.swift

import UIKit
import MacaroonUIKit

final class ActionableBannerView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]

    private lazy var contentView = UIView()
    private lazy var iconView = ImageView()
    private lazy var titleView = Label()
    private lazy var messageView = Label()
    private lazy var actionView = MacaroonUIKit.Button()

    func customize(
        _ theme: ActionableBannerViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
        addAction(theme)
    }
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: ActionableBannerViewModel?
    ) {
        titleView.editText = viewModel?.title
        messageView.editText = viewModel?.message
        iconView.image = viewModel?.icon?.uiImage

        if let actionTitle = viewModel?.actionTitle {
            actionView.editTitle = actionTitle
        } else {
            actionView.removeFromSuperview()
        }
    }

    static func calculatePreferredSize(
        _ viewModel: ActionableBannerViewModel?,
        for theme: ActionableBannerViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleFittingWidth =
            (width * theme.contentWidthRatio) -
            theme.iconContentEdgeInsets.x -
            (viewModel.icon?.uiImage.width ?? .zero)
        let titleSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: CGSize((titleFittingWidth, .greatestFiniteMagnitude))
        ) ?? .zero
        let messageSize = viewModel.message?.boundingSize(
            multiline: true,
            fittingSize:  CGSize((titleFittingWidth, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight =
            theme.contentPaddings.top +
            titleSize.height +
            theme.messageContentEdgeInsets.top +
            messageSize.height +
            theme.messageContentEdgeInsets.bottom +
            theme.contentPaddings.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension ActionableBannerView {
    private func addBackground(
        _ theme: ActionableBannerViewTheme
    ) {
        customizeAppearance(theme.background)

        if let corner = theme.corner {
            draw(corner: corner)
        }
    }

    private func addContent(
        _ theme: ActionableBannerViewTheme
    ) {
        addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.width == self * theme.contentWidthRatio
            $0.trailing
                .equalToSuperview()
                .inset(theme.actionHorizontalPaddings.trailing)
                .priority(.medium)
            $0.setPaddings(theme.contentPaddings)
        }

        addIcon(theme)
        addTitle(theme)
        addMessage(theme)
    }

    private func addIcon(
        _ theme: ActionableBannerViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        contentView.addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addTitle(
        _ theme: ActionableBannerViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.trailing == 0
        }
    }

    private func addMessage(
        _ theme: ActionableBannerViewTheme
    ) {
        messageView.customizeAppearance(theme.message)

        contentView.addSubview(messageView)
        messageView.contentEdgeInsets = theme.messageContentEdgeInsets
        messageView.fitToVerticalIntrinsicSize()
        messageView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == titleView.snp.leading
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addAction(
        _ theme: ActionableBannerViewTheme
    ) {
        actionView.customizeAppearance(theme.action)
        actionView.draw(corner: theme.actionCorner)

        addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.leading >= contentView.snp.trailing + theme.actionHorizontalPaddings.leading
            $0.trailing == theme.actionHorizontalPaddings.trailing
            $0.centerY == contentView
        }

        startPublishing(
            event: .performAction,
            for: actionView
        )
    }
}

extension ActionableBannerView {
    enum Event {
        case performAction
    }
}
