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

//   WCKeyRegTransactionView.swift

import UIKit
import MacaroonUIKit

final class WCKeyRegTransactionView: WCSingleTransactionView {
    weak var delegate: WCKeyRegTransactionViewDelegate?

    private lazy var theme = Theme()

    private lazy var fromView = TitledTransactionAccountNameView()
    private lazy var rekeyInformationView = TransactionTextInformationView()
    private lazy var rekeyWarningInformationView = WCTransactionWarningView()
    private lazy var voteKeyView = TransactionTextInformationView()
    private lazy var selectionKeyView = TransactionTextInformationView()
    private lazy var stateProofKeyView = TransactionTextInformationView()
    private lazy var voteFirstValidRoundView = TransactionTextInformationView()
    private lazy var voteLastValidRoundView = TransactionTextInformationView()
    private lazy var voteKeyDilutionView = TransactionTextInformationView()
    private lazy var participationStatusView = TransactionTextInformationView()
    private lazy var feeView = TransactionAmountInformationView()
    private lazy var warningFeeView = WCTransactionWarningView()
    private lazy var noteView = TransactionTextInformationView()
    private lazy var topButtonsContainer = HStackView()
    private lazy var rawTransactionButton = UIButton()

    override func prepareLayout() {
        super.prepareLayout()
        
        addParticipantInformationViews()
        addTransactionInformationViews()
        addDetailedInformationViews()
        addButtons()
    }

    override func setListeners() {
        super.setListeners()
        
        rawTransactionButton.addTarget(
            self,
            action: #selector(notifyDelegateToOpenRawTransaction),
            for: .touchUpInside
        )
    }

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = Colors.Defaults.background.uiColor
    }
}

extension WCKeyRegTransactionView {
    private func addParticipantInformationViews() {
        fromView.customize(theme.accountInformationTheme)
        rekeyInformationView.customize(theme.textInformationTheme)

        addParticipantInformationView(fromView)
        addParticipantInformationView(rekeyInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        voteKeyView.customize(theme.textInformationTheme)
        selectionKeyView.customize(theme.textInformationTheme)
        stateProofKeyView.customize(theme.textInformationTheme)
        voteFirstValidRoundView.customize(theme.textInformationTheme)
        voteLastValidRoundView.customize(theme.textInformationTheme)
        voteKeyDilutionView.customize(theme.textInformationTheme)
        participationStatusView.customize(theme.textInformationTheme)
        feeView.customize(theme.amountInformationTheme)

        addTransactionInformationView(voteKeyView)
        addTransactionInformationView(selectionKeyView)
        addTransactionInformationView(stateProofKeyView)
        addTransactionInformationView(voteFirstValidRoundView)
        addTransactionInformationView(voteLastValidRoundView)
        addTransactionInformationView(voteKeyDilutionView)
        addTransactionInformationView(participationStatusView)
        addTransactionInformationView(feeView)
        addTransactionInformationView(warningFeeView)
    }

    private func addDetailedInformationViews() {
        noteView.customize(theme.textInformationTheme)

        addDetailedInformationView(noteView)
    }

    private func addButtons() {
        rawTransactionButton.customizeAppearance(theme.rawTransactionButtonStyle)
        rawTransactionButton.layer.draw(corner: theme.buttonsCorner)
        rawTransactionButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        addButton(topButtonsContainer)

        topButtonsContainer.addArrangedSubview(rawTransactionButton)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        topButtonsContainer.addArrangedSubview(spacer)
    }
}

extension WCKeyRegTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcKeyRegTransactionViewDidOpenRawTransaction(self)
    }
}

extension WCKeyRegTransactionView {
    func bind(_ viewModel: WCKeyRegTransactionViewModel) {
        if let fromInformationViewModel = viewModel.fromInformationViewModel {
            unhideViewAnimatedIfNeeded(fromView)
            fromView.bindData(fromInformationViewModel)
        } else {
            fromView.hideViewInStack()
        }

        if let rekeyInformationViewModel = viewModel.rekeyInformationViewModel {
            unhideViewAnimatedIfNeeded(rekeyInformationView)
            rekeyInformationView.bindData(rekeyInformationViewModel)
        } else {
            rekeyInformationView.hideViewInStack()
        }

        if let warningInformationViewModel = viewModel.rekeyWarningInformationViewModel {
            unhideViewAnimatedIfNeeded(rekeyWarningInformationView)
            rekeyWarningInformationView.bind(warningInformationViewModel)
        } else {
            rekeyWarningInformationView.hideViewInStack()
        }

        if let voteKeyViewModel = viewModel.voteKeyViewModel {
            unhideViewAnimatedIfNeeded(voteKeyView)
            voteKeyView.bindData(voteKeyViewModel)
        } else {
            voteKeyView.hideViewInStack()
        }

        if let selectionKeyViewModel = viewModel.selectionKeyViewModel {
            unhideViewAnimatedIfNeeded(selectionKeyView)
            selectionKeyView.bindData(selectionKeyViewModel)
        } else {
            selectionKeyView.hideViewInStack()
        }

        if let stateProofKeyViewModel = viewModel.stateProofKeyViewModel {
            unhideViewAnimatedIfNeeded(stateProofKeyView)
            stateProofKeyView.bindData(stateProofKeyViewModel)
        } else {
            stateProofKeyView.hideViewInStack()
        }

        if let voteFirstValidRoundViewModel = viewModel.voteFirstValidRoundViewModel {
            unhideViewAnimatedIfNeeded(voteFirstValidRoundView)
            voteFirstValidRoundView.bindData(voteFirstValidRoundViewModel)
        } else {
            voteFirstValidRoundView.hideViewInStack()
        }

        if let voteLastValidRoundViewModel = viewModel.voteLastValidRoundViewModel {
            unhideViewAnimatedIfNeeded(voteLastValidRoundView)
            voteLastValidRoundView.bindData(voteLastValidRoundViewModel)
        } else {
            voteLastValidRoundView.hideViewInStack()
        }

        if let voteKeyDilutionViewModel = viewModel.voteKeyDilutionViewModel {
            unhideViewAnimatedIfNeeded(voteKeyDilutionView)
            voteKeyDilutionView.bindData(voteKeyDilutionViewModel)
        } else {
            voteKeyDilutionView.hideViewInStack()
        }

        if let participationStatusViewModel = viewModel.participationStatusViewModel {
            unhideViewAnimatedIfNeeded(participationStatusView)
            participationStatusView.bindData(participationStatusViewModel)
        } else {
            participationStatusView.hideViewInStack()
        }

        if let feeViewModel = viewModel.feeViewModel {
            unhideViewAnimatedIfNeeded(feeView)
            feeView.bindData(feeViewModel)
        } else {
            feeView.hideViewInStack()
        }

        if let feeWarningViewModel = viewModel.feeWarningInformationViewModel {
            unhideViewAnimatedIfNeeded(warningFeeView)
            warningFeeView.bind(feeWarningViewModel)
        } else {
            warningFeeView.hideViewInStack()
        }

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            showNoteStackView(true)
            unhideViewAnimatedIfNeeded(noteView)
            noteView.bindData(noteInformationViewModel)
        } else {
            showNoteStackView(false)
            noteView.hideViewInStack()
        }
    }

    private func unhideViewAnimatedIfNeeded(_ view: UIView) {
        if view.isHidden {
            UIView.animate(withDuration: 0.3) {
                view.showViewInStack()
            }
        }
    }
}

protocol WCKeyRegTransactionViewDelegate: AnyObject {
    func wcKeyRegTransactionViewDidOpenRawTransaction(
        _ wcKeyRegTransactionView: WCKeyRegTransactionView
    )
}
