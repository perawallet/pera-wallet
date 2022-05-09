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

//   CollectibleListLoadingView.swift

import UIKit
import MacaroonUIKit

final class CollectibleListLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var searchInput = ShimmerView()
    private lazy var infoView = ShimmerView()
    private lazy var filterActionView = ShimmerView()
    private lazy var collectibleListItemsVerticalStack = UIStackView()

    private static let rowCount = 2
    private static let columnCount = 2

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        addSearchInput(theme)
        addInfo(theme)
        addFilterAction(theme)
        addCollectibleListItemsVerticalStack(theme)
        addCollectibleListItem(theme)
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
        for theme: CollectibleListLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let rowCount = CollectibleListLoadingView.rowCount
        let columnCount = CollectibleListLoadingView.columnCount


        let rowSpacing = theme.collectibleListItemsHorizontalStackSpacing
        let itemWidth = (size.width - rowSpacing)  / columnCount.cgFloat

        let itemHeight =  CollectibleListItemLoadingView.calculatePreferredSize(
            for: theme.collectibleListItemLoadingViewTheme,
            fittingIn: CGSize((itemWidth.float(), size.height))
        )

        let collectibleListItemsVerticalStackItemsHeight = itemHeight.height * rowCount.cgFloat

        let preferredHeight =
        theme.searchInputHeight +
        theme.searchInputPaddings.top +
        theme.infoTopPadding +
        theme.infoSize.h +
        theme.collectibleListItemsVerticalStackPaddings.top +
        theme.collectibleListItemsVerticalStackSpacing +
        collectibleListItemsVerticalStackItemsHeight +
        theme.collectibleListItemsVerticalStackPaddings.bottom

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleListLoadingView {
    private func addSearchInput(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        searchInput.draw(corner: theme.corner)

        addSubview(searchInput)
        searchInput.snp.makeConstraints {
            $0.setPaddings(theme.searchInputPaddings)
            $0.fitToHeight(theme.searchInputHeight)
        }
    }

    private func addInfo(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        infoView.draw(corner: theme.corner)

        addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.top == searchInput.snp.bottom + theme.infoTopPadding
            $0.leading == 0
            $0.fitToSize(theme.infoSize)
        }
    }

    private func addFilterAction(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        filterActionView.draw(corner: theme.corner)

        addSubview(filterActionView)
        filterActionView.snp.makeConstraints {
            $0.top == infoView.snp.top
            $0.trailing == 0
            $0.width == infoView.snp.width * theme.filterActionWidthRatio
            $0.height == infoView.snp.height
        }
    }

    private func addCollectibleListItemsVerticalStack(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        collectibleListItemsVerticalStack.axis = .vertical
        collectibleListItemsVerticalStack.spacing = theme.collectibleListItemsVerticalStackSpacing
        collectibleListItemsVerticalStack.distribution = .equalSpacing

        addSubview(collectibleListItemsVerticalStack)

        collectibleListItemsVerticalStack.snp.makeConstraints {
            $0.top == filterActionView.snp.bottom + theme.collectibleListItemsVerticalStackPaddings.top
            $0.leading == theme.collectibleListItemsVerticalStackPaddings.leading
            $0.trailing == theme.collectibleListItemsVerticalStackPaddings.trailing
            $0.bottom == theme.collectibleListItemsVerticalStackPaddings.bottom
        }
    }

    private func addCollectibleListItem(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        let rowCount = CollectibleListLoadingView.rowCount
        let columnCount = CollectibleListLoadingView.columnCount

        (0..<rowCount).forEach { _ in
            let collectibleListItemsHorizontalStack = UIStackView()
            collectibleListItemsHorizontalStack.spacing = theme.collectibleListItemsHorizontalStackSpacing
            collectibleListItemsHorizontalStack.distribution = .fillEqually

            (0..<columnCount).forEach { _ in
                let collectibleListItem = CollectibleListItemLoadingView()
                collectibleListItem.customize(theme.collectibleListItemLoadingViewTheme)
                collectibleListItemsHorizontalStack.addArrangedSubview(collectibleListItem)
            }

            collectibleListItemsVerticalStack.addArrangedSubview(collectibleListItemsHorizontalStack)
        }
    }
}
