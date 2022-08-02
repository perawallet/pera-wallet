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
//  TransactionStatusInformationView.swift

import UIKit
import MacaroonUIKit

final class TransactionStatusInformationView: View {
    private lazy var titleLabel = UILabel()
    private lazy var transactionStatusView = TransactionStatusView()

    func customize(_ theme: TransactionStatusInformationViewTheme) {
        addTitleLabel(theme)
        addTransactionStatusView(theme)
    }

    func customizeAppearance(_ styleSheet: ViewStyle) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension TransactionStatusInformationView {
    private func addTitleLabel(_ theme: TransactionStatusInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.bottom <= theme.contentPaddings.bottom
        }
    }
    
    private func addTransactionStatusView(_ theme: TransactionStatusInformationViewTheme) {
        transactionStatusView.customize(theme.transactionStatusViewTheme)

        addSubview(transactionStatusView)
        transactionStatusView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading + theme.statusLeadingPadding
            $0.bottom == theme.contentPaddings.bottom
            $0.trailing <= theme.contentPaddings.trailing
        }

        titleLabel.snp.makeConstraints {
            $0.trailing == transactionStatusView.snp.leading - theme.minimumSpacingBetweenTitleAndStatus
        }
    }
}

extension TransactionStatusInformationView: ViewModelBindable {
    func bindData(_ viewModel: TransactionStatusInformationViewModel?) {
        if let title = viewModel?.title {
            titleLabel.text = title
        }

        if let transactionStatusViewModel = viewModel?.transactionStatusViewModel {
            transactionStatusView.bindData(transactionStatusViewModel)
        }
    }
}
