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
//   TransactionMultipleAmountInformationView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class TransactionMultipleAmountInformationView: View {
    private lazy var titleLabel = UILabel()
    private lazy var transactionAmountView = VerticalTransactionAmountView()

    func customize(_ theme: TransactionMultipleAmountInformationViewTheme) {
        addTitleLabel(theme)
        addTransactionAmountView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionMultipleAmountInformationView {
    private func addTitleLabel(_ theme: TransactionMultipleAmountInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom <= 0
        }
    }

    private func addTransactionAmountView(_ theme: TransactionMultipleAmountInformationViewTheme) {
        transactionAmountView.customize(theme.verticalTransactionAmountViewTheme)

        addSubview(transactionAmountView)
        transactionAmountView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.amountLeadingPadding)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.trailing == transactionAmountView.snp.leading - theme.minimumSpacingBetweenTitleAndAmount
        }
    }
}

extension TransactionMultipleAmountInformationView: ViewModelBindable {
    func bindData(_ viewModel: TransactionCurrencyAmountInformationViewModel?) {
        if let title = viewModel?.title {
            titleLabel.text = title
        }

        if let transactionViewModel = viewModel?.transactionViewModel {
            transactionAmountView.bindData(transactionViewModel)
        }
    }
}
