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
//   WCAssetAdditionTransactionView.swift

import UIKit

class WCAssetAdditionTransactionView: WCSingleTransactionView {

    weak var delegate: WCAssetAdditionTransactionViewDelegate?

    private lazy var accountInformationView = TitledTransactionAccountNameView()

    private lazy var assetInformationView: TransactionAssetView = {
        let assetInformationView = TransactionAssetView()
        assetInformationView.setAssetAlignment(.right)
        return assetInformationView
    }()

    private lazy var authAccountInformationView = WCTransactionTextInformationView()

    private lazy var rekeyWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var closeWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var feeInformationView = TitledTransactionAmountInformationView()

    private lazy var feeWarningView = WCContainedTransactionWarningView()

    private lazy var noteInformationView = WCTransactionTextInformationView()

    private lazy var rawTransactionInformationView = WCTransactionActionableInformationView()

    private lazy var algoExplorerInformationView = WCTransactionActionableInformationView()

    private lazy var assetURLInformationView = WCTransactionActionableInformationView()

    private lazy var assetMetadataInformationView = WCTransactionActionableInformationView()

    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addBalanceInformationViews()
        addDetailedInformationViews()
    }

    override func setListeners() {
        rawTransactionInformationView.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
        algoExplorerInformationView.addTarget(self, action: #selector(notifyDelegateToOpenAlgoExplorer), for: .touchUpInside)
        assetURLInformationView.addTarget(self, action: #selector(notifyDelegateToOpenAssetURL), for: .touchUpInside)
        assetMetadataInformationView.addTarget(self, action: #selector(notifyDelegateToOpenAssetMetadata), for: .touchUpInside)
    }
}

extension WCAssetAdditionTransactionView {
    private func addParticipantInformationViews() {
        addParticipantInformationView(accountInformationView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(authAccountInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addBalanceInformationViews() {
        addTransactionInformationView(feeInformationView)
        addTransactionInformationView(feeWarningView)
    }

    private func addDetailedInformationViews() {
        addDetailedInformationView(noteInformationView)
        addDetailedInformationView(rawTransactionInformationView)
        addDetailedInformationView(algoExplorerInformationView)
        addDetailedInformationView(assetURLInformationView)
        addDetailedInformationView(assetMetadataInformationView)
    }
}

extension WCAssetAdditionTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetAdditionTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenAlgoExplorer() {
        delegate?.wcAssetAdditionTransactionViewDidOpenAlgoExplorer(self)
    }

    @objc
    private func notifyDelegateToOpenAssetURL() {
        delegate?.wcAssetAdditionTransactionViewDidOpenAssetURL(self)
    }

    @objc
    private func notifyDelegateToOpenAssetMetadata() {
        delegate?.wcAssetAdditionTransactionViewDidOpenAssetMetadata(self)
    }
}

extension WCAssetAdditionTransactionView {
    func bind(_ viewModel: WCAssetAdditionTransactionViewModel) {
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
        } else {
            rawTransactionInformationView.hideViewInStack()
        }

        if let algoExplorerInformationViewModel = viewModel.algoExplorerInformationViewModel {
            algoExplorerInformationView.bind(algoExplorerInformationViewModel)
            unhideViewAnimatedIfNeeded(algoExplorerInformationView)
        } else {
            algoExplorerInformationView.hideViewInStack()
        }

        if let urlInformationViewModel = viewModel.urlInformationViewModel {
            assetURLInformationView.bind(urlInformationViewModel)
            unhideViewAnimatedIfNeeded(assetURLInformationView)
        } else {
            assetURLInformationView.hideViewInStack()
        }

        if let metadataInformationViewModel = viewModel.metadataInformationViewModel {
            assetMetadataInformationView.bind(metadataInformationViewModel)
            unhideViewAnimatedIfNeeded(assetMetadataInformationView)
        } else {
            assetMetadataInformationView.hideViewInStack()
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

protocol WCAssetAdditionTransactionViewDelegate: AnyObject {
    func wcAssetAdditionTransactionViewDidOpenRawTransaction(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView)
    func wcAssetAdditionTransactionViewDidOpenAlgoExplorer(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView)
    func wcAssetAdditionTransactionViewDidOpenAssetURL(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView)
    func wcAssetAdditionTransactionViewDidOpenAssetMetadata(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView)
}
