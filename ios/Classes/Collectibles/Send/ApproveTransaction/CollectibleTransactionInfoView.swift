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

//   CollectibleTransactionInfoView.swift

import MacaroonUIKit
import UIKit

final class CollectibleTransactionInfoView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: GestureInteraction()
    ]

    private lazy var titleView = Label()
    private lazy var valueContent = MacaroonUIKit.BaseView()
    private lazy var iconView = ImageView()
    private lazy var valueView = UILabel()

    func customize(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        addContext(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareForReuse() {
        titleView.editText = nil
        iconView.image = nil
        valueView.editText = nil
    }

    func bindData(
        _ viewModel: CollectibleTransactionInfoViewModel?
    ) {
        titleView.editText = viewModel?.title

        iconView.load(from: viewModel?.icon)

        if let valueStyle = viewModel?.valueStyle {
            valueView.customizeAppearance(valueStyle)
        }

        valueView.editText = viewModel?.value
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleTransactionInfoViewModel?,
        for theme: CollectibleTransactionInfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width

        var valueMaxWidth =
        width *
        theme.valueWidthRatio

        if viewModel.icon != nil {
            valueMaxWidth -= (theme.iconSize.w + theme.iconContentEdgeInsets.x)
        }

        let titleWidth =
        width -
        valueMaxWidth -
        theme.titleContentEdgeInsets.trailing

        let titleSize = viewModel.title.boundingSize(
            multiline: true,
            fittingSize: CGSize((titleWidth, .greatestFiniteMagnitude))
        )
        let valueSize = viewModel.value.boundingSize(
            multiline: true,
            fittingSize: CGSize((valueMaxWidth , .greatestFiniteMagnitude))
        )

        let verticalSpacing = theme.verticalPadding * 2
        let contentHeight =
        max(titleSize.height, valueSize.height) +
        verticalSpacing

        return CGSize((size.width, min(contentHeight.ceil(), size.height)))
    }
}

extension CollectibleTransactionInfoView {
    private func addContext(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        addValueContent(theme)
        addTitle(theme)
        addSeparator(theme.separator)
    }

    private func addValueContent(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        addSubview(valueContent)
        valueContent.snp.makeConstraints {
            $0.trailing == 0
            $0.top == theme.verticalPadding
            $0.bottom <= theme.verticalPadding
            $0.width == self * theme.valueWidthRatio
        }

        addValue(theme)
        addIcon(theme)
    }

    private func addValue(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        valueView.customizeAppearance(theme.value)

        valueContent.addSubview(valueView)
        valueView.snp.makeConstraints {
            $0.trailing == 0
            $0.top == 0
            $0.bottom == 0
        }

        valueView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        valueView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .defaultHigh
        )

        startPublishing(
            event: .performAction,
            for: valueView
        )
    }

    private func addIcon(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)
        iconView.layer.draw(corner: theme.iconCorner)
        iconView.clipsToBounds = true

        valueContent.addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == valueView
            $0.trailing == valueView.snp.leading
            $0.leading >= 0
        }
    }

    private func addTitle(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.contentEdgeInsets = theme.titleContentEdgeInsets
        titleView.snp.makeConstraints {
            $0.leading == 0
            $0.top == theme.verticalPadding
            $0.bottom <= theme.verticalPadding
            $0.trailing <= valueContent.snp.leading
        }

        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultHigh,
            compression: .required
        )

        titleView.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultHigh
        )
    }
}

extension CollectibleTransactionInfoView {
    enum Event {
        case performAction
    }
}
