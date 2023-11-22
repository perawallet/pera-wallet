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

//   WCSessionProfileView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCSessionProfileView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didTapLink: GestureInteraction(gesture: .tap),
        .didLongPressLink: GestureInteraction(gesture: .longPress)
    ]

    private lazy var iconView = URLImageView()
    private lazy var titleView = UILabel()
    private lazy var linkView = UILabel()
    private lazy var descriptionView = Label()

    func customize(_ theme: WCSessionProfileViewTheme) {
        addIcon(theme)
        addTitle(theme)
        addLink(theme)
        addDescription(theme)
    }

    func bindData(_ viewModel: WCSessionProfileViewModel?) {
        iconView.load(from: viewModel?.icon)

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let link = viewModel?.link {
            link.load(in: linkView)
        } else {
            linkView.text = nil
            linkView.attributedText = nil
        }

        if let description = viewModel?.description {
            description.load(in: descriptionView)
        } else {
            descriptionView.text = nil
            descriptionView.attributedText = nil
        }
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionProfileViewModel?,
        for theme: WCSessionProfileViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))
        let iconSize = theme.iconSize
        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let linkSize = viewModel.link?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let descriptionSize = viewModel.description?.boundingSize(
            multiline: true,
            fittingSize: maxContextSize
        ) ?? .zero
        let preferredHeight =
            iconSize.h +
            theme.spacingBetweenIconAndTitle +
            titleSize.height +
            theme.spacingBetweenTitleAndLink +
            linkSize.height +
            theme.spacingBetweenLinkAndDescription +
            descriptionSize.height
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func prepareForReuse() {
        iconView.prepareForReuse()
        titleView.clearText()
        linkView.clearText()
        descriptionView.clearText()
    }
}

extension WCSessionProfileView {
    private func addIcon(_ theme: WCSessionProfileViewTheme) {
        iconView.build(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addTitle(_ theme: WCSessionProfileViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addLink(_ theme: WCSessionProfileViewTheme) {
        linkView.customizeAppearance(theme.link)

        addSubview(linkView)
        linkView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndLink
            $0.leading == 0
            $0.trailing == 0
        }

        startPublishing(
            event: .didTapLink,
            for: linkView
        )
        startPublishing(
            event: .didLongPressLink,
            for: linkView
        )
    }

    private func addDescription(_ theme: WCSessionProfileViewTheme) {
        descriptionView.customizeAppearance(theme.description)

        addSubview(descriptionView)
        descriptionView.contentEdgeInsets.top = theme.spacingBetweenLinkAndDescription
        descriptionView.snp.makeConstraints {
            $0.top == linkView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension WCSessionProfileView {
    enum Event {
        case didTapLink
        case didLongPressLink
    }
}
