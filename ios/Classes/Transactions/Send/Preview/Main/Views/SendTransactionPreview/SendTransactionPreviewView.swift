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
//   SendTransactionPreviewView.swift


import Foundation
import UIKit
import MacaroonUIKit

final class SendTransactionPreviewView: View {
    private lazy var theme = SendTransactionPreviewViewTheme()

    private lazy var verticalStackView = UIStackView()
    private(set) lazy var amountView = TransactionMultipleAmountInformationView()
    private(set) lazy var userView = TitledTransactionAccountNameView()
    private(set) lazy var opponentView = TitledTransactionAccountNameView()
    private(set) lazy var feeView = TransactionAmountInformationView()
    private(set) lazy var balanceView = TransactionMultipleAmountInformationView()
    private(set) lazy var noteView = TransactionTextInformationView()

    init() {
        super.init(frame: .zero)

        customize(theme)
    }

    func customize(_ theme: SendTransactionPreviewViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addVerticalStackView(theme)
        addAmountView(theme)
        addUserView(theme)
        addOpponentView(theme)
        addFeeView(theme)
        addBalanceView(theme)
        addNoteView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}

    func setNoteViewVisible(_ isVisible: Bool) {
        if isVisible {
            balanceView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
            verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: balanceView)
        }
        noteView.isHidden = !isVisible
    }
}

extension SendTransactionPreviewView {
    private func addVerticalStackView(_ theme: SendTransactionPreviewViewTheme) {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = theme.verticalStackViewSpacing
        addSubview(verticalStackView)

        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(
                safeAreaBottom + theme.bottomInset
            )
        }
    }

    private func addAmountView(_ theme: SendTransactionPreviewViewTheme) {
        amountView.customize(theme.bigMultipleAmountInformationViewTheme)
        amountView.bindData(
            TransactionCurrencyAmountInformationViewModel(
                title: "transaction-detail-amount".localized
            )
        )

        verticalStackView.addArrangedSubview(amountView)

    }

    private func addUserView(_ theme: SendTransactionPreviewViewTheme) {
        userView.customize(theme.transactionAccountInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(userView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: amountView)
        amountView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addOpponentView(_ theme: SendTransactionPreviewViewTheme) {
        opponentView.customize(theme.transactionAccountInformationViewCommonTheme)
        verticalStackView.addArrangedSubview(opponentView)
    }

    private func addFeeView(_ theme: SendTransactionPreviewViewTheme) {
        feeView.customize(theme.commonTransactionAmountInformationViewTheme)
        feeView.bindData(
            TransactionAmountInformationViewModel(
                title: "transaction-detail-fee".localized
            )
        )

        verticalStackView.addArrangedSubview(feeView)
        feeView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: feeView)
    }

    private func addBalanceView(_ theme: SendTransactionPreviewViewTheme) {
        balanceView.customize(theme.smallMultipleAmountInformationViewTheme)
        balanceView.bindData(
            TransactionCurrencyAmountInformationViewModel(
                title: "send-transaction-preview-current-balance".localized
            )
        )

        verticalStackView.addArrangedSubview(balanceView)
    }

    private func addNoteView(_ theme: SendTransactionPreviewViewTheme) {
        noteView.customize(theme.transactionTextInformationViewCommonTheme)
        noteView.bindData(
            TransactionTextInformationViewModel(
                title: "transaction-detail-note".localized
            )
        )

        verticalStackView.addArrangedSubview(noteView)
    }
}

extension SendTransactionPreviewView: ViewModelBindable {
    func bindData(_ viewModel: SendTransactionPreviewViewModel?) {
        if let amountViewMode = viewModel?.amountViewMode {
            amountView.bindData(
                TransactionCurrencyAmountInformationViewModel(
                    transactionViewModel: TransactionCurrencyAmountViewModel(amountViewMode)
                )
            )
        }

        userView.bindData(
            viewModel?.userView
        )

        opponentView.bindData(
            viewModel?.opponentView
        )

        if let feeViewMode = viewModel?.feeViewMode {
            feeView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(feeViewMode)
                )
            )
        }

        if let balanceViewMode = viewModel?.balanceViewMode {
            balanceView.bindData(
                TransactionCurrencyAmountInformationViewModel(
                    transactionViewModel: TransactionCurrencyAmountViewModel(balanceViewMode)
                )
            )
        }

        noteView.bindData(
            TransactionTextInformationViewModel(detail: viewModel?.noteViewDetail)
        )

        setNoteViewVisible(!(viewModel?.noteViewDetail.isNilOrEmpty ?? true))
    }
}
