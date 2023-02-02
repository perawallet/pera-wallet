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

//   CollectibleDetailLoadingView.swift

import UIKit
import MacaroonUIKit

final class CollectibleDetailLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    static let theme = CollectibleDetailLoadingViewTheme()

    private lazy var image = ShimmerView()
    private lazy var title = ShimmerView()
    private lazy var subtitle = ShimmerView()
    private lazy var amount = ShimmerView()

    private lazy var actionView = ShimmerView()

    private lazy var descriptionTitle = ShimmerView()
    private lazy var descriptionValueFirstLine = ShimmerView()
    private lazy var descriptionValueSecondLine = ShimmerView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        linkInteractors()
        build(Self.theme)
    }

    private func build(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        addTitle(theme)
        addSubtitle(theme)
        addAmount(theme)
        addImage(theme)
        addAction(theme)
        addDescriptionTitle(theme)
        addDescriptionValueFirstLine(theme)
        addDescriptionValueSecondLine(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }

    class func calculatePreferredSize(
        for theme: CollectibleDetailLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width

        let title =
        theme.titlePaddings.top +
        theme.titleViewHeight

        let subtitle =
        theme.subtitleTopPadding +
        theme.subtitleViewHeight

        let amount =
        theme.amountTopPadding +
        theme.amountViewHeight

        let imageHeight =
        width -
        theme.imagePaddings.leading -
        theme.imagePaddings.trailing

        let image = theme.imagePaddings.top + imageHeight

        let action =
        theme.actionTopPadding +
        theme.actionHeight

        let description =
        theme.spacingBetweenDescriptionAndAction +
        theme.descriptionHeight +
        theme.descriptionValueFirstLineTopMargin +
        theme.descriptionValueLineHeight +
        theme.descriptionValueLineSpacing +
        theme.descriptionValueLineHeight

        let preferredHeight =
        title +
        subtitle +
        amount +
        image +
        action +
        description

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleDetailLoadingView {

    private func addTitle(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        title.draw(corner: theme.corner)

        addSubview(title)
        title.snp.makeConstraints {
            $0.top == theme.titlePaddings.top
            $0.leading == theme.titlePaddings.trailing
            $0.width == self * theme.titleWidthMultiplier
            $0.fitToHeight(theme.titleViewHeight)
        }
    }

    private func addSubtitle(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        subtitle.draw(corner: theme.corner)

        addSubview(subtitle)
        subtitle.snp.makeConstraints {
            $0.top == title.snp.bottom + theme.subtitleTopPadding
            $0.leading == title
            $0.width == self * theme.subtitleWidthMultiplier
            $0.fitToHeight(theme.subtitleViewHeight)
        }
    }

    private func addAmount(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        amount.draw(corner: theme.corner)

        addSubview(amount)
        amount.snp.makeConstraints {
            $0.top == subtitle.snp.bottom + theme.amountTopPadding
            $0.leading == title
            $0.width == self * theme.amountWidthMultiplier
            $0.fitToHeight(theme.amountViewHeight)
        }
    }

    private func addImage(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        image.draw(corner: theme.imageCorner)

        addSubview(image)
        image.snp.makeConstraints {
            $0.height == image.snp.width

            $0.top == amount.snp.bottom + theme.imagePaddings.top
            $0.leading == theme.imagePaddings.leading
            $0.trailing == theme.imagePaddings.trailing
        }
    }

    private func addAction(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        actionView.draw(corner: theme.corner)

        addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.top == image.snp.bottom + theme.actionTopPadding
            $0.leading == image
            $0.trailing == image
            $0.fitToHeight(theme.actionHeight)
        }
    }

    private func addDescriptionTitle(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        descriptionTitle.draw(corner: theme.corner)

        addSubview(descriptionTitle)
        descriptionTitle.snp.makeConstraints {
            $0.top == actionView.snp.bottom + theme.spacingBetweenDescriptionAndAction
            $0.leading == image
            $0.fitToHeight(theme.descriptionHeight)
            $0.width == self * theme.descriptionWidthMultiplier
        }
    }

    private func addDescriptionValueFirstLine(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        descriptionValueFirstLine.draw(corner: theme.corner)

        addSubview(descriptionValueFirstLine)
        descriptionValueFirstLine.snp.makeConstraints {
            $0.top == descriptionTitle.snp.bottom + theme.descriptionValueFirstLineTopMargin
            $0.leading == image
            $0.fitToHeight(theme.descriptionValueLineHeight)
            $0.width == self * theme.descriptionValueFirstLineWidthMultiplier
        }
    }

    private func addDescriptionValueSecondLine(
        _ theme: CollectibleDetailLoadingViewTheme
    ) {
        descriptionValueSecondLine.draw(corner: theme.corner)

        addSubview(descriptionValueSecondLine)
        descriptionValueSecondLine.snp.makeConstraints {
            $0.top == descriptionValueFirstLine.snp.bottom + theme.descriptionValueLineSpacing
            $0.leading == image
            $0.fitToHeight(theme.descriptionValueLineHeight)
            $0.width == self * theme.descriptionValueSecondLineWidthMultiplier
            $0.bottom == 0
        }
    }
}
