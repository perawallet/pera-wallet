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

//
//   BannerView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class BannerView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: UIBlockInteraction()
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)

        linkInteractors()
    }

    private lazy var contentView = UIView()
    private lazy var iconView = ImageView()
    private lazy var titleView = Label()
    private lazy var messageView = Label()

    func customize(
        _ theme: BannerViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func linkInteractors() {
        addBannerTapGesture()
    }

    func bindData(
        _ viewModel: BannerViewModel?
    ) {
        titleView.editText = viewModel?.title
        messageView.editText = viewModel?.message
        iconView.image = viewModel?.icon?.uiImage
    }
}

extension BannerView {
    private func addBannerTapGesture() {
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapBanner))
        )
    }

    @objc
    private func didTapBanner() {
        let interaction = uiInteractions[.performAction]
        interaction?.publish()
    }
}

extension BannerView {
    private func addBackground(
        _ theme: BannerViewTheme
    ) {
        drawAppearance(shadow: theme.backgroundShadow)
    }

    private func addContent(
        _ theme: BannerViewTheme
    ) {
        addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.setPaddings(
                theme.contentPaddings
            )
        }

        addIcon(theme)
        addTitle(theme)
        addMessage(theme)
    }

    private func addIcon(
        _ theme: BannerViewTheme
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
        _ theme: BannerViewTheme
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
        _ theme: BannerViewTheme
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
}

extension BannerView {
    enum Event {
        case performAction
    }
}
