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
    override var name: AnalyticsScreenName? {
        return .transactionDetail
    }
    
    private lazy var transactionDetailView = TransactionDetailView(transactionType: transactionType)
    
    private var transaction: Transaction
    private let account: Account
    private var assetDetail: AssetInformation?
    private let transactionType: TransactionType

    private lazy var transactionDetailViewModel = TransactionDetailViewModel(
        transactionType: transactionType,
        transaction: transaction,
        account: account,
        assetDetail: assetDetail
    )
    
    init(
        account: Account,
        transaction: Transaction,
        transactionType: TransactionType,
        assetDetail: AssetInformation?,
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
        addBarButtons()
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
        scrollView.customizeBaseAppearance(backgroundColor: AppColors.Shared.System.background)
        title = "transaction-detail-title".localized
        configureTransactionDetail()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addTransactionDetailView()
    }
}

extension TransactionDetailViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
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
        transactionDetailView.bindData(transactionDetailViewModel)
    }
}

extension TransactionDetailViewController: TransactionDetailViewDelegate {
    func transactionDetailViewDidTapAddContactButton(_ transactionDetailView: TransactionDetailView) {
        guard case let .address(address) = transactionDetailViewModel.opponentType else {
            return
        }
        open(.addContact(address: address), by: .push)
    }
    
    func transactionDetailViewDidCopyOpponentAddress(_ transactionDetailView: TransactionDetailView) {
        guard let opponentType = transactionDetailViewModel.opponentType else {
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
           let url = explorer.transactionURL(with: transactionId, in: api.network) {
            open(url)
        }
    }
    
    func transactionDetailViewDidCopyTransactionNote(_ transactionDetailView: TransactionDetailView) {
        UIPasteboard.general.string = transaction.noteRepresentation()
        displaySimpleAlertWith(title: "transaction-detail-note-copied".localized)
    }

    func transactionDetailViewDidCopyTransactionID(_ transactionDetailView: TransactionDetailView) {
        UIPasteboard.general.string = transaction.id
        displaySimpleAlertWith(title: "transaction-detail-id-copied-title".localized)
    }
}

enum TransactionType {
    case sent
    case received
}

enum AlgoExplorerType {
    case algoexplorer
    case goalseeker

    func transactionURL(with id: String, in network: ALGAPI.Network) -> URL? {
        switch network {
        case .testnet:
            return testNetTransactionURL(with: id)
        case .mainnet:
            return mainNetTransactionURL(with: id)
        }
    }

    private func testNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://testnet.algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/testnet/transaction/\(id)")
        }
    }

    private func mainNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/mainnet/transaction/\(id)")
        }
    }
}
