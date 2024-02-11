// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   KeyRegTransactionDetailView.swift

import UIKit
import MacaroonUIKit

final class KeyRegTransactionDetailView:
    View,
    UIContextMenuInteractionDelegate {
    weak var delegate: KeyRegTransactionDetailViewDelegate?

    private lazy var verticalStackView = UIStackView()
    private lazy var statusView = TransactionStatusInformationView()
    private lazy var rewardView = TransactionAmountInformationView()
    private lazy var userView = TransactionTextInformationView()
    private lazy var feeView = TransactionAmountInformationView()
    private lazy var dateView = TransactionTextInformationView()
    private lazy var roundView = TransactionTextInformationView()
    private lazy var idView = TransactionTextInformationView()
    private lazy var voteKeyView = TransactionTextInformationView()
    private lazy var selectionKeyView = TransactionTextInformationView()
    private lazy var stateProofKeyView = TransactionTextInformationView()
    private lazy var voteFirstValidRoundView = TransactionTextInformationView()
    private lazy var voteLastValidRoundView = TransactionTextInformationView()
    private lazy var voteKeyDilutionView = TransactionTextInformationView()
    private lazy var participationStatusView = TransactionTextInformationView()
    private lazy var noteView = TransactionTextInformationView()
    private lazy var openInPeraExplorerButton = UIButton()

    private lazy var userContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var idContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var noteContextMenuInteraction = UIContextMenuInteraction(delegate: self)

    override init(frame: CGRect) {
        super.init(frame: frame)

        userView.addInteraction(userContextMenuInteraction)
        idView.addInteraction(idContextMenuInteraction)
        noteView.addInteraction(noteContextMenuInteraction)

        openInPeraExplorerButton.addTarget(
            self,
            action: #selector(notifyDelegateToOpenPeraExplorer), for: .touchUpInside
        )
    }

    func customize(_ theme: KeyRegTransactionDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
       
        addVerticalStackView(theme)
        addRewardView(theme)
        addStatusView(theme)
        addUserView(theme)
        addFeeView(theme)
        addDateView(theme)
        addRoundView(theme)
        addIdView(theme)
        addVoteKeyView(theme)
        addSelectionKeyView(theme)
        addStateProofKeyView(theme)
        addVoteFirstValidRoundView(theme)
        addVoteLastValidRoundView(theme)
        addVoteKeyDilutionView(theme)
        addParticipationStatusView(theme)
        addNoteView(theme)
        addOpenInPeraExplorerButton(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension KeyRegTransactionDetailView {
    private func addVerticalStackView(_ theme: KeyRegTransactionDetailViewTheme) {
        verticalStackView.axis = .vertical

        addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func addStatusView(_ theme: KeyRegTransactionDetailViewTheme) {
        statusView.customize(theme.transactionStatusInformationViewTheme)

        verticalStackView.addArrangedSubview(statusView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: statusView)
        statusView.addSeparator(theme.separator, padding: theme.separatorTopPadding)

        statusView.bindData(TransactionStatusInformationViewModel(title: "transaction-detail-status".localized))
    }

    private func addRewardView(_ theme: KeyRegTransactionDetailViewTheme) {
        rewardView.customize(theme.commonTransactionAmountInformationViewTheme)

        verticalStackView.addArrangedSubview(rewardView)

        rewardView.bindData(TransactionAmountInformationViewModel(title: "transaction-detail-reward".localized))
    }

    private func addUserView(_ theme: KeyRegTransactionDetailViewTheme) {
        userView.customize(theme.transactionUserInformationViewTheme)

        verticalStackView.addArrangedSubview(userView)
    }

    private func addFeeView(_ theme: KeyRegTransactionDetailViewTheme) {
        feeView.customize(theme.commonTransactionAmountInformationViewTheme)

        verticalStackView.addArrangedSubview(feeView)

        feeView.bindData(TransactionAmountInformationViewModel(title: "transaction-detail-fee".localized))
    }

    private func addDateView(_ theme: KeyRegTransactionDetailViewTheme) {
        dateView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(dateView)

        dateView.bindData(TransactionTextInformationViewModel(title: "transaction-detail-date".localized))
    }

    private func addRoundView(_ theme: KeyRegTransactionDetailViewTheme) {
        roundView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(roundView)

        roundView.bindData(TransactionTextInformationViewModel(title: "transaction-detail-round".localized))
    }

    private func addIdView(_ theme: KeyRegTransactionDetailViewTheme) {
        idView.customize(theme.transactionTextInformationViewTransactionIDTheme)

        verticalStackView.addArrangedSubview(idView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: idView)
        idView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addVoteKeyView(_ theme: KeyRegTransactionDetailViewTheme) {
        voteKeyView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(voteKeyView)
    }

    private func addSelectionKeyView(_ theme: KeyRegTransactionDetailViewTheme) {
        selectionKeyView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(selectionKeyView)
    }

    private func addStateProofKeyView(_ theme: KeyRegTransactionDetailViewTheme) {
        stateProofKeyView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(stateProofKeyView)
    }

    private func addVoteFirstValidRoundView(_ theme: KeyRegTransactionDetailViewTheme) {
        voteFirstValidRoundView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(voteFirstValidRoundView)
    }

    private func addVoteLastValidRoundView(_ theme: KeyRegTransactionDetailViewTheme) {
        voteLastValidRoundView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(voteLastValidRoundView)
    }

    private func addVoteKeyDilutionView(_ theme: KeyRegTransactionDetailViewTheme) {
        voteKeyDilutionView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(voteKeyDilutionView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: voteKeyDilutionView)
        voteKeyDilutionView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addParticipationStatusView(_ theme: KeyRegTransactionDetailViewTheme) {
        participationStatusView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(participationStatusView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: participationStatusView)
        participationStatusView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addNoteView(_ theme: KeyRegTransactionDetailViewTheme) {
        noteView.customize(theme.transactionTextInformationViewCommonTheme)
        noteView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(noteView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: noteView)
        noteView.addSeparator(theme.separator, padding: theme.separatorTopPadding)

        noteView.bindData(TransactionTextInformationViewModel(title: "transaction-detail-note".localized))
    }

    private func addOpenInPeraExplorerButton(_ theme: KeyRegTransactionDetailViewTheme) {
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

extension KeyRegTransactionDetailView {
    @objc
    func notifyDelegateToOpenPeraExplorer() {
        delegate?.transactionDetailView(self, didOpen: .peraExplorer)
    }
}

extension KeyRegTransactionDetailView {
    func bindData(
        _ viewModel: KeyRegTransactionDetailViewModel?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
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

        if let voteKeyViewModel = viewModel?.voteKeyViewModel {
            voteKeyView.bindData(voteKeyViewModel)
        } else {
            voteKeyView.hideViewInStack()
        }

        if let selectionKeyViewModel = viewModel?.selectionKeyViewModel {
            selectionKeyView.bindData(selectionKeyViewModel)
        } else {
            selectionKeyView.hideViewInStack()
        }

        if let stateProofKeyViewModel = viewModel?.stateProofKeyViewModel {
            stateProofKeyView.bindData(stateProofKeyViewModel)
        } else {
            stateProofKeyView.hideViewInStack()
        }

        if let voteFirstValidRoundViewModel = viewModel?.voteFirstValidRoundViewModel {
            voteFirstValidRoundView.bindData(voteFirstValidRoundViewModel)
        } else {
            voteFirstValidRoundView.hideViewInStack()
        }

        if let voteLastValidRoundViewModel = viewModel?.voteLastValidRoundViewModel {
            voteLastValidRoundView.bindData(voteLastValidRoundViewModel)
        } else {
            voteLastValidRoundView.hideViewInStack()
        }

        if let voteKeyDilutionViewModel = viewModel?.voteKeyDilutionViewModel {
            voteKeyDilutionView.bindData(voteKeyDilutionViewModel)
        } else {
            voteKeyDilutionView.hideViewInStack()
        }

        if let participationStatusViewModel = viewModel?.participationStatusViewModel {
            participationStatusView.bindData(participationStatusViewModel)
        } else {
            participationStatusView.hideViewInStack()
        }
    }
}

extension KeyRegTransactionDetailView {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        switch interaction {
        case userContextMenuInteraction:
            return delegate?.contextMenuInteractionForUser(self)
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

protocol KeyRegTransactionDetailViewDelegate: AnyObject {
    func contextMenuInteractionForUser(
        _ transactionDetailView: KeyRegTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForTransactionID(
        _ transactionDetailView: KeyRegTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForTransactionNote(
        _ transactionDetailView: KeyRegTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func transactionDetailView(
        _ transactionDetailView: KeyRegTransactionDetailView,
        didOpen explorer: AlgoExplorerType
    )
}
