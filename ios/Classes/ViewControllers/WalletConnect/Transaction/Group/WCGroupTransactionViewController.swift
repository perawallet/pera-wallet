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
//   WCGroupTransactionViewController.swift

import UIKit
import SVProgressHUD

class WCGroupTransactionViewController: BaseViewController {

    private lazy var groupTransactionView = WCGroupTransactionView()

    private lazy var dataSource = WCGroupTransactionDataSource(
        session: session,
        transactions: transactions,
        walletConnector: walletConnector
    )

    private lazy var layoutBuilder = WCGroupTransactionLayout(dataSource: dataSource)

    private let transactions: [WCTransaction]
    private let transactionRequest: WalletConnectRequest

    init(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        configuration: ViewControllerConfiguration
    ) {
        self.transactions = transactions
        self.transactionRequest = transactionRequest
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-multiple".localized
    }

    override func linkInteractors() {
        groupTransactionView.setDataSource(dataSource)
        groupTransactionView.setDelegate(layoutBuilder)
        layoutBuilder.delegate = self
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(groupTransactionView)
    }
}

extension WCGroupTransactionViewController: WCGroupTransactionLayoutDelegate {
    func wcGroupTransactionLayout(
        _ wcGroupTransactionLayout: WCGroupTransactionLayout,
        didSelect transaction: WCTransaction
    ) {
        presentSingleWCTransaction(transaction, with: transactionRequest)
    }
}

extension WCGroupTransactionViewController: WalletConnectSingleTransactionRequestPresentable { }
