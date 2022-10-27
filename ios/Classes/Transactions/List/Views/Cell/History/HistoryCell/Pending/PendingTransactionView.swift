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
//  PendingTransactionView.swift

import UIKit
import MacaroonUIKit

final class PendingTransactionView: TransactionHistoryContextView {
    private(set) lazy var indicatorView = ViewLoadingIndicator()

    func customize(_ theme: PendingTransactionViewTheme) {
        super.customize(theme.transactionHistoryContextViewTheme)
        adjustContent(theme)
        addIndicatorView(theme)
    }
}

extension PendingTransactionView {
    private func adjustContent(_ theme: PendingTransactionViewTheme) {
        contentView.snp.updateConstraints {
            $0.leading.equalToSuperview().inset(theme.transactionHistoryContextLeadingPadding)
        }
    }
    
    private func addIndicatorView(_ theme: PendingTransactionViewTheme) {
        indicatorView.applyStyle(theme.indicator)

        addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.fitToSize(theme.indicatorSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.indicatorLeadingPadding)
        }
    }
}

extension PendingTransactionView {
    func startAnimatingIndicator() {
        indicatorView.startAnimating()
    }

    func stopAnimatingIndicator() {
        indicatorView.stopAnimating()
    }
}
