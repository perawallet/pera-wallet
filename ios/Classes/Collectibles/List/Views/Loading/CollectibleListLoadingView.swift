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
    private lazy var collectibleListItemsVerticalStack = UIStackView()

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
            $0.bottom <= 0
        }
    }

    private func addCollectibleListItem(
        _ theme: CollectibleListLoadingViewTheme
    ) {
        let rowCount = 2
        let columnCount = 2

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
