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
//  TransactionDetailViewController.swift

import UIKit

final class TransactionDetailViewController: BaseScrollViewController {
    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .transactionDetail)
    }
    
    private lazy var transactionDetailView = TransactionDetailView(transactionType: transactionType)

    private lazy var currencyFormatter = CurrencyFormatter()
    
    private var transaction: Transaction
    private let account: Account
    private var assetDetail: Asset?
    private let transactionType: TransferType

    private lazy var transactionDetailViewModel = TransactionDetailViewModel(
        transactionType: transactionType,
        transaction: transaction,
        account: account,
        assetDetail: assetDetail
    )

    private lazy var tooltipController = TooltipUIController(
        presentingView: view
    )

    private let copyToClipboardController: CopyToClipboardController
    
    init(
        account: Account,
        transaction: Transaction,
        transactionType: TransferType,
        assetDetail: Asset?,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transaction = transaction
        self.transactionType = transactionType
        self.assetDetail = assetDetail
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        transactionDetailView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let tooltipDisplayStore = TooltipDisplayStore()

        if !tooltipDisplayStore.isDisplayedCopyAddressTooltip {
            tooltipDisplayStore.isDisplayedCopyAddressTooltip = true

            tooltipController.present(
                on: transactionDetailView.userView.detailLabel,
                title: "title-press-hold-copy-address".localized,
                duration: .default
            )
            return
        }
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        scrollView.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
        title = "transaction-detail-title".localized
        configureTransactionDetail()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addTransactionDetailView()
    }
}

extension TransactionDetailViewController {
    private func addTransactionDetailView() {
        contentView.addSubview(transactionDetailView)
        transactionDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransactionDetailViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Contact],
              let contact = userInfo["contact"] else {
            return
        }
        
        transaction.contact = contact
        transactionDetailViewModel.bindOpponent(for: transaction, with: contact.address ?? "")
        transactionDetailView.bindOpponentViewDetail(transactionDetailViewModel)
    }
}

extension TransactionDetailViewController {
    private func configureTransactionDetail() {
        transactionDetailView.bindData(
            transactionDetailViewModel,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension TransactionDetailViewController: TransactionDetailViewDelegate {
    func transactionDetailViewDidTapAddContactButton(_ transactionDetailView: TransactionDetailView) {
        guard case let .address(address) = transactionDetailViewModel.opponentType else {
            return
        }
        open(.addContact(address: address), by: .push)
    }

    func contextMenuInteractionForUser(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                guard let address = self.getUserAddress(
                    transaction: transaction,
                    type: transactionType
                ) else {
                    return
                }

                self.copyToClipboardController.copyAddress(
                    address
                )
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    private func getUserAddress(
        transaction: Transaction,
        type: TransferType
    ) -> String? {
        switch type {
        case .received:
            return transaction.getReceiver()
        case .sent:
            return transaction.sender
        }
    }

    func contextMenuInteractionForOpponent(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                let address = (self.transactionDetailViewModel.opponentType?.address).someString
                self.copyToClipboardController.copyAddress(address)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForCloseTo(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                let address = (self.transaction.payment?.closeAddress).someString
                self.copyToClipboardController.copyAddress(address)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForTransactionID(
        _ transactionDetailView: TransactionDetailView
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
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyTransactionNote) {
                [unowned self] _ in
                self.copyToClipboardController.copyNote(self.transaction)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }
    
    func transactionDetailView(_ transactionDetailView: TransactionDetailView, didOpen explorer: AlgoExplorerType) {
        if let api = api,
           let transactionId = transaction.id ?? transaction.parentID,
           let url = explorer.transactionURL(with: transactionId, in: api.network) {
            open(url)
        }
    }
}

extension TransactionDetailViewController {
    private final class TooltipDisplayStore: Storable {
        typealias Object = Any

        var isDisplayedCopyAddressTooltip: Bool {
            get { userDefaults.bool(forKey: isDisplayedCopyAddressTooltipKey) }
            set { userDefaults.set(newValue, forKey: isDisplayedCopyAddressTooltipKey) }
        }

        private let isDisplayedCopyAddressTooltipKey =
        "cache.key.transactionDetailIsDisplayedCopyAddressTooltip"
    }
}
