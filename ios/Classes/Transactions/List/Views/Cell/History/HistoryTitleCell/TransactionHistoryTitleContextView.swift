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
//   TransactionHistoryTitleContextView.swift

import MacaroonUIKit
import UIKit

final class TransactionHistoryTitleContextView: View {
    private lazy var leadingLine = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var trailingLine = UIView()

    func customize(_ theme: TransactionHistoryTitleContextViewTheme) {
        addTitleLabel(theme)
        addLines(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionHistoryTitleContextView {
    private func addTitleLabel(_ theme: TransactionHistoryTitleContextViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.paddings.top)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(theme.paddings.bottom)
        }
    }

    private func addLines(_ theme: TransactionHistoryTitleContextViewTheme) {
        leadingLine.customizeAppearance(theme.lineStyle)
        trailingLine.customizeAppearance(theme.lineStyle)

        addSubview(leadingLine)
        leadingLine.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalToSuperview().inset(theme.paddings.leading)
            $0.trailing.equalTo(titleLabel.snp.leading).offset(-theme.linePaddings.leading)
            $0.height.equalTo(theme.lineHeight)
        }

        addSubview(trailingLine)
        trailingLine.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(theme.paddings.trailing)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(theme.linePaddings.trailing)
            $0.height.equalTo(theme.lineHeight)
        }
    }
}

extension TransactionHistoryTitleContextView: ViewModelBindable {
    func bindData(_ viewModel: TransactionHistoryTitleContextViewModel?) {
        titleLabel.text = viewModel?.title
    }
}
