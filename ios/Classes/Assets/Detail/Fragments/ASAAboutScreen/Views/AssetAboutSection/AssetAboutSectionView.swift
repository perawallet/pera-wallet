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

//   AssetAboutSectionView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AssetAboutSectionView:
    View,
    ViewModelBindable {
    private lazy var titleView = Label()
    private lazy var itemsContextView = MacaroonUIKit.VStackView()

    func customize(
        _ theme: AssetAboutSectionViewTheme
    ) {
        addTitle(theme)
        addItemsContext(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AssetAboutSectionViewModel?
    ) {
        viewModel?.title?.load(in: titleView)

        itemsContextView.deleteAllArrangedSubviews()
        viewModel?.items.forEach(addItem)
    }
}

extension AssetAboutSectionView {
    private func addTitle(
        _ theme: AssetAboutSectionViewTheme
    ) {
        addSubview(titleView)

        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.titleEdgeInsets.top
            $0.leading == theme.titleEdgeInsets.leading
            $0.trailing == theme.titleEdgeInsets.trailing
        }
    }

    private func addItemsContext(
        _ theme: AssetAboutSectionViewTheme
    ) {
        addSubview(itemsContextView)
        itemsContextView.spacing = theme.itemSpacing

        itemsContextView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndItems
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }
    }
}

extension AssetAboutSectionView {
    private func addItem(
        _ item: AssetAboutSectionItem
    ) {
        let itemView = createItemView(
            item
        )

        if let didTapAccessoryHandler = item.handlers?.didTapAccessory {
            itemView.startObserving(
                event: .didTapAccessory,
                using: didTapAccessoryHandler
            )
        }

        if let didLongPressAccessoryHandler = item.handlers?.didLongPressAccessory {
            itemView.startObserving(
                event: .didLongPressAccessory,
                using: didLongPressAccessoryHandler
            )
        }

        itemsContextView.addArrangedSubview(itemView)
    }

    private func createItemView(
        _ item: AssetAboutSectionItem
    ) -> SecondaryListItemView {
        let itemView = SecondaryListItemView()
        itemView.customize(item.theme)

        itemView.bindData(item.viewModel)

        return itemView
    }
}
