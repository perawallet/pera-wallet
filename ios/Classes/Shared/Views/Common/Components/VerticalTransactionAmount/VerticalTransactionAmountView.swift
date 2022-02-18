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
//   VerticalTransactionAmountView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class VerticalTransactionAmountView: View {
    private lazy var amountStackView = UIStackView()
    private lazy var amountLabel = Label()
    private lazy var usdLabel = Label()

    func customize(_ theme: VerticalTransactionAmountViewTheme) {
        addAmountStackView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension VerticalTransactionAmountView {
    private func addAmountStackView(_ theme: VerticalTransactionAmountViewTheme) {
        addSubview(amountStackView)
        amountStackView.distribution = .equalSpacing
        amountStackView.alignment = .leading
        amountStackView.axis = .vertical

        amountStackView.fitToIntrinsicSize()
        amountLabel.fitToIntrinsicSize()
        usdLabel.fitToIntrinsicSize()

        amountStackView.pinToSuperview()

        amountLabel.customizeAppearance(theme.amountLabel)
        amountStackView.addArrangedSubview(amountLabel)

        usdLabel.customizeAppearance(theme.usdLabel)
        amountStackView.addArrangedSubview(usdLabel)
    }
}

extension VerticalTransactionAmountView: ViewModelBindable {
    func bindData(_ viewModel: TransactionCurrencyAmountViewModel?) {
        usdLabel.editText = viewModel?.currencyLabelText
        amountLabel.editText = viewModel?.amountLabelText
    }

    func prepareForReuse() {
        usdLabel.text = nil
        amountLabel.text = nil
    }
}
