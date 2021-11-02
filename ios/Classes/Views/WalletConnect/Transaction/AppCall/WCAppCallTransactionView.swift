// Copyright 2019 Algorand, Inc.

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

class WCAppCallTransactionView: WCSingleTransactionView {

    weak var delegate: WCAppCallTransactionViewDelegate?

    private lazy var accountInformationView = TitledTransactionAccountNameView()

    private lazy var idInformationView = WCTransactionTextInformationView()

    private lazy var onCompletionInformationView = WCTransactionTextInformationView()

    private lazy var appGlobalSchemaInformationView = WCTransactionTextInformationView()

    private lazy var appLocalSchemaInformationView = WCTransactionTextInformationView()

    private lazy var appExtraPagesInformationView = WCTransactionTextInformationView()

    private lazy var approvalHashInformationView = WCTransactionTextInformationView()

    private lazy var clearStateHashInformationView = WCTransactionTextInformationView()

    private lazy var authAccountInformationView = WCTransactionTextInformationView()

    private lazy var closeWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var rekeyWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var feeInformationView = TitledTransactionAmountInformationView()

    private lazy var feeWarningView = WCContainedTransactionWarningView()

    private lazy var noteInformationView = WCTransactionTextInformationView()

    private lazy var rawTransactionInformationView = WCTransactionActionableInformationView()

    private lazy var algoExplorerInformationView = WCTransactionActionableInformationView()

    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addTransactionInformationViews()
        addDetailedInformationViews()
    }

    override func setListeners() {
        rawTransactionInformationView.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
        algoExplorerInformationView.addTarget(self, action: #selector(notifyDelegateToOpenAlgoExplorer), for: .touchUpInside)
    }
}

extension WCAppCallTransactionView {
    private func addParticipantInformationViews() {
        addParticipantInformationView(accountInformationView)
        addParticipantInformationView(idInformationView)
        addParticipantInformationView(onCompletionInformationView)
        addParticipantInformationView(appGlobalSchemaInformationView)
        addParticipantInformationView(appLocalSchemaInformationView)
        addParticipantInformationView(appExtraPagesInformationView)
        addParticipantInformationView(approvalHashInformationView)
        addParticipantInformationView(clearStateHashInformationView)
        addParticipantInformationView(authAccountInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        addTransactionInformationView(feeInformationView)
        addTransactionInformationView(feeWarningView)
    }

    private func addDetailedInformationViews() {
        addDetailedInformationView(noteInformationView)
        addDetailedInformationView(rawTransactionInformationView)
        addDetailedInformationView(algoExplorerInformationView)
    }
}

extension WCAppCallTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAppCallTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenAlgoExplorer() {
        delegate?.wcAppCallTransactionViewDidOpenAlgoExplorer(self)
    }
}

extension WCAppCallTransactionView {
    func bind(_ viewModel: WCAppCallTransactionViewModel) {
        accountInformationView.bind(viewModel.senderInformationViewModel)

        if let idInformationViewModel = viewModel.idInformationViewModel {
            idInformationView.bind(idInformationViewModel)
        } else {
            idInformationView.hideViewInStack()
        }

        if let onCompletionInformationViewModel = viewModel.onCompletionInformationViewModel {
            onCompletionInformationView.bind(onCompletionInformationViewModel)
        }

        if let appGlobalSchemaInformationViewModel = viewModel.appGlobalSchemaInformationViewModel {
            appGlobalSchemaInformationView.bind(appGlobalSchemaInformationViewModel)
        } else {
            appGlobalSchemaInformationView.hideViewInStack()
        }

        if let appLocalSchemaInformationViewModel = viewModel.appLocalSchemaInformationViewModel {
            appLocalSchemaInformationView.bind(appLocalSchemaInformationViewModel)
        } else {
            appLocalSchemaInformationView.hideViewInStack()
        }

        if let appExtraPagesInformationViewModel = viewModel.appExtraPagesInformationViewModel {
            appExtraPagesInformationView.bind(appExtraPagesInformationViewModel)
        } else {
            appExtraPagesInformationView.hideViewInStack()
        }

        if let approvalHashInformationViewModel = viewModel.approvalHashInformationViewModel {
            approvalHashInformationView.bind(approvalHashInformationViewModel)
        } else {
            approvalHashInformationView.hideViewInStack()
        }

        if let clearStateHashInformationViewModel = viewModel.clearStateHashInformationViewModel {
            clearStateHashInformationView.bind(clearStateHashInformationViewModel)
        } else {
            clearStateHashInformationView.hideViewInStack()
        }

        if let authAccountInformationViewModel = viewModel.authAccountInformationViewModel {
            authAccountInformationView.bind(authAccountInformationViewModel)
        } else {
            authAccountInformationView.hideViewInStack()
        }

        if let closeWarningInformationViewModel = viewModel.closeWarningInformationViewModel {
            closeWarningInformationView.bind(closeWarningInformationViewModel)
        } else {
            closeWarningInformationView.hideViewInStack()
        }

        if let rekeyWarningInformationViewModel = viewModel.rekeyWarningInformationViewModel {
            rekeyWarningInformationView.bind(rekeyWarningInformationViewModel)
        } else {
            rekeyWarningInformationView.hideViewInStack()
        }

        if let feeInformationViewModel = viewModel.feeInformationViewModel {
            feeInformationView.bind(feeInformationViewModel)
        } else {
            feeInformationView.hideViewInStack()
        }

        if let feeWarningViewModel = viewModel.feeWarningViewModel {
            feeWarningView.bind(feeWarningViewModel)
        } else {
            feeWarningView.hideViewInStack()
        }

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            noteInformationView.bind(noteInformationViewModel)
        } else {
            noteInformationView.hideViewInStack()
        }

        if let rawTransactionInformationViewModel = viewModel.rawTransactionInformationViewModel {
            rawTransactionInformationView.bind(rawTransactionInformationViewModel)
        }

        if let algoExplorerInformationViewModel = viewModel.algoExplorerInformationViewModel {
            algoExplorerInformationView.bind(algoExplorerInformationViewModel)
        } else {
            algoExplorerInformationView.hideViewInStack()
        }
    }
}

protocol WCAppCallTransactionViewDelegate: AnyObject {
    func wcAppCallTransactionViewDidOpenRawTransaction(_ wcAppCallTransactionView: WCAppCallTransactionView)
    func wcAppCallTransactionViewDidOpenAlgoExplorer(_ wcAppCallTransactionView: WCAppCallTransactionView)
}
