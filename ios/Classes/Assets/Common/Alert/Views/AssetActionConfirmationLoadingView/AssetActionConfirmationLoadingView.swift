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

//   AssetActionConfirmationLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetActionConfirmationLoadingView:
    UIView,
    ViewModelBindable,
    ShimmerAnimationDisplaying {
    private lazy var contentView = UIView()
    private lazy var titleView = UILabel()
    private lazy var primaryNameView = ShimmerView()
    private lazy var secondaryNameView = ShimmerView()
    private lazy var idView = ShimmerView()
    private lazy var bodyView = UILabel()
    private lazy var bodyAccessoryView = ImageView()
    private lazy var primaryActionView = Button()
    private lazy var secondaryActionView = Button()

    func customize(_ theme: AssetActionConfirmationLoadingViewTheme) {
        addContent(theme)
    }

    func bindData(_ viewModel: AssetActionConfirmationLoadingViewModel?) {
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

        if let bodyAccessory = viewModel?.bodyAccessory {
            bodyAccessory.load(in: bodyAccessoryView)
        } else {
            bodyAccessoryView.image = nil
        }

        primaryActionView.bindData(ButtonCommonViewModel(title: viewModel?.primaryAction))
        secondaryActionView.bindData(ButtonCommonViewModel(title: viewModel?.secondaryAction))
    }

    static func calculatePreferredSize(
        _ viewModel: AssetActionConfirmationLoadingViewModel?,
        for theme: AssetActionConfirmationLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return .zero
    }
}

extension AssetActionConfirmationLoadingView {
    private func addContent(_ theme: AssetActionConfirmationLoadingViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        addTitle(theme)
        addName(theme)
        addID(theme)
        addBody(theme)
        addActions(theme)
    }

    private func addTitle(_ theme: AssetActionConfirmationLoadingViewTheme) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addName(_ theme: AssetActionConfirmationLoadingViewTheme) {
        primaryNameView.draw(corner: theme.shimmeringCorner)

        contentView.addSubview(primaryNameView)
        primaryNameView.snp.makeConstraints {
            $0.fitToSize((theme.primaryNameSize.width, theme.primaryNameSize.height))
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndPrimaryName
            $0.leading == 0
        }

        secondaryNameView.draw(corner: theme.shimmeringCorner)

        contentView.addSubview(secondaryNameView)
        secondaryNameView.snp.makeConstraints {
            $0.fitToSize((theme.secondaryNameSize.width, theme.secondaryNameSize.height))
            $0.top == primaryNameView.snp.bottom + theme.spacingBetweenPrimaryAndSecondaryName
            $0.leading == 0
        }

        contentView.attachSeparator(
            theme.separator,
            to: secondaryNameView,
            margin: theme.spacingBetweenSecondaryNameAndSeparator
        )
    }

    private func addID(_ theme: AssetActionConfirmationLoadingViewTheme) {
        idView.draw(corner: theme.shimmeringCorner)

        contentView.addSubview(idView)
        idView.snp.makeConstraints {
            $0.fitToSize((theme.idSize.width, theme.idSize.height))
            $0.top == secondaryNameView.snp.bottom + theme.spacingBetweenSecondaryNameAndID
            $0.leading == 0
        }

        contentView.attachSeparator(
            theme.separator,
            to: idView,
            margin: theme.spacingBetweenIDAndSeparator
        )
    }

    private func addBody(_ theme: AssetActionConfirmationLoadingViewTheme) {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.fitToVerticalIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == idView.snp.bottom + theme.spacingBetweenIDAndBody
            $0.trailing == 0
        }

        bodyAccessoryView.customizeAppearance(theme.bodyAccessory)

        contentView.addSubview(bodyAccessoryView)
        bodyAccessoryView.contentEdgeInsets = theme.bodyAccessoryContentOffset
        bodyAccessoryView.fitToIntrinsicSize()
        bodyAccessoryView.snp.makeConstraints {
            $0.top == bodyView
            $0.leading == 0
            $0.trailing == bodyView.snp.leading
        }
    }

    private func addActions(_ theme: AssetActionConfirmationLoadingViewTheme) {
        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.isUserInteractionEnabled = false

        contentView.addSubview(primaryActionView)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInset
        primaryActionView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndPrimaryAction
            $0.leading == 0
            $0.trailing == 0
        }

        secondaryActionView.customizeAppearance(theme.secondaryAction)
        secondaryActionView.isUserInteractionEnabled = false

        contentView.addSubview(secondaryActionView)
        secondaryActionView.contentEdgeInsets = theme.secondaryActionContentEdgeInset
        secondaryActionView.snp.makeConstraints {
            $0.top == primaryActionView.snp.bottom + theme.spacingBetweenPrimaryAndSecondaryAction
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
