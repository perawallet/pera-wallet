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
//  TransactionDetailView.swift

import UIKit
import MacaroonUIKit

final class TransactionDetailView:
    View,
    UIContextMenuInteractionDelegate {
    weak var delegate: TransactionDetailViewDelegate?

    private lazy var verticalStackView = UIStackView()
    private lazy var statusView = TransactionStatusInformationView()
    private lazy var amountView = TransactionAmountInformationView()
    private lazy var closeAmountView = TransactionAmountInformationView()
    private lazy var rewardView = TransactionAmountInformationView()
    private(set) lazy var userView = TransactionTextInformationView()
    private lazy var opponentView = TransactionContactInformationView()
    private lazy var closeToView = TransactionTextInformationView()
    private lazy var feeView = TransactionAmountInformationView()
    private lazy var dateView = TransactionTextInformationView()
    private lazy var roundView = TransactionTextInformationView()
    private lazy var idView = TransactionTextInformationView()
    private lazy var noteView = TransactionTextInformationView()
    private lazy var openInPeraExplorerButton = UIButton()

    private lazy var userContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var opponentContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var closeToContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var idContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var noteContextMenuInteraction = UIContextMenuInteraction(delegate: self)

    private let transactionType: TransferType
    
    init(transactionType: TransferType) {
        self.transactionType = transactionType
        super.init(frame: .zero)

        customize(TransactionDetailViewTheme())
        linkInteractors()
    }
    
    func linkInteractors() {
        opponentView.delegate = self
        opponentView.linkInteractors()

        userView.addInteraction(userContextMenuInteraction)
        opponentView.addInteraction(opponentContextMenuInteraction)
        closeToView.addInteraction(closeToContextMenuInteraction)
        idView.addInteraction(idContextMenuInteraction)
        noteView.addInteraction(noteContextMenuInteraction)

        openInPeraExplorerButton.addTarget(self, action: #selector(notifyDelegateToOpenPeraExplorer), for: .touchUpInside)
    }
    
    func customize(_ theme: TransactionDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addVerticalStackView(theme)
        addAmountView(theme)
        addCloseAmountView(theme)
        addRewardView(theme)
        addStatusView(theme)

        if transactionType == .received {
            addOpponentView(theme)
            addUserView(theme)
        } else {
            addUserView(theme)
            addOpponentView(theme)
        }

        addCloseToView(theme)
        addFeeView(theme)
        addDateView(theme)
        addRoundView(theme)
        addIdView(theme)
        addNoteView(theme)
        addOpenInPeraExplorerButton(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionDetailView {
    private func addVerticalStackView(_ theme: TransactionDetailViewTheme) {
        verticalStackView.axis = .vertical
        addSubview(verticalStackView)

        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addAmountView(_ theme: TransactionDetailViewTheme) {
        amountView.customize(theme.transactionAmountInformationViewTheme)
        amountView.bindData(TransactionAmountInformationViewModel(title: "transaction-detail-amount".localized))

        verticalStackView.addArrangedSubview(amountView)
    }
    
    private func addCloseAmountView(_ theme: TransactionDetailViewTheme) {
        closeAmountView.customize(theme.commonTransactionAmountInformationViewTheme)
        closeAmountView.bindData(TransactionAmountInformationViewModel(title: "transaction-detail-close-amount".localized))

        verticalStackView.addArrangedSubview(closeAmountView)
    }

    private func addStatusView(_ theme: TransactionDetailViewTheme) {
        statusView.customize(theme.transactionStatusInformationViewTheme)
        statusView.bindData(TransactionStatusInformationViewModel(title: "transaction-detail-status".localized))

        verticalStackView.addArrangedSubview(statusView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: statusView)
        statusView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addRewardView(_ theme: TransactionDetailViewTheme) {
        rewardView.customize(theme.commonTransactionAmountInformationViewTheme)
        rewardView.bindData(TransactionAmountInformationViewModel(title: "transaction-detail-reward".localized))

        verticalStackView.addArrangedSubview(rewardView)
    }
    
    private func addUserView(_ theme: TransactionDetailViewTheme) {
        userView.customize(theme.transactionUserInformationViewTheme)

        verticalStackView.addArrangedSubview(userView)
    }
    
    private func addOpponentView(_ theme: TransactionDetailViewTheme) {
        opponentView.customize(theme.transactionContactInformationViewTheme)
        opponentView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(opponentView)
    }
    
    private func addCloseToView(_ theme: TransactionDetailViewTheme) {
        closeToView.customize(theme.transactionTextInformationViewCommonTheme)
        closeToView.bindData(TransactionTextInformationViewModel(title: "transaction-detail-close-to".localized))
        closeToView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(closeToView)
    }
    
    private func addFeeView(_ theme: TransactionDetailViewTheme) {
        feeView.customize(theme.commonTransactionAmountInformationViewTheme)
        feeView.bindData(TransactionAmountInformationViewModel(title: "transaction-detail-fee".localized))

        verticalStackView.addArrangedSubview(feeView)
    }
    
    private func addDateView(_ theme: TransactionDetailViewTheme) {
        dateView.customize(theme.transactionTextInformationViewCommonTheme)
        dateView.bindData(TransactionTextInformationViewModel(title: "transaction-detail-date".localized))

        verticalStackView.addArrangedSubview(dateView)
    }
    
    private func addRoundView(_ theme: TransactionDetailViewTheme) {
        roundView.customize(theme.transactionTextInformationViewCommonTheme)
        roundView.bindData(TransactionTextInformationViewModel(title: "transaction-detail-round".localized))

        verticalStackView.addArrangedSubview(roundView)
    }
    
    private func addIdView(_ theme: TransactionDetailViewTheme) {
        idView.customize(theme.transactionTextInformationViewTransactionIDTheme)

        verticalStackView.addArrangedSubview(idView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: idView)
        idView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }
    
    private func addNoteView(_ theme: TransactionDetailViewTheme) {
        noteView.customize(theme.transactionTextInformationViewCommonTheme)
        noteView.bindData(TransactionTextInformationViewModel(title: "transaction-detail-note".localized))
        noteView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(noteView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: noteView)
        noteView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addOpenInPeraExplorerButton(_ theme: TransactionDetailViewTheme) {
        openInPeraExplorerButton.customizeAppearance(theme.openInPeraExplorerButton)
        openInPeraExplorerButton.layer.draw(corner: theme.buttonsCorner)

        addSubview(openInPeraExplorerButton)
        openInPeraExplorerButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        openInPeraExplorerButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(verticalStackView.snp.bottom).offset(theme.spacingBetweenPropertiesAndActions)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension TransactionDetailView: TransactionContactInformationViewDelegate {
    func transactionContactInformationViewDidTapAddContactButton(_ transactionContactInformationView: TransactionContactInformationView) {
        delegate?.transactionDetailViewDidTapAddContactButton(self)
    }
}

extension TransactionDetailView {
    @objc
    func notifyDelegateToOpenPeraExplorer() {
        delegate?.transactionDetailView(self, didOpen: .peraExplorer)
    }
}

extension TransactionDetailView {
    func bindData(
        _ viewModel: TransactionDetailViewModel?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        closeToView.bindData(TransactionTextInformationViewModel(detail: viewModel?.closeToViewDetail))
        closeToView.isHidden = (viewModel?.closeToViewIsHidden).falseIfNil

        if let rewardViewMode = viewModel?.rewardViewMode {
            rewardView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(
                        rewardViewMode,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                )
            )
        }

        rewardView.isHidden = (viewModel?.rewardViewIsHidden).falseIfNil

        if let closeAmountViewMode = viewModel?.closeAmountViewMode {
            closeAmountView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(
                        closeAmountViewMode,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                )
            )
        }

        closeAmountView.isHidden = (viewModel?.closeAmountViewIsHidden).falseIfNil
        noteView.bindData(TransactionTextInformationViewModel(detail: viewModel?.noteViewDetail))
        noteView.isHidden = (viewModel?.noteViewIsHidden).falseIfNil
        roundView.bindData(TransactionTextInformationViewModel(detail: viewModel?.roundViewDetail))
        roundView.isHidden = (viewModel?.roundViewIsHidden).falseIfNil
        dateView.bindData(TransactionTextInformationViewModel(detail: viewModel?.date))
        idView.bindData(
            TransactionTextInformationViewModel(
                title: viewModel?.transactionIDTitle,
                detail: viewModel?.transactionID
            )
        )

        if let status = viewModel?.transactionStatus {
            statusView.bindData(
                TransactionStatusInformationViewModel(
                    transactionStatusViewModel: TransactionStatusViewModel(status)
                )
            )
        }

        if let userViewDetail = viewModel?.userViewDetail {
            userView.bindData(
                TransactionTextInformationViewModel(
                    TitledInformation(title: viewModel?.userViewTitle, detail: userViewDetail)
                )
            )
        } else {
            userView.hideViewInStack()
        }


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

        if let transactionAmountViewMode = viewModel?.transactionAmountViewMode {
            amountView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(
                        transactionAmountViewMode,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                )
            )
        } else {
            amountView.isHidden = true
        }

        if let opponentViewTitle = viewModel?.opponentViewTitle {
            opponentView.bindData(
                TransactionContactInformationViewModel(title: opponentViewTitle)
            )
            bindOpponentViewDetail(viewModel)
        } else {
            opponentView.isHidden = true
        }
    }

    func bindOpponentViewDetail(_ viewModel: TransactionDetailViewModel?) {
        if let contact = viewModel?.opponentViewContact {
            opponentView.bindData(
                TransactionContactInformationViewModel(
                    contactDisplayViewModel: ContactDisplayViewModel(contact: contact)
                )
            )
        } else if let opponentViewAddress = viewModel?.opponentViewAddress {
            opponentView.bindData(
                TransactionContactInformationViewModel(
                    contactDisplayViewModel: ContactDisplayViewModel(address: opponentViewAddress)
                )
            )
        } else if let localAddress = viewModel?.localAddress {
            opponentView.bindData(
                TransactionContactInformationViewModel(
                    contactDisplayViewModel: ContactDisplayViewModel(localAddress: localAddress)
                )
            )
        } else {
            opponentView.hideViewInStack()
            opponentView.removeAccessoryViews()
        }
    }
}

extension TransactionDetailView {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        switch interaction {
        case userContextMenuInteraction:
            return delegate?.contextMenuInteractionForUser(self)
        case opponentContextMenuInteraction:
            return delegate?.contextMenuInteractionForOpponent(self)
        case closeToContextMenuInteraction:
            return delegate?.contextMenuInteractionForCloseTo(self)
        case idContextMenuInteraction:
            return delegate?.contextMenuInteractionForTransactionID(self)
        case noteContextMenuInteraction:
            return delegate?.contextMenuInteractionForTransactionNote(self)
        default:
            return nil
        }
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

protocol TransactionDetailViewDelegate: AnyObject {
    func transactionDetailViewDidTapAddContactButton(
        _ transactionDetailView: TransactionDetailView
    )
    func contextMenuInteractionForUser(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForOpponent(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForCloseTo(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForTransactionID(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForTransactionNote(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration?
    func transactionDetailView(_ transactionDetailView: TransactionDetailView, didOpen explorer: AlgoExplorerType)
}
