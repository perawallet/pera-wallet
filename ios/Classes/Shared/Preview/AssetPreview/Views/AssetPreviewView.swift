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
//   AssetPreviewView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class AssetPreviewView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = URLImageView()
    private lazy var contentAndAccessoryContextView = UIView()
    private lazy var contentView = UIView()
    private lazy var titleView = Label()
    private lazy var verifiedIconView = ImageView()
    private lazy var subtitleView = Label()
    private lazy var accessoryView = UIView()
    private lazy var primaryAccessoryView = Label()
    private lazy var secondaryAccessoryView = Label()

    func customize(
        _ theme: AssetPreviewViewTheme
    ) {
        addIconView(theme)
        addContentAndAccessoryContext(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: AssetPreviewViewModel?
    ) {
        iconView.load(from: viewModel?.imageSource)
        titleView.editText = viewModel?.title
        verifiedIconView.image = viewModel?.verificationTierIcon
        subtitleView.editText = viewModel?.subtitle
        primaryAccessoryView.editText = viewModel?.primaryAccessory
        secondaryAccessoryView.editText = viewModel?.secondaryAccessory
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        verifiedIconView.image = nil
        titleView.editText = nil
        subtitleView.editText = nil
        primaryAccessoryView.editText = nil
        secondaryAccessoryView.editText = nil
    }

    class func calculatePreferredSize(
        _ viewModel: AssetPreviewViewModel?,
        for theme: AssetPreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconSize = theme.imageSize
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let primaryAccessorySize = viewModel.primaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let secondaryAccessorySize = viewModel.secondaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let accessoryIconSize = viewModel.verificationTierIcon?.size ?? .zero
        let contentHeight = max(titleSize.height, accessoryIconSize.height) + subtitleSize.height
        let accessoryHeight = primaryAccessorySize.height + secondaryAccessorySize.height
        let preferredHeight = max(iconSize.h, max(contentHeight, accessoryHeight))
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AssetPreviewView {
    private func addIconView(
        _ theme: AssetPreviewViewTheme
    ) {
        iconView.build(theme.icon)
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
            $0.fitToSize(theme.imageSize)
        }
    }

    private func addContentAndAccessoryContext(
        _ theme: AssetPreviewViewTheme
    ) {
        addSubview(contentAndAccessoryContextView)
        contentAndAccessoryContextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.horizontalPadding
            $0.bottom == 0
            $0.trailing == 0
        }

        addContent(theme)
        addAccessory(theme)
    }

    private func addContent(
        _ theme: AssetPreviewViewTheme
    ) {
        contentAndAccessoryContextView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width >= contentAndAccessoryContextView * theme.contentMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(
        _ theme: AssetPreviewViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        contentView.addSubview(titleView)

        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )

        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }

        addVerifiedIcon(theme)
    }

    private func addVerifiedIcon(
        _ theme: AssetPreviewViewTheme
    ) {
        verifiedIconView.customizeAppearance(theme.verifiedIcon)

        contentView.addSubview(verifiedIconView)
        
        verifiedIconView.fitToIntrinsicSize()
        verifiedIconView.contentEdgeInsets = theme.verifiedIconContentEdgeInsets

        verifiedIconView.snp.makeConstraints {
            $0.centerY == titleView
            $0.leading == titleView.snp.trailing
            $0.trailing <= 0
        }
    }

    private func addSubtitle(
        _ theme: AssetPreviewViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)
        
        contentView.addSubview(subtitleView)

        subtitleView.fitToVerticalIntrinsicSize(
            hugging: .required,
            compression: .defaultHigh
        )
        subtitleView.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )

        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addAccessory(
        _ theme: AssetPreviewViewTheme
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
        _ theme: AssetPreviewViewTheme
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

        primaryAccessoryView.contentEdgeInsets.leading = theme.minSpacingBetweenContentAndSecondaryContent
        primaryAccessoryView.snp.makeConstraints {
            $0.top == 0
            $0.trailing == 0
            $0.leading == 0
            $0.bottom
                .equalToSuperview()
                .priority(.low)
        }
    }

    private func addSecondaryAccessory(
        _ theme: AssetPreviewViewTheme
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

        secondaryAccessoryView.contentEdgeInsets.leading = theme.minSpacingBetweenContentAndSecondaryContent
        secondaryAccessoryView.snp.makeConstraints {
            $0.top == primaryAccessoryView.snp.bottom
            $0.bottom == 0
            $0.trailing == 0
            $0.leading == 0
        }
    }
}
