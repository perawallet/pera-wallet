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
//   WCGroupTransactionViewController.swift

import UIKit

final class WCGroupTransactionViewController: BaseViewController {
    private lazy var groupTransactionView = WCGroupTransactionView()

    private lazy var dataSource = WCGroupTransactionDataSource(
        sharedDataController: sharedDataController,
        transactions: transactions,
        currencyFormatter: currencyFormatter
    )

    private lazy var layoutBuilder = WCGroupTransactionLayout(
        dataSource: dataSource,
        sharedDataController: sharedDataController,
        currencyFormatter: currencyFormatter
    )

    private lazy var currencyFormatter = CurrencyFormatter()

    private let transactions: [WCTransaction]
    private let transactionRequest: WalletConnectRequestDraft
    private let wcSession: WCSessionDraft

    init(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequestDraft,
        session: WCSessionDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.transactions = transactions
        self.transactionRequest = transactionRequest
        self.wcSession = session
        super.init(configuration: configuration)
        setupObserver()
    }

    deinit {
        removeObserver()
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-multiple".localized
        view.backgroundColor = Colors.Defaults.background.uiColor
        groupTransactionView.backgroundColor = Colors.Defaults.background.uiColor
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

extension WCGroupTransactionViewController {
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAssetFetched(notification:)),
            name: .AssetDetailFetched,
            object: nil
        )
    }

    private func removeObserver() {
        NotificationCenter
            .default
            .removeObserver(self)
    }

    @objc
    private func didAssetFetched(notification: Notification) {
        groupTransactionView.reloadData()
    }
}

extension WCGroupTransactionViewController: WCGroupTransactionLayoutDelegate {
    func wcGroupTransactionLayout(
        _ wcGroupTransactionLayout: WCGroupTransactionLayout,
        didSelect transaction: WCTransaction
    ) {
        presentSingleWCTransaction(
            transaction,
            with: transactionRequest,
            wcSession: wcSession
        )
    }
}

extension WCGroupTransactionViewController: WalletConnectSingleTransactionRequestPresentable { }
