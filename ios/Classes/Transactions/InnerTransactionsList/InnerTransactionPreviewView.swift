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

//   InnerTransactionPreviewView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InnerTransactionPreviewView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = Label()
    private lazy var amountView = TransactionAmountView()

    func customize(
        _ theme: InnerTransactionPreviewViewTheme
    ) {
        addTitle(theme)
        addAmountView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: InnerTransactionPreviewViewModel?
    ) {
        titleView.editText = viewModel?.title
        amountView.bindData(viewModel?.amountViewModel)
    }

    func prepareForReuse() {
        titleView.editText = nil
        amountView.prepareForReuse()
    }

    class func calculatePreferredSize(
        _ viewModel: InnerTransactionPreviewViewModel?,
        for theme: InnerTransactionPreviewViewTheme,
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
        let amountSize = TransactionAmountView.calculatePreferredSize(
            viewModel.amountViewModel,
            for: theme.amountViewTheme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        let preferredHeight = max(titleSize.height, amountSize.height)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension InnerTransactionPreviewView {
    private func addTitle(
        _ theme: InnerTransactionPreviewViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)

        titleView.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )
        titleView.contentEdgeInsets.trailing =  theme.minSpacingBetweenTitleAndAmount
        titleView.snp.makeConstraints {
            $0.width >= self * theme.titleMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAmountView(
        _ theme: InnerTransactionPreviewViewTheme
    ) {
        amountView.customize(theme.amountViewTheme)

        addSubview(amountView)

        amountView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        
        amountView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= titleView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
