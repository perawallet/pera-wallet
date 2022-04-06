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
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: UIControlInteraction()
    ]

    private lazy var titleView = Label()
    private lazy var valueButton = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))

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

    func bindData(
        _ viewModel: CollectibleTransactionInfoViewModel?
    ) {
        titleView.editText = viewModel?.title

        if let icon = viewModel?.icon {
            valueButton.setImage(icon, for: .normal)
        } else {
            valueButton.setImage(nil, for: .normal)
        }

        if let valueStyle = viewModel?.valueStyle {
            valueButton.customizeAppearance(valueStyle)
        }

        valueButton.setEditTitle(viewModel?.value, for: .normal)
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
        let valueMaxWidth =
            width *
            theme.valueWidthRatio
        let titleWidth =
            width -
            valueMaxWidth -
            theme.iconSize.w -
            theme.buttonPadding * 2
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
        addValue(theme)
        addTitle(theme)
        addSeparator(theme.separator)
    }


    private func addValue(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        valueButton.customizeAppearance(theme.value)
        valueButton.imageView?.contentMode = .scaleAspectFit

        addSubview(valueButton)
        valueButton.snp.makeConstraints {
            $0.trailing == 0
            $0.top == theme.verticalPadding
            $0.bottom == theme.verticalPadding
            $0.width <= self * theme.valueWidthRatio
        }

        valueButton.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        valueButton.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        startPublishing(
            event: .performAction,
            for: valueButton
        )
    }

    private func addTitle(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading == 0
            $0.top == theme.verticalPadding
            $0.bottom == theme.verticalPadding
            $0.trailing <= valueButton.snp.leading - theme.buttonPadding
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
