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
//   WCUnsignedRequestScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCUnsignedRequestScreen: BaseViewController {
    weak var delegate: WCUnsignedRequestScreenDelegate?

    private lazy var scrollView: UIScrollView = UIScrollView()

    private lazy var theme = Theme()
    private lazy var unsignedRequestView = WCUnsignedRequestView()
    private lazy var layoutBuilder = WCMainTransactionLayout(
        dataSource: dataSource,
        sharedDataController: sharedDataController,
        currencyFormatter: currencyFormatter
    )

    private lazy var currencyFormatter = CurrencyFormatter()

    private let dataSource: WCMainTransactionDataSource

    init(
        dataSource: WCMainTransactionDataSource,
        configuration: ViewControllerConfiguration
    ) {
        self.dataSource = dataSource
        super.init(configuration: configuration)
        setupObserver()
    }

    deinit {
        removeObserver()
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor.uiColor
        scrollView.backgroundColor = theme.backgroundColor.uiColor
        unsignedRequestView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = "wallet-connect-transaction-title-unsigned".localized

        hidesCloseBarButtonItem = true
    }

    override func prepareLayout() {
        super.prepareLayout()

        addScrollView()
        addContentView()
    }

    override func linkInteractors() {
        super.linkInteractors()

        unsignedRequestView.setDataSource(dataSource)
        unsignedRequestView.setDelegate(layoutBuilder)
        unsignedRequestView.delegate = self
        layoutBuilder.delegate = self
    }
}

extension WCUnsignedRequestScreen {
    private func addScrollView() {
        scrollView.isScrollEnabled = false
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addContentView() {
        let contentView = UIView()
        contentView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalToSuperview().priority(.low)
            make.edges.equalToSuperview()
        }

        contentView.addSubview(unsignedRequestView)
        unsignedRequestView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension WCUnsignedRequestScreen {
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
        unsignedRequestView.reloadData()
    }
}

extension WCUnsignedRequestScreen: WCUnsignedRequestViewDelegate {
    func wcUnsignedRequestViewDidTapCancel(_ requestView: WCUnsignedRequestView) {
        delegate?.wcUnsignedRequestScreenDidReject(self)
    }

    func wcUnsignedRequestViewDidTapConfirm(_ requestView: WCUnsignedRequestView) {
        delegate?.wcUnsignedRequestScreenDidConfirm(self)
    }
}

extension WCUnsignedRequestScreen: WCMainTransactionLayoutDelegate {
    func wcMainTransactionLayout(
        _ wcMainTransactionLayout: WCMainTransactionLayout,
        didSelect transactions: [WCTransaction]
    ) {
        if transactions.count == 1 {
            if let transaction = transactions.first {
                presentSingleWCTransaction(
                    transaction,
                    with: dataSource.transactionRequest,
                    wcSession: dataSource.wcSession
                )
            }
            return
        }

        open(
            .wcGroupTransaction(
                transactions: transactions,
                transactionRequest: dataSource.transactionRequest,
                wcSession: dataSource.wcSession
            ),
            by: .push
        )
    }
}

extension WCUnsignedRequestScreen: WalletConnectSingleTransactionRequestPresentable { }

protocol WCUnsignedRequestScreenDelegate: AnyObject {
    func wcUnsignedRequestScreenDidConfirm(
        _ wcUnsignedRequestScreen: WCUnsignedRequestScreen
    )
    func wcUnsignedRequestScreenDidReject(
        _ wcUnsignedRequestScreen: WCUnsignedRequestScreen
    )
}
