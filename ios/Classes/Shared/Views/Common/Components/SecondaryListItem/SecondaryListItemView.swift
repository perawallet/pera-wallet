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

//   SecondaryListItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SecondaryListItemView:
    MacaroonUIKit.View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didTapAccessory: GestureInteraction(gesture: .tap),
        .didLongPressAccessory: GestureInteraction(gesture: .longPress)
    ]

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var titleView = UILabel()
    private lazy var accessoryView = SecondaryListItemValueView()

    private var theme: SecondaryListItemViewTheme?

    func customize(
        _ theme: SecondaryListItemViewTheme
    ) {
        self.theme = theme

        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SecondaryListItemViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        accessoryView.bindData(viewModel?.accessory)
    }
}

extension SecondaryListItemView {
    private func addContent(
        _ theme: SecondaryListItemViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.setPaddings(theme.contentEdgeInsets)
        }

        addTitle(theme)
        addAccessory(theme)
    }

    private func addTitle(
        _ theme: SecondaryListItemViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToHorizontalIntrinsicSize(
            hugging: .defaultHigh,
            compression: .defaultHigh
        )
        titleView.snp.makeConstraints {
            $0.width >= contentView.snp.width * theme.titleMinWidthRatio
            $0.width <= contentView.snp.width * theme.titleMaxWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAccessory(
        _ theme: SecondaryListItemViewTheme
    ) {
        accessoryView.customize(theme.accessory)

        contentView.addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.leading >= titleView.snp.trailing + theme.minimumSpacingBetweenTitleAndAccessory
            $0.bottom <= 0
            $0.trailing == 0
        }

        startPublishing(
            event: .didTapAccessory,
            for: accessoryView
        )
        startPublishing(
            event: .didLongPressAccessory,
            for: accessoryView
        )
    }
}

extension SecondaryListItemView {
    enum Event {
        case didTapAccessory
        case didLongPressAccessory
    }
}
