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

//   WCKeyRegTransactionViewController.swift

import UIKit

final class WCKeyRegTransactionViewController: 
    WCSingleTransactionViewController,
    WCKeyRegTransactionViewDelegate,
    WCSingleTransactionViewControllerActionable {
    private lazy var keyRegTransactionView = WCKeyRegTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return keyRegTransactionView
    }

    override func configureAppearance() {
        super.configureAppearance()

        title = "transaction-details-title".localized

        view.backgroundColor = Colors.Defaults.background.uiColor
    }

    override func linkInteractors() {
        super.linkInteractors()

        keyRegTransactionView.delegate = self
    }

    override func bindData() {
        super.bindData()

        let viewModel = WCKeyRegTransactionViewModel(
            transaction: transaction,
            senderAccount: account,
            currency: sharedDataController.currency,
            currencyFormatter: .init()
        )
        keyRegTransactionView.bind(viewModel)
    }
}

extension WCKeyRegTransactionViewController {
    func wcKeyRegTransactionViewDidOpenRawTransaction(
        _ wcKeyRegTransactionView: WCKeyRegTransactionView
    ) {
        displayRawTransaction()
    }
}
