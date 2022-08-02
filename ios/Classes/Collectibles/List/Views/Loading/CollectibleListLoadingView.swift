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
    private lazy var managementItemView = ManagementItemView()
    private lazy var searchInput = SearchInputView()
    private lazy var collectibleListItemsVerticalStack = UIStackView()

    private static let managementItemViewModel = ManagementItemViewModel(
        .collectible(
            count: .zero,
            isWatchAccountDisplay: false
        )
    )

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
        addManagementItem(theme)
        addSearchInput(theme)
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
        let width = size.width

        let managementItemSize = ManagementItemView.calculatePreferredSize(
            CollectibleListLoadingView.managementItemViewModel,
            for: theme.managementItemTheme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        let rowCount = CollectibleListLoadingView.rowCount
        let columnCount = CollectibleListLoadingView.columnCount

        let rowSpacing = theme.collectibleListItemsHorizontalStackSpacing
        let itemWidth = (width - rowSpacing) / columnCount.cgFloat

        let itemHeight =  CollectibleListItemLoadingView.calculatePreferredSize(
            for: theme.collectibleListItemLoadingViewTheme,
            fittingIn: CGSize((itemWidth.float(), size.height))
        )

        let collectibleListItemsVerticalStackItemsHeight = itemHeight.height * rowCount.cgFloat

        let preferredHeight =
        theme.managementItemTopPadding +
        managementItemSize.height +
        theme.searchInputHeight +
        theme.searchInputPaddings.top +
        theme.collectibleListItemsVerticalStackPaddings.top +
        theme.collectibleListItemsVerticalStackSpacing +
        collectibleListItemsVerticalStackItemsHeight +
        theme.collectibleListItemsVerticalStackPaddings.bottom

        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleListLoadingView {
    private func addManagementItem(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        managementItemView.customize(theme.managementItemTheme)
        managementItemView.bindData(CollectibleListLoadingView.managementItemViewModel)

        addSubview(managementItemView)
        managementItemView.snp.makeConstraints {
            $0.top == theme.managementItemTopPadding
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSearchInput(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        searchInput.customize(theme.searchInputTheme)

        addSubview(searchInput)
        searchInput.snp.makeConstraints {
            $0.top == managementItemView.snp.bottom + theme.searchInputPaddings.top
            $0.leading == theme.searchInputPaddings.leading
            $0.trailing == theme.searchInputPaddings.trailing

            $0.fitToHeight(theme.searchInputHeight)
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
            $0.top == searchInput.snp.bottom + theme.collectibleListItemsVerticalStackPaddings.top
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
