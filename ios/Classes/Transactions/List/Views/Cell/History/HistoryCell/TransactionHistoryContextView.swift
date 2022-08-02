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
    private(set) lazy var titleLabel = Label()
    private(set) lazy var subtitleLabel = Label()
    private(set) lazy var transactionAmountView = TransactionAmountView()

    func customize(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        addTitleLabel(theme)
        addSubtitleLabel(theme)
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
    private func addTitleLabel(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)

        titleLabel.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )
        titleLabel.contentEdgeInsets.trailing = theme.minSpacingBetweenTitleAndAmount
        titleLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualToSuperview().multipliedBy(theme.titleMinWidthRatio)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.centerY.equalToSuperview().priority(.low)
        }
    }
    
    private func addSubtitleLabel(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        subtitleLabel.customizeAppearance(theme.subtitleLabel)

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
        }

        subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func addTransactionAmountView(
        _ theme: TransactionHistoryContextViewTheme
    ) {
        transactionAmountView.customize(TransactionAmountViewSmallerTheme())

        transactionAmountView.setContentHuggingPriority(.required, for: .horizontal)
        transactionAmountView.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubview(transactionAmountView)
        transactionAmountView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.centerY.equalToSuperview()
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
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
