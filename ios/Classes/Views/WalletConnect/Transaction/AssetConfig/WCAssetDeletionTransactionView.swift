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
//   WCAssetDeletionTransactionView.swift

import UIKit

class WCAssetDeletionTransactionView: WCSingleTransactionView {
    
    weak var delegate: WCAssetDeletionTransactionViewDelegate?

    private lazy var accountInformationView = TitledTransactionAccountNameView()

    private lazy var assetInformationView: TransactionAssetView = {
        let assetInformationView = TransactionAssetView()
        assetInformationView.setAssetAlignment(.right)
        return assetInformationView
    }()

    private lazy var assetWarningView = WCContainedTransactionWarningView()

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

extension WCAssetDeletionTransactionView {
    private func addParticipantInformationViews() {
        addParticipantInformationView(accountInformationView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(assetWarningView)
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

extension WCAssetDeletionTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetDeletionTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenAlgoExplorer() {
        delegate?.wcAssetDeletionTransactionViewDidOpenAlgoExplorer(self)
    }
}

extension WCAssetDeletionTransactionView {
    func bind(_ viewModel: WCAssetDeletionTransactionViewModel) {
        accountInformationView.bind(viewModel.senderInformationViewModel)

        if let assetInformationViewModel = viewModel.assetInformationViewModel {
            assetInformationView.bind(assetInformationViewModel)
            unhideViewAnimatedIfNeeded(assetInformationView)
        } else {
            assetInformationView.hideViewInStack()
        }

        if let assetWarningViewModel = viewModel.assetWarningViewModel,
           viewModel.assetInformationViewModel != nil {
            assetWarningView.bind(assetWarningViewModel)
            unhideViewAnimatedIfNeeded(assetWarningView)
        } else {
            assetWarningView.hideViewInStack()
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

protocol WCAssetDeletionTransactionViewDelegate: AnyObject {
    func wcAssetDeletionTransactionViewDidOpenRawTransaction(_ wcAssetDeletionTransactionView: WCAssetDeletionTransactionView)
    func wcAssetDeletionTransactionViewDidOpenAlgoExplorer(_ wcAssetDeletionTransactionView: WCAssetDeletionTransactionView)
}
