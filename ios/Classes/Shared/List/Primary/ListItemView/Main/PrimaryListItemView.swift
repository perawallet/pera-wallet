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

//   PrimaryListItemView.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class PrimaryListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = URLImageView()
    private lazy var loadingIndicatorView = ViewLoadingIndicator()
    private lazy var contentView = UIView()
    private lazy var titleView = PrimaryTitleView()
    private lazy var valueContentView = UIView()
    private lazy var primaryValueView = UILabel()
    private lazy var secondaryValueView = UILabel()

    func customize(
        _ theme: PrimaryListItemViewTheme
    ) {
        addIcon(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: PrimaryListItemViewModel?
    ) {
        if let icon = viewModel?.imageSource {
            iconView.load(from: icon)
        } else {
            iconView.prepareForReuse()
        }

        if let title = viewModel?.title {
            titleView.bindData(title)
        } else {
            titleView.prepareForReuse()
        }

        if let value = viewModel?.primaryValue {
            value.load(in: primaryValueView)
        } else {
            primaryValueView.clearText()
        }

        if let value = viewModel?.secondaryValue {
            value.load(in: secondaryValueView)
        } else {
            secondaryValueView.clearText()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: PrimaryListItemViewModel?,
        for theme: PrimaryListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width

        let titleSize = PrimaryTitleView.calculatePreferredSize(
            viewModel.title,
            for: theme.title,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        let primaryValueSize = viewModel.primaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let secondaryValueSize = viewModel.secondaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let valueContentHeight = primaryValueSize.height + secondaryValueSize.height

        let preferredHeight = max(titleSize.height, valueContentHeight)

        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        titleView.prepareForReuse()
        primaryValueView.clearText()
        secondaryValueView.clearText()
    }
}

extension PrimaryListItemView {
    private func addIcon(
        _ theme: PrimaryListItemViewTheme
    ) {
        iconView.build(theme.icon)
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.leading == 0
            $0.centerY == 0
        }

        addLoadingIndicator(theme)
    }

    private func addLoadingIndicator(
        _ theme: PrimaryListItemViewTheme
    ) {
        loadingIndicatorView.applyStyle(theme.loadingIndicator)

        iconView.addSubview(loadingIndicatorView)
        loadingIndicatorView.snp.makeConstraints {
            $0.fitToSize(theme.loadingIndicatorSize)
            $0.center.equalToSuperview()
        }

        loadingIndicatorView.isHidden = true
    }

    private func addContent(
        _ theme: PrimaryListItemViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.contentHorizontalPadding
            $0.bottom == 0
            $0.trailing == 0
        }

        addTitle(theme)
        addValueContent(theme)
    }

    private func addTitle(
        _ theme: PrimaryListItemViewTheme
    ) {
        titleView.customize(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.width >= (contentView - theme.minSpacingBetweenTitleAndValue) * theme.contentMinWidthRatio
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
            $0.centerY == 0
        }
    }

    private func addValueContent(
        _ theme: PrimaryListItemViewTheme
    ) {
        contentView.addSubview(valueContentView)
        valueContentView.snp.makeConstraints {
            $0.top >= 0
            $0.leading >= titleView.snp.trailing + theme.minSpacingBetweenTitleAndValue
            $0.bottom <= 0
            $0.trailing == 0
            $0.centerY == 0
        }

        addPrimaryValue(theme)
        addSecondaryValue(theme)
    }

    private func addPrimaryValue(
        _ theme: PrimaryListItemViewTheme
    ) {
        primaryValueView.customizeAppearance(theme.primaryValue)

        primaryValueView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryValueView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        valueContentView.addSubview(primaryValueView)
        primaryValueView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSecondaryValue(
        _ theme: PrimaryListItemViewTheme
    ) {
        secondaryValueView.customizeAppearance(theme.secondaryValue)

        secondaryValueView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        secondaryValueView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        
        valueContentView.addSubview(secondaryValueView)
        secondaryValueView.snp.makeConstraints {
            $0.top == primaryValueView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension PrimaryListItemView {
    var isLoading: Bool {
        return loadingIndicatorView.isAnimating
    }
    
    func startLoading() {
        loadingIndicatorView.isHidden = false

        loadingIndicatorView.startAnimating()
    }

    func stopLoading() {
        loadingIndicatorView.isHidden = true

        loadingIndicatorView.stopAnimating()
    }
}
