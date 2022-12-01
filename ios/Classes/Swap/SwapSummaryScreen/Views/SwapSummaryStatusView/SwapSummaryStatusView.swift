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

//   SwapSummaryStatusView.swift

import MacaroonUIKit
import UIKit

final class SwapSummaryStatusView: View, ViewModelBindable {
    private lazy var titleView = UILabel()
    private lazy var statusView = TransactionStatusView()

    func customize(
        _ theme: SwapSummaryStatusViewTheme
    ) {
        addStatus(theme)
        addTitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: TransactionStatusViewModel?
    ) {
        statusView.bindData(viewModel)
    }
}

extension SwapSummaryStatusView {
    private func addStatus(
        _ theme: SwapSummaryStatusViewTheme
    ) {
        statusView.customize(theme.status)

        addSubview(statusView)
        statusView.fitToIntrinsicSize()
        statusView.snp.makeConstraints {
            $0.top == 0
            $0.leading == theme.statusLeadingInset
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addTitle(
        _ theme: SwapSummaryStatusViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.trailing == statusView.snp.leading - theme.minimumSpacingBetweenTitleAndStatus
        }
    }
}
