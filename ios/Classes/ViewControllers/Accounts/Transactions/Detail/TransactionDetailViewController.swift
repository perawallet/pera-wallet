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
//  TransactionDetailViewController.swift

import UIKit

class TransactionDetailViewController: BaseScrollViewController {
    
    override var name: AnalyticsScreenName? {
        return .transactionDetail
    }
    
    private lazy var transactionDetailView = TransactionDetailView(transactionType: transactionType)
    
    private var transaction: Transaction
    private let account: Account
    private var assetDetail: AssetDetail?
    private let transactionType: TransactionType
    
    private let transactionDetailTooltipStorage = TransactionDetailTooltipStorage()
    
    private let viewModel = TransactionDetailViewModel()
    
    init(
        account: Account,
        transaction: Transaction,
        transactionType: TransactionType,
        assetDetail: AssetDetail?,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transaction = transaction
        self.transactionType = transactionType
        self.assetDetail = assetDetail
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentInformationCopyTooltipIfNeeded()
        }
    }
    
    override func linkInteractors() {
        transactionDetailView.delegate = self
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
        title = "transaction-detail-title".localized
        contentView.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        configureTransactionDetail()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionDetailViewLayout()
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
        viewModel.setOpponent(for: transaction, with: contact.address ?? "", in: transactionDetailView)
    }
}

extension TransactionDetailViewController: TooltipPresenter {
    private func configureTransactionDetail() {
        if transactionType == .sent {
            viewModel.configureSentTransaction(transactionDetailView, with: transaction, and: assetDetail, for: account)
        } else {
            viewModel.configureReceivedTransaction(transactionDetailView, with: transaction, and: assetDetail, for: account)
        }
    }
    
    private func presentInformationCopyTooltipIfNeeded() {
        if transactionDetailTooltipStorage.isInformationCopyTooltipDisplayed() || !isViewAppeared {
            return
        }
        
        presentTooltip(
            with: "transaction-detail-copy-tooltip".localized,
            using: configuration,
            at: transactionDetailView.opponentView.copyImageView
        )
        transactionDetailTooltipStorage.setInformationCopyTooltipDisplayed()
    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

extension TransactionDetailViewController {
    private func setupTransactionDetailViewLayout() {
        contentView.addSubview(transactionDetailView)
        
        transactionDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionDetailViewController: TransactionDetailViewDelegate {
    func transactionDetailViewDidTapOpponentActionButton(_ transactionDetailView: TransactionDetailView) {
        guard let opponentType = viewModel.opponentType else {
            return
        }
        
        switch opponentType {
        case let .contact(address):
            let draft = QRCreationDraft(address: address, mode: .address)
            open(
                .qrGenerator(
                    title: transaction.contact?.name ?? "qr-creation-sharing-title".localized,
                    draft: draft,
                    isTrackable: true
                ),
                by: .present
            )
        case let .localAccount(address):
            let draft = QRCreationDraft(address: address, mode: .address)
            open(
                .qrGenerator(
                    title: "qr-creation-sharing-title".localized,
                    draft: draft,
                    isTrackable: true
                ),
                by: .present
            )
        case let .address(address):
            let viewController = open(.addContact(mode: .new()), by: .push) as? AddContactViewController
            viewController?.addContactView.userInformationView.algorandAddressInputView.value = address
        }
    }
    
    func transactionDetailViewDidCopyOpponentAddress(_ transactionDetailView: TransactionDetailView) {
        guard let opponentType = viewModel.opponentType else {
            return
        }
        
        switch opponentType {
        case let .contact(address),
             let .localAccount(address),
             let .address(address):
            UIPasteboard.general.string = address
        }
        
        displaySimpleAlertWith(title: "qr-creation-copied".localized)
    }
    
    func transactionDetailViewDidCopyCloseToAddress(_ transactionDetailView: TransactionDetailView) {
        UIPasteboard.general.string = transaction.payment?.closeAddress
        displaySimpleAlertWith(title: "qr-creation-copied".localized)
    }

    func transactionDetailView(_ transactionDetailView: TransactionDetailView, didOpen explorer: AlgoExplorerType) {
        if let api = api,
           let transactionId = transaction.id,
           let url = explorer.transactionURL(with: transactionId, in: api.isTestNet ? .testnet : .mainnet) {
            open(url)
        }
    }
    
    func transactionDetailViewDidCopyTransactionNote(_ transactionDetailView: TransactionDetailView) {
        UIPasteboard.general.string = transaction.noteRepresentation()
        displaySimpleAlertWith(title: "transaction-detail-note-copied".localized)
    }
}

enum TransactionType {
    case sent
    case received
}

private struct TransactionDetailTooltipStorage: Storable {
    typealias Object = Any
    
    private let informationCopyTooltipKey = "com.algorand.algorand.transaction.detail.information.copy.tooltip"
    
    func setInformationCopyTooltipDisplayed() {
        save(true, for: informationCopyTooltipKey, to: .defaults)
    }
    
    func isInformationCopyTooltipDisplayed() -> Bool {
        return bool(with: informationCopyTooltipKey, to: .defaults)
    }
}
