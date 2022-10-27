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
//  TransactionAmountView.swift

import UIKit
import MacaroonUIKit

/// <todo> Use formatter instead of `signLabel`.
final class TransactionAmountView: View {
    private var theme: TransactionAmountViewTheme?

    private lazy var signLabel = Label()
    private lazy var amountLabel = Label()

    func customize(_ theme: TransactionAmountViewTheme) {
        self.theme = theme

        addSignLabel(theme)
        addAmountLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    class func calculatePreferredSize(
        _ viewModel: TransactionAmountViewModel?,
        for theme: TransactionAmountViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.amountLabelText.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )

        let preferredHeight = titleSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension TransactionAmountView {
    private func addSignLabel(
        _ theme: TransactionAmountViewTheme
    ) {
        signLabel.customizeAppearance(theme.signLabel)

        addSubview(signLabel)
        signLabel.fitToHorizontalIntrinsicSize()
        signLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
    }

    private func addAmountLabel(
        _ theme: TransactionAmountViewTheme
    ) {
        amountLabel.customizeAppearance(theme.amountLabel)

        addSubview(amountLabel)
        amountLabel.snp.makeConstraints {
            $0.leading.equalTo(signLabel.snp.trailing)
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
}

extension TransactionAmountView: ViewModelBindable {
    func bindData(_ viewModel: TransactionAmountViewModel?) {
        signLabel.editText = viewModel?.signLabelText
        signLabel.textColor = viewModel?.signLabelColor?.uiColor
        amountLabel.editText = viewModel?.amountLabelText
        amountLabel.textColor = viewModel?.amountLabelColor?.uiColor
    }

    func prepareForReuse() {
        signLabel.text = nil
        signLabel.font = theme?.signLabel.font?.uiFont

        amountLabel.text = nil
        amountLabel.font = theme?.amountLabel.font?.uiFont
    }
}

extension TransactionAmountView {
    enum Mode: Hashable {
        case normal(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil, assetSymbol: String? = nil, currency: String? = nil)
        case positive(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil, assetSymbol: String? = nil, currencyValue: String? = nil)
        case negative(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil, assetSymbol: String? = nil, currency: String? = nil)
    }
}
