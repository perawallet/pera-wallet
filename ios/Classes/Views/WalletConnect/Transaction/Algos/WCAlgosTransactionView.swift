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
//   WCAlgosTransactionView.swift

import UIKit

class WCAlgosTransactionView: WCSingleTransactionView {

    weak var delegate: WCAlgosTransactionViewDelegate?

    private lazy var accountInformationView = TitledTransactionAccountNameView()

    private lazy var assetInformationView: TransactionAssetView = {
        let assetInformationView = TransactionAssetView()
        assetInformationView.setAssetAlignment(.right)
        return assetInformationView
    }()

    private lazy var receiverInformationView = WCTransactionTextInformationView()

    private lazy var authAccountInformationView = WCTransactionTextInformationView()

    private lazy var rekeyWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var closeWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var balanceInformationView = TitledTransactionAmountInformationView()

    private lazy var amountInformationView = TitledTransactionAmountInformationView()

    private lazy var feeInformationView = TitledTransactionAmountInformationView()

    private lazy var feeWarningView = WCContainedTransactionWarningView()

    private lazy var noteInformationView = WCTransactionTextInformationView()

    private lazy var rawTransactionInformationView = WCTransactionActionableInformationView()

    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addTransactionInformationViews()
        addDetailedInformationViews()
    }

    override func setListeners() {
        rawTransactionInformationView.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
    }
}

extension WCAlgosTransactionView {
    private func addParticipantInformationViews() {
        addParticipantInformationView(accountInformationView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(balanceInformationView)
        addParticipantInformationView(authAccountInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        addTransactionInformationView(receiverInformationView)
        addTransactionInformationView(amountInformationView)
        addTransactionInformationView(feeInformationView)
        addTransactionInformationView(feeWarningView)
    }

    private func addDetailedInformationViews() {
        addDetailedInformationView(noteInformationView)
        addDetailedInformationView(rawTransactionInformationView)
    }
}

extension WCAlgosTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAlgosTransactionViewDidOpenRawTransaction(self)
    }
}

extension WCAlgosTransactionView {
    func bind(_ viewModel: WCAlgosTransactionViewModel) {
        accountInformationView.bind(viewModel.senderInformationViewModel)

        if let assetInformationViewModel = viewModel.assetInformationViewModel {
            assetInformationView.bind(assetInformationViewModel)
        }

        if let receiverInformationViewModel = viewModel.receiverInformationViewModel {
            receiverInformationView.bind(receiverInformationViewModel)
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

        if let balanceInformationViewModel = viewModel.balanceInformationViewModel {
            balanceInformationView.bind(balanceInformationViewModel)
        } else {
            balanceInformationView.hideViewInStack()
        }

        amountInformationView.bind(viewModel.amountInformationViewModel)
        feeInformationView.bind(viewModel.feeInformationViewModel)

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
    }
}

protocol WCAlgosTransactionViewDelegate: AnyObject {
    func wcAlgosTransactionViewDidOpenRawTransaction(_ wcAlgosTransactionView: WCAlgosTransactionView)
}
