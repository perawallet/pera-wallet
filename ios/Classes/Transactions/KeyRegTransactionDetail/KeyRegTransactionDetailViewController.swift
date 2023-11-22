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

//   KeyRegTransactionDetailViewController.swift

import UIKit

final class KeyRegTransactionDetailViewController: BaseScrollViewController {
    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .transactionDetail)
    }

    private lazy var contextView = KeyRegTransactionDetailView()

    private let account: Account
    private let transaction: Transaction
    private let copyToClipboardController: CopyToClipboardController

    init(
        account: Account,
        transaction: Transaction,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transaction = transaction
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "transaction-detail-title".localized

        addUI()
    }
}

extension KeyRegTransactionDetailViewController {
    private func addUI() {
        addBackground()
        addContext()
    }

    private func addBackground() {
        scrollView.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
    }

    private func addContext() {
        scrollView.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)

        contextView.customize(KeyRegTransactionDetailViewTheme())

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contextView.delegate = self

        bindContext()
    }

    private func bindContext() {
        let viewModel = KeyRegTransactionDetailViewModel(
            transaction: transaction,
            account: account
        )
        contextView.bindData(
            viewModel,
            currency: sharedDataController.currency,
            currencyFormatter: .init()
        )
    }
}

extension KeyRegTransactionDetailViewController: KeyRegTransactionDetailViewDelegate {
    func contextMenuInteractionForUser(
        _ transactionDetailView: KeyRegTransactionDetailView
    ) -> UIContextMenuConfiguration? {
        guard let senderAddress = transaction.sender else { return nil }

        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                self.copyToClipboardController.copyAddress(senderAddress)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForTransactionID(
        _ transactionDetailView: KeyRegTransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyTransactionID) {
                [unowned self] _ in
                self.copyToClipboardController.copyID(self.transaction)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForTransactionNote(
        _ transactionDetailView: KeyRegTransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyTransactionNote) {
                [unowned self] _ in
                self.copyToClipboardController.copyNote(self.transaction)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func transactionDetailView(
        _ transactionDetailView: KeyRegTransactionDetailView,
        didOpen explorer: AlgoExplorerType
    ) {
        if let transactionId = transaction.id ?? transaction.parentID,
           let url = explorer.transactionURL(with: transactionId, in: api!.network) {
            open(url)
        }
    }
}
