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
//   AccountListItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = ImageView()
    private lazy var iconBottomRightBadgeView = UIImageView()
    private lazy var contentAndAccessoryContextView = UIView()
    private lazy var contentView = UIView()
    private lazy var titleView = PrimaryTitleView()
    private lazy var accessoryView = UIView()
    private lazy var primaryAccessoryView = Label()
    private lazy var secondaryAccessoryView = Label()
    private lazy var accessoryIconView = ImageView()

    func customize(
        _ theme: AccountListItemViewTheme
    ) {
        addIcon(theme)
        addContentAndAccessoryContext(theme)
        addAccessoryIcon(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AccountListItemViewModel?
    ) {
        iconView.load(from: viewModel?.icon)
        iconBottomRightBadgeView.image = viewModel?.iconBottomRightBadge?.uiImage
        titleView.bindData(viewModel?.title)
        primaryAccessoryView.editText = viewModel?.primaryAccessory
        secondaryAccessoryView.editText = viewModel?.secondaryAccessory
        accessoryIconView.image = viewModel?.accessoryIcon
    }

    class func calculatePreferredSize(
        _ viewModel: AccountListItemViewModel?,
        for theme: AccountListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        /// <warning>
        /// The constrained widths of the subviews will be discarded from the calculations because
        /// none of them has the multi-line texts.
        let width = size.width
        let iconSize = viewModel.icon?.iconSize ?? .zero
        let titleSize = PrimaryTitleView.calculatePreferredSize(
            viewModel.title,
            for: theme.title,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        let primaryAccessorySize = viewModel.primaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let secondaryAccessorySize = viewModel.secondaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let accessoryIconSize = viewModel.accessoryIcon?.size ?? .zero
        let contentHeight = titleSize.height
        let accessoryTextHeight = primaryAccessorySize.height + secondaryAccessorySize.height
        let accessoryHeight = max(accessoryTextHeight, accessoryIconSize.height)
        let preferredHeight = max(iconSize.height, max(contentHeight, accessoryHeight))
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AccountListItemView {
    private func addIcon(
        _ theme: AccountListItemViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.fitToSize(theme.iconSize)
        }

        addIconBottomRightBadge(theme)
    }

    private func addIconBottomRightBadge(
        _ theme: AccountListItemViewTheme
    ) {
        addSubview(iconBottomRightBadgeView)
        iconBottomRightBadgeView.snp.makeConstraints {
            $0.top == iconView.snp.top + theme.iconBottomRightBadgePaddings.top
            $0.leading == theme.iconBottomRightBadgePaddings.leading
        }
    }

    private func addContentAndAccessoryContext(
        _ theme: AccountListItemViewTheme
    ) {
        addSubview(contentAndAccessoryContextView)
        contentAndAccessoryContextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.horizontalPadding
            $0.bottom == 0
        }

        addContent(theme)
        addAccessory(theme)
    }

    private func addContent(
        _ theme: AccountListItemViewTheme
    ) {
        contentAndAccessoryContextView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width >= contentAndAccessoryContextView * theme.contentMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }

        addTitle(theme)
    }

    private func addTitle(
        _ theme: AccountListItemViewTheme
    ) {
        titleView.customize(theme.title)

        contentView.addSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addAccessory(
        _ theme: AccountListItemViewTheme
    ) {
        contentAndAccessoryContextView.addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.top == 0
            $0.leading == contentView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }

        addPrimaryAccessory(theme)
        addSecondaryAccessory(theme)
    }

    private func addPrimaryAccessory(
        _ theme: AccountListItemViewTheme
    ) {
        primaryAccessoryView.customizeAppearance(theme.primaryAccessory)

        accessoryView.addSubview(primaryAccessoryView)

        primaryAccessoryView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryAccessoryView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        primaryAccessoryView.contentEdgeInsets.leading = theme.horizontalPadding
        primaryAccessoryView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom
                .equalToSuperview()
                .priority(.low)
        }
    }

    private func addSecondaryAccessory(
        _ theme: AccountListItemViewTheme
    ) {
        secondaryAccessoryView.customizeAppearance(theme.secondaryAccessory)

        accessoryView.addSubview(secondaryAccessoryView)

        secondaryAccessoryView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        secondaryAccessoryView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .defaultLow
        )

        secondaryAccessoryView.contentEdgeInsets.leading = theme.horizontalPadding
        secondaryAccessoryView.snp.makeConstraints {
            $0.top == primaryAccessoryView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addAccessoryIcon(
        _ theme: AccountListItemViewTheme
    ) {
        accessoryIconView.customizeAppearance(theme.accessoryIcon)

        addSubview(accessoryIconView)
        accessoryIconView.contentEdgeInsets = theme.accessoryIconContentEdgeInsets
        accessoryIconView.fitToIntrinsicSize()
        accessoryIconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == contentAndAccessoryContextView.snp.trailing
            $0.trailing == 0
        }
    }
}
