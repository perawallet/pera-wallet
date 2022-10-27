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

//
//  TransactionHistoryContextView.swift

import UIKit
import MacaroonUIKit

class TransactionHistoryContextView:
    View,
    ViewModelBindable {
    private(set) lazy var contentView = UIView()
    private lazy var titleLabel = Label()
    private lazy var subtitleLabel = Label()
    private lazy var transactionAmountView = TransactionAmountView()

    func customize(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        addContent(theme)
        addTransactionAmountView(theme)
    }

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: ViewStyle
    ) {}
}

extension TransactionHistoryContextView {
    private func addContent(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width >= (self - theme.minSpacingBetweenTitleAndAmount) * theme.titleMinWidthRatio
            $0.top == theme.verticalInset
            $0.leading == theme.horizontalInset
            $0.bottom == theme.verticalInset
        }

        addTitleLabel(theme)
        addSubtitleLabel(theme)
    }

    private func addTitleLabel(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        titleLabel.customizeAppearance(theme.titleLabel)

        titleLabel.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY
                .equalToSuperview()
                .priority(.low)
            $0.top == 0
            $0.leading == 0
            $0.trailing <= 0
        }
    }
    
    private func addSubtitleLabel(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        subtitleLabel.customizeAppearance(theme.subtitleLabel)

        subtitleLabel.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )

        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addTransactionAmountView(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        transactionAmountView.customize(theme.amount)

        addSubview(transactionAmountView)
        transactionAmountView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        transactionAmountView.snp.makeConstraints {
            $0.centerY == 0
            $0.top == theme.verticalInset
            $0.leading == contentView.snp.trailing + theme.minSpacingBetweenTitleAndAmount
            $0.bottom == theme.verticalInset
            $0.trailing == theme.horizontalInset
        }
    }
}

extension TransactionHistoryContextView {
    func bindData(
        _ viewModel: TransactionListItemViewModel?
    ) {
        titleLabel.editText = viewModel?.title
        subtitleLabel.editText = viewModel?.subtitle

        if let transactionAmountViewModel = viewModel?.transactionAmountViewModel {
            transactionAmountView.bindData(transactionAmountViewModel)
        }
    }

    class func calculatePreferredSize(
        _ viewModel: TransactionListItemViewModel?,
        for theme: TransactionHistoryContextViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let amountSize = viewModel.transactionAmountViewModel?.amountLabelText.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let contentHeight = titleSize.height + subtitleSize.height
        let accessoryTextHeight = (amountSize?.height ?? 0)
        let preferredHeight = max(contentHeight, accessoryTextHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        transactionAmountView.prepareForReuse()
    }
}
