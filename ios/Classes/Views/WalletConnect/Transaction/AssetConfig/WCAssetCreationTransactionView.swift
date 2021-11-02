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
//   WCAssetCreationTransactionView.swift

import UIKit

class WCAssetCreationTransactionView: WCSingleTransactionView {

    weak var delegate: WCAssetCreationTransactionViewDelegate?

    private lazy var accountInformationView = TitledTransactionAccountNameView()

    private lazy var assetNameView = WCTransactionTextInformationView()

    private lazy var unitNameView = WCTransactionTextInformationView()

    private lazy var authAccountInformationView = WCTransactionTextInformationView()

    private lazy var closeWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var rekeyWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var amountInformationView = TitledTransactionAmountInformationView()

    private lazy var feeInformationView = TitledTransactionAmountInformationView()

    private lazy var feeWarningView = WCContainedTransactionWarningView()

    private lazy var decimalPlacesView = WCTransactionTextInformationView()

    private lazy var defaultFrozenView = WCTransactionTextInformationView()

    private lazy var managerAccountView = WCTransactionTextInformationView()

    private lazy var reserveAccountView = WCTransactionTextInformationView()

    private lazy var freezeAccountView = WCTransactionTextInformationView()

    private lazy var clawbackAccountView = WCTransactionTextInformationView()

    private lazy var noteInformationView = WCTransactionTextInformationView()

    private lazy var metadataInformationView = WCTransactionTextInformationView()

    private lazy var rawTransactionInformationView = WCTransactionActionableInformationView()

    private lazy var assetURLInformationView = WCTransactionActionableInformationView()

    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addTransactionInformationViews()
        addDetailedInformationViews()
    }

    override func setListeners() {
        rawTransactionInformationView.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
        assetURLInformationView.addTarget(self, action: #selector(notifyDelegateToOpenAssetURL), for: .touchUpInside)
    }
}

extension WCAssetCreationTransactionView {
    private func addParticipantInformationViews() {
        addParticipantInformationView(accountInformationView)
        addParticipantInformationView(assetNameView)
        addParticipantInformationView(unitNameView)
        addParticipantInformationView(authAccountInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        addTransactionInformationView(amountInformationView)
        addTransactionInformationView(feeInformationView)
        addTransactionInformationView(feeWarningView)
        addTransactionInformationView(decimalPlacesView)
        addTransactionInformationView(defaultFrozenView)
        addTransactionInformationView(managerAccountView)
        addTransactionInformationView(reserveAccountView)
        addTransactionInformationView(freezeAccountView)
        addTransactionInformationView(clawbackAccountView)
    }

    private func addDetailedInformationViews() {
        addDetailedInformationView(noteInformationView)
        addDetailedInformationView(metadataInformationView)
        addDetailedInformationView(rawTransactionInformationView)
        addDetailedInformationView(assetURLInformationView)
    }
}

extension WCAssetCreationTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetCreationTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenAssetURL() {
        delegate?.wcAssetCreationTransactionViewDidOpenAssetURL(self)
    }
}

extension WCAssetCreationTransactionView {
    func bind(_ viewModel: WCAssetCreationTransactionViewModel) {
        accountInformationView.bind(viewModel.senderInformationViewModel)

        if let assetNameViewModel = viewModel.assetNameViewModel {
            assetNameView.bind(assetNameViewModel)
        } else {
            assetNameView.hideViewInStack()
        }

        if let unitNameViewModel = viewModel.unitNameViewModel {
            unitNameView.bind(unitNameViewModel)
        } else {
            unitNameView.hideViewInStack()
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

        if let amountInformationViewModel = viewModel.amountInformationViewModel {
            amountInformationView.bind(amountInformationViewModel)
        } else {
            amountInformationView.hideViewInStack()
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

        if let decimalPlacesViewModel = viewModel.decimalPlacesViewModel {
            decimalPlacesView.bind(decimalPlacesViewModel)
        } else {
            decimalPlacesView.hideViewInStack()
        }

        if let defaultFrozenViewModel = viewModel.defaultFrozenViewModel {
            defaultFrozenView.bind(defaultFrozenViewModel)
        } else {
            defaultFrozenView.hideViewInStack()
        }

        if let managerAccountViewModel = viewModel.managerAccountViewModel {
            managerAccountView.bind(managerAccountViewModel)
        } else {
            managerAccountView.hideViewInStack()
        }

        if let freezeAccountViewModel = viewModel.freezeAccountViewModel {
            freezeAccountView.bind(freezeAccountViewModel)
        } else {
            freezeAccountView.hideViewInStack()
        }

        if let reserveAccountViewModel = viewModel.reserveAccountViewModel {
            reserveAccountView.bind(reserveAccountViewModel)
        } else {
            reserveAccountView.hideViewInStack()
        }

        if let clawbackAccountViewModel = viewModel.clawbackAccountViewModel {
            clawbackAccountView.bind(clawbackAccountViewModel)
        } else {
            clawbackAccountView.hideViewInStack()
        }

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            noteInformationView.bind(noteInformationViewModel)
        } else {
            noteInformationView.hideViewInStack()
        }

        if let metadataInformationViewModel = viewModel.metadataInformationViewModel {
            metadataInformationView.bind(metadataInformationViewModel)
        } else {
            metadataInformationView.hideViewInStack()
        }

        if let rawTransactionInformationViewModel = viewModel.rawTransactionInformationViewModel {
            rawTransactionInformationView.bind(rawTransactionInformationViewModel)
        }

        if let assetURLInformationViewModel = viewModel.assetURLInformationViewModel {
            assetURLInformationView.bind(assetURLInformationViewModel)
        } else {
            assetURLInformationView.hideViewInStack()
        }
    }
}

protocol WCAssetCreationTransactionViewDelegate: AnyObject {
    func wcAssetCreationTransactionViewDidOpenRawTransaction(_ wcAssetCreationTransactionView: WCAssetCreationTransactionView)
    func wcAssetCreationTransactionViewDidOpenAssetURL(_ wcAssetCreationTransactionView: WCAssetCreationTransactionView)
}
