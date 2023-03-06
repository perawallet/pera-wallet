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

final class SendTransactionPreviewView:
    View,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performEditNote: UIBlockInteraction()
    ]
    private lazy var theme = SendTransactionPreviewViewTheme()

    private lazy var verticalStackView = UIStackView()
    private(set) lazy var amountView = TransactionMultipleAmountInformationView()
    private(set) lazy var userView = TitledTransactionAccountNameView()
    private(set) lazy var opponentView = TitledTransactionAccountNameView()
    private(set) lazy var feeView = TransactionAmountInformationView()
    private(set) lazy var balanceView = TransactionMultipleAmountInformationView()
    private(set) lazy var noteView = TransactionActionInformationView()
    private(set) lazy var lockedNoteView = TransactionTextInformationView()

    init() {
        super.init(frame: .zero)

        customize(theme)
        setListeners()
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
        addLockedNoteView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
    
    func setListeners() {
        noteView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }
            
            let interaction = self.uiInteractions[.performEditNote]
            interaction?.publish()
        }
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
            $0.bottom.equalToSuperview()
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
        verticalStackView.setCustomSpacing(
            theme.bottomPaddingForSeparator,
            after: amountView
        )
        amountView.addSeparator(
            theme.separator,
            padding: theme.separatorTopPadding
        )
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
        feeView.addSeparator(
            theme.separator,
            padding: theme.separatorTopPadding
        )
        verticalStackView.setCustomSpacing(
            theme.bottomPaddingForSeparator,
            after: feeView
        )
    }

    private func addBalanceView(_ theme: SendTransactionPreviewViewTheme) {
        balanceView.customize(theme.smallMultipleAmountInformationViewTheme)
        balanceView.bindData(
            TransactionCurrencyAmountInformationViewModel(
                title: "send-transaction-preview-current-balance".localized
            )
        )

        verticalStackView.addArrangedSubview(balanceView)
        balanceView.addSeparator(
            theme.separator,
            padding: theme.separatorTopPadding
        )
        verticalStackView.setCustomSpacing(
            theme.bottomPaddingForSeparator,
            after: balanceView
        )
    }

    private func addNoteView(_ theme: SendTransactionPreviewViewTheme) {
        noteView.customize(theme.transactionActionInformationViewTheme)
        noteView.bindData(TransactionActionInformationViewModel())

        verticalStackView.addArrangedSubview(noteView)
    }
    
    private func addLockedNoteView(_ theme: SendTransactionPreviewViewTheme) {
        lockedNoteView.customize(theme.transactionTextInformationViewTheme)
        lockedNoteView.bindData(
            TransactionTextInformationViewModel(
                title: "transaction-detail-note".localized
            )
        )
        
        verticalStackView.addArrangedSubview(lockedNoteView)
    }
}

extension SendTransactionPreviewView {
    func bindData(
        _ viewModel: SendTransactionPreviewViewModel?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if let amountViewMode = viewModel?.amountViewMode {
            amountView.bindData(
                TransactionCurrencyAmountInformationViewModel(
                    transactionViewModel: TransactionCurrencyAmountViewModel(
                        amountViewMode,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
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
                    transactionViewModel: TransactionAmountViewModel(
                        feeViewMode,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                )
            )
        }

        if let balanceViewMode = viewModel?.balanceViewMode {
            balanceView.bindData(
                TransactionCurrencyAmountInformationViewModel(
                    transactionViewModel: TransactionCurrencyAmountViewModel(
                        balanceViewMode,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                )
            )
        }

        if let lockedNote = viewModel?.lockedNoteView {
            lockedNoteView.bindData(lockedNote)
            lockedNoteView.isHidden = false
            noteView.isHidden = true
        } else {
            noteView.bindData(viewModel?.noteView)
            noteView.isHidden = false
            lockedNoteView.isHidden = true
        }
    }
}

extension SendTransactionPreviewView {
    enum Event {
        case performEditNote
    }
}
