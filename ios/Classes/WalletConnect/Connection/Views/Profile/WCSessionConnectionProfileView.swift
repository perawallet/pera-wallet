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

//   WCSessionConnectionProfileView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCSessionConnectionProfileView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didTapLink: TargetActionInteraction(),
    ]

    private lazy var iconView = URLImageView()
    private lazy var titleView = UILabel()
    private lazy var linkView = MacaroonUIKit.Button(.imageAtLeft(spacing: 12))

    func customize(_ theme: WCSessionConnectionProfileViewTheme) {
        addIcon(theme)
        addTitle(theme)
        addLink(theme)
    }

    func bindData(_ viewModel: WCSessionConnectionProfileViewModel?) {
        iconView.load(from: viewModel?.icon)

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let link = viewModel?.link {
            linkView.customizeAppearance(link)
        } else {
            linkView.resetAppearance()
        }
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionConnectionProfileViewModel?,
        for theme: WCSessionConnectionProfileViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))
        let iconSize = theme.iconSize
        let titleSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: maxContextSize
        ) ?? .zero
        let linkTitleSize = viewModel.link?.title?.text.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let linkIconSize = viewModel.link?.icon?[.normal]?.size ?? .zero
        let linkSize = max(linkTitleSize.height, linkIconSize.height)
        let preferredHeight =
            iconSize.h +
            theme.spacingBetweenIconAndTitle +
            titleSize.height +
            theme.spacingBetweenTitleAndLink +
            linkSize
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func prepareForReuse() {
        iconView.prepareForReuse()
        titleView.clearText()
        linkView.resetAppearance()
    }
}

extension WCSessionConnectionProfileView {
    private func addIcon(_ theme: WCSessionConnectionProfileViewTheme) {
        iconView.build(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.top == 0
            $0.centerX == 0
        }
    }

    private func addTitle(_ theme: WCSessionConnectionProfileViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addLink(_ theme: WCSessionConnectionProfileViewTheme) {
        addSubview(linkView)
        linkView.fitToIntrinsicSize()
        linkView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndLink
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        startPublishing(
            event: .didTapLink,
            for: linkView
        )
    }
}

extension WCSessionConnectionProfileView {
    enum Event {
        case didTapLink
    }
}
