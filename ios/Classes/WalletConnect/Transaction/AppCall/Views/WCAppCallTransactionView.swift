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
//   WCAppCallTransactionView.swift

import UIKit

final class WCAppCallTransactionView: WCSingleTransactionView {
    weak var delegate: WCAppCallTransactionViewDelegate?

    private lazy var theme = Theme()

    private lazy var senderView = TitledTransactionAccountNameView()
    private lazy var idInformationView = TransactionTextInformationView()
    private lazy var onCompletionInformationView = TransactionTextInformationView()
    private lazy var appGlobalSchemaInformationView = TransactionTextInformationView()
    private lazy var appLocalSchemaInformationView = TransactionTextInformationView()
    private lazy var appExtraPagesInformationView = TransactionTextInformationView()
    private lazy var approvalHashInformationView = TransactionTextInformationView()
    private lazy var clearStateHashInformationView = TransactionTextInformationView()
    private lazy var closeInformationView = TransactionTextInformationView()
    private lazy var closeWarningInformationView = WCTransactionWarningView()
    private lazy var rekeyInformationView = TransactionTextInformationView()
    private lazy var rekeyWarningInformationView = WCTransactionWarningView()

    private lazy var feeView = TransactionAmountInformationView()
    private lazy var warningFeeView = WCTransactionWarningView()

    private lazy var noteView = TransactionTextInformationView()

    private lazy var topButtonsContainer = HStackView()
    private lazy var rawTransactionButton = UIButton()
    private lazy var peraExplorerButton = UIButton()

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = Colors.Defaults.background.uiColor
    }

    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addTransactionInformationViews()
        addDetailedInformationViews()
        addButtons()
    }

    override func setListeners() {
        rawTransactionButton.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
        peraExplorerButton.addTarget(self, action: #selector(notifyDelegateToOpenPeraExplorer), for: .touchUpInside)
    }
}

extension WCAppCallTransactionView {
    private func addParticipantInformationViews() {
        senderView.customize(theme.accountInformationTheme)
        idInformationView.customize(theme.textInformationTheme)
        onCompletionInformationView.customize(theme.textInformationTheme)
        appGlobalSchemaInformationView.customize(theme.textInformationTheme)
        appLocalSchemaInformationView.customize(theme.textInformationTheme)
        appExtraPagesInformationView.customize(theme.textInformationTheme)
        approvalHashInformationView.customize(theme.textInformationTheme)
        clearStateHashInformationView.customize(theme.textInformationTheme)
        approvalHashInformationView.customize(theme.textInformationTheme)
        closeInformationView.customize(theme.textInformationTheme)
        rekeyInformationView.customize(theme.textInformationTheme)

        addParticipantInformationView(senderView)
        addParticipantInformationView(idInformationView)
        addParticipantInformationView(onCompletionInformationView)
        addParticipantInformationView(appGlobalSchemaInformationView)
        addParticipantInformationView(appLocalSchemaInformationView)
        addParticipantInformationView(appExtraPagesInformationView)
        addParticipantInformationView(approvalHashInformationView)
        addParticipantInformationView(clearStateHashInformationView)
        addParticipantInformationView(closeInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        feeView.customize(theme.amountInformationTheme)

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

        peraExplorerButton.customizeAppearance(theme.peraExplorerButtonStyle)
        peraExplorerButton.layer.draw(corner: theme.buttonsCorner)
        peraExplorerButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        addButton(topButtonsContainer)

        topButtonsContainer.spacing = theme.buttonSpacing

        topButtonsContainer.addArrangedSubview(rawTransactionButton)
        topButtonsContainer.addArrangedSubview(peraExplorerButton)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        topButtonsContainer.addArrangedSubview(spacer)
    }
}

extension WCAppCallTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAppCallTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenPeraExplorer() {
        delegate?.wcAppCallTransactionViewDidOpenPeraExplorer(self)
    }
}

extension WCAppCallTransactionView {
    func bind(_ viewModel: WCAppCallTransactionViewModel) {
        senderView.bindData(viewModel.senderInformationViewModel)

        if let idInformationViewModel = viewModel.idInformationViewModel {
            idInformationView.bindData(idInformationViewModel)
        } else {
            idInformationView.hideViewInStack()
        }

        if let onCompletionInformationViewModel = viewModel.onCompletionInformationViewModel {
            onCompletionInformationView.bindData(onCompletionInformationViewModel)
        }

        if let appGlobalSchemaInformationViewModel = viewModel.appGlobalSchemaInformationViewModel {
            appGlobalSchemaInformationView.bindData(appGlobalSchemaInformationViewModel)
        } else {
            appGlobalSchemaInformationView.hideViewInStack()
        }

        if let appLocalSchemaInformationViewModel = viewModel.appLocalSchemaInformationViewModel {
            appLocalSchemaInformationView.bindData(appLocalSchemaInformationViewModel)
        } else {
            appLocalSchemaInformationView.hideViewInStack()
        }

        if let appExtraPagesInformationViewModel = viewModel.appExtraPagesInformationViewModel {
            appExtraPagesInformationView.bindData(appExtraPagesInformationViewModel)
        } else {
            appExtraPagesInformationView.hideViewInStack()
        }

        if let approvalHashInformationViewModel = viewModel.approvalHashInformationViewModel {
            approvalHashInformationView.bindData(approvalHashInformationViewModel)
        } else {
            approvalHashInformationView.hideViewInStack()
        }

        if let clearStateHashInformationViewModel = viewModel.clearStateHashInformationViewModel {
            clearStateHashInformationView.bindData(clearStateHashInformationViewModel)
        } else {
            clearStateHashInformationView.hideViewInStack()
        }

        if let closeInformationViewModel = viewModel.closeInformationViewModel {
            closeInformationView.bindData(closeInformationViewModel)
        } else {
            closeInformationView.hideViewInStack()
        }

        if let warningInformationViewModel = viewModel.closeWarningInformationViewModel {
            closeWarningInformationView.bind(warningInformationViewModel)
        } else {
            closeWarningInformationView.hideViewInStack()
        }

        if let rekeyInformationViewModel = viewModel.rekeyInformationViewModel {
            rekeyInformationView.bindData(rekeyInformationViewModel)
        } else {
            rekeyInformationView.hideViewInStack()
        }

        if let warningInformationViewModel = viewModel.rekeyWarningInformationViewModel {
            rekeyWarningInformationView.bind(warningInformationViewModel)
        } else {
            rekeyWarningInformationView.hideViewInStack()
        }

        if let feeInformationViewModel = viewModel.feeInformationViewModel {
            feeView.bindData(feeInformationViewModel)
            showTransactionInformationStackView(true)
        } else {
            feeView.hideViewInStack()
            showTransactionInformationStackView(false)
        }

        if let feeWarningViewModel = viewModel.feeWarningViewModel {
            warningFeeView.bind(feeWarningViewModel)
        } else {
            warningFeeView.hideViewInStack()
        }

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            noteView.bindData(noteInformationViewModel)
            showNoteStackView(true)
        } else {
            noteView.hideViewInStack()
            showNoteStackView(false)
        }

        if viewModel.rawTransactionInformationViewModel != nil {
            rawTransactionButton.showViewInStack()
        } else {
            rawTransactionButton.hideViewInStack()
        }

        if viewModel.peraExplorerInformationViewModel != nil {
            peraExplorerButton.showViewInStack()
        } else {
            peraExplorerButton.hideViewInStack()
        }
    }
}

protocol WCAppCallTransactionViewDelegate: AnyObject {
    func wcAppCallTransactionViewDidOpenRawTransaction(_ wcAppCallTransactionView: WCAppCallTransactionView)
    func wcAppCallTransactionViewDidOpenPeraExplorer(_ wcAppCallTransactionView: WCAppCallTransactionView)
}
