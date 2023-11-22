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
//   WCAlgosTransactionViewController.swift

import UIKit

final class WCAlgosTransactionViewController: WCSingleTransactionViewController {
    private lazy var algosTransactionView = WCAlgosTransactionView()

    private lazy var currencyFormatter = CurrencyFormatter()

    override var transactionView: WCSingleTransactionView? {
        return algosTransactionView
    }

    override func configureAppearance() {
        super.configureAppearance()

        title = "wallet-connect-transaction-title-transaction".localized
    }

    override func linkInteractors() {
        super.linkInteractors()
        algosTransactionView.delegate = self
    }

    override func bindData() {
        algosTransactionView.bind(
            WCAlgosTransactionViewModel(
                transaction: transaction,
                senderAccount: account,
                currency: sharedDataController.currency,
                currencyFormatter: currencyFormatter
            )
        )
    }
}

extension WCAlgosTransactionViewController: WCAlgosTransactionViewDelegate {
    func wcAlgosTransactionViewDidOpenRawTransaction(_ wcAlgosTransactionView: WCAlgosTransactionView) {
        displayRawTransaction()
    }
}

extension WCAlgosTransactionViewController: WCSingleTransactionViewControllerActionable { }
