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
//   WCAssetReconfigurationTransactionView.swift

import UIKit

class WCAssetReconfigurationTransactionView: WCSingleTransactionView {

    weak var delegate: WCAssetReconfigurationTransactionViewDelegate?

    private lazy var accountInformationView = TitledTransactionAccountNameView()

    private lazy var assetInformationView: TransactionAssetView = {
        let assetInformationView = TransactionAssetView()
        assetInformationView.setAssetAlignment(.right)
        return assetInformationView
    }()

    private lazy var authAccountInformationView = WCTransactionTextInformationView()

    private lazy var closeWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var rekeyWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var feeInformationView = TitledTransactionAmountInformationView()

    private lazy var feeWarningView = WCContainedTransactionWarningView()

    private lazy var managerAccountView = WCTransactionTextInformationView()

    private lazy var reserveAccountView = WCTransactionTextInformationView()

    private lazy var freezeAccountView = WCTransactionTextInformationView()

    private lazy var clawbackAccountView = WCTransactionTextInformationView()

    private lazy var noteInformationView = WCTransactionTextInformationView()

    private lazy var rawTransactionInformationView = WCTransactionActionableInformationView()

    private lazy var assetURLInformationView = WCTransactionActionableInformationView()

    private lazy var algoExplorerInformationView = WCTransactionActionableInformationView()

    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addTransactionInformationViews()
        addDetailedInformationViews()
    }

    override func setListeners() {
        rawTransactionInformationView.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
        assetURLInformationView.addTarget(self, action: #selector(notifyDelegateToOpenAssetURL), for: .touchUpInside)
        algoExplorerInformationView.addTarget(self, action: #selector(notifyDelegateToOpenAlgoExplorer), for: .touchUpInside)
    }
}

extension WCAssetReconfigurationTransactionView {
    private func addParticipantInformationViews() {
        addParticipantInformationView(accountInformationView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(authAccountInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        addTransactionInformationView(feeInformationView)
        addTransactionInformationView(feeWarningView)
        addTransactionInformationView(managerAccountView)
        addTransactionInformationView(reserveAccountView)
        addTransactionInformationView(freezeAccountView)
        addTransactionInformationView(clawbackAccountView)
    }

    private func addDetailedInformationViews() {
        addDetailedInformationView(noteInformationView)
        addDetailedInformationView(rawTransactionInformationView)
        addDetailedInformationView(assetURLInformationView)
        addDetailedInformationView(algoExplorerInformationView)
    }
}

extension WCAssetReconfigurationTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetReconfigurationTransactionViewDidOpenRawTransaction(self)
    }
    
    @objc
    private func notifyDelegateToOpenAssetURL() {
        delegate?.wcAssetReconfigurationTransactionViewDidOpenAssetURL(self)
    }

    @objc
    private func notifyDelegateToOpenAlgoExplorer() {
        delegate?.wcAssetReconfigurationTransactionViewDidOpenAlgoExplorer(self)
    }
}

extension WCAssetReconfigurationTransactionView {
    func bind(_ viewModel: WCAssetReconfigurationTransactionViewModel) {
        accountInformationView.bind(viewModel.senderInformationViewModel)

        if let assetInformationViewModel = viewModel.assetInformationViewModel {
            assetInformationView.bind(assetInformationViewModel)
            unhideViewAnimatedIfNeeded(assetInformationView)
        } else {
            assetInformationView.hideViewInStack()
        }

        if let authAccountInformationViewModel = viewModel.authAccountInformationViewModel {
            authAccountInformationView.bind(authAccountInformationViewModel)
        } else {
            authAccountInformationView.hideViewInStack()
        }

        if let closeWarningInformationViewModel = viewModel.closeWarningInformationViewModel {
            closeWarningInformationView.bind(closeWarningInformationViewModel)
            unhideViewAnimatedIfNeeded(closeWarningInformationView)
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

        if let rawTransactionInformationViewModel = viewModel.rawTransactionInformationViewModel {
            rawTransactionInformationView.bind(rawTransactionInformationViewModel)
        }

        if let assetURLInformationViewModel = viewModel.assetURLInformationViewModel {
            assetURLInformationView.bind(assetURLInformationViewModel)
        }

        if let algoExplorerInformationViewModel = viewModel.algoExplorerInformationViewModel {
            algoExplorerInformationView.bind(algoExplorerInformationViewModel)
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

protocol WCAssetReconfigurationTransactionViewDelegate: AnyObject {
    func wcAssetReconfigurationTransactionViewDidOpenRawTransaction(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    )
    func wcAssetReconfigurationTransactionViewDidOpenAssetURL(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    )
    func wcAssetReconfigurationTransactionViewDidOpenAlgoExplorer(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    )
}
