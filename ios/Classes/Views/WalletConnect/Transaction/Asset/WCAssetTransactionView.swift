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
//   WCAssetTransactionView.swift

import UIKit

class WCAssetTransactionView: WCSingleTransactionView {

    weak var delegate: WCAssetTransactionViewDelegate?

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

extension WCAssetTransactionView {
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

extension WCAssetTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetTransactionViewDidOpenRawTransaction(self)
    }
}

extension WCAssetTransactionView {
    func bind(_ viewModel: WCAssetTransactionViewModel) {
        accountInformationView.bind(viewModel.senderInformationViewModel)

        if let assetInformationViewModel = viewModel.assetInformationViewModel {
            assetInformationView.bind(assetInformationViewModel)
            unhideViewAnimatedIfNeeded(assetInformationView)
        } else {
            assetInformationView.hideViewInStack()
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
            unhideViewAnimatedIfNeeded(closeWarningInformationView)
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
            unhideViewAnimatedIfNeeded(balanceInformationView)
        } else {
            balanceInformationView.hideViewInStack()
        }

        if let amountInformationViewModel = viewModel.amountInformationViewModel {
            amountInformationView.bind(amountInformationViewModel)
            unhideViewAnimatedIfNeeded(amountInformationView)
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

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            noteInformationView.bind(noteInformationViewModel)
        } else {
            noteInformationView.hideViewInStack()
        }

        if let rawTransactionInformationViewModel = viewModel.rawTransactionInformationViewModel {
            rawTransactionInformationView.bind(rawTransactionInformationViewModel)
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

protocol WCAssetTransactionViewDelegate: AnyObject {
    func wcAssetTransactionViewDidOpenRawTransaction(_ wcAssetTransactionView: WCAssetTransactionView)
}
