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
//   WCSingleTransactionRequestScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSingleTransactionRequestScreen: BaseViewController {
    weak var delegate: WCSingleTransactionRequestScreenDelegate?
    var isScrollEnabled: Bool = true
    lazy var scrollView: UIScrollView = UIScrollView()

    /// <todo> This should be refactored while this screen is on refactor process.
    private var assetDecoration: AssetDecoration?

    private lazy var requestView = WCSingleTransactionRequestView()
    private lazy var viewModel: WCSingleTransactionRequestViewModel? = {
        guard let transaction = transactions.first else {
            return nil
        }

        let account: Account?

        if let address = transaction.transactionDetail?.sender {
            account = sharedDataController.accountCollection[address]?.value
        } else {
            account = nil
        }

        let asset: Asset?

        if let assetId = transaction.transactionDetail?.currentAssetId,
           let assetDetail = sharedDataController.assetDetailCollection[assetId] {
            if assetDetail.isCollectible {
                asset = StandardAsset(asset: ALGAsset(id: assetId), decoration: assetDetail)
            } else {
                asset = nil
            }
        } else {
            asset = nil
        }

        return WCSingleTransactionRequestViewModel(
            transaction: transaction,
            account: account,
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }()

    private lazy var theme = Theme()

    var transactions: [WCTransaction] {
        dataSource.transactions(at: 0) ?? []
    }

    let dataSource: WCMainTransactionDataSource

    private let currencyFormatter: CurrencyFormatter

    init(
        dataSource: WCMainTransactionDataSource,
        configuration: ViewControllerConfiguration,
        currencyFormatter: CurrencyFormatter
    ) {
        self.dataSource = dataSource
        self.currencyFormatter = currencyFormatter

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
        requestView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    override func linkInteractors() {
        super.linkInteractors()

        requestView.delegate = self
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = viewModel?.title

        hidesCloseBarButtonItem = true
    }

    override func prepareLayout() {
        super.prepareLayout()

        addScrollView()
        addContentView()
    }

    override func bindData() {
        super.bindData()

        requestView.bind(viewModel)
    }
}

extension WCSingleTransactionRequestScreen {
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
        guard let transaction = transactions.first,
              let assetId = transaction.transactionDetail?.currentAssetId,
              let assetDecoration = sharedDataController.assetDetailCollection[assetId]
        else {
            return
        }

        self.assetDecoration = assetDecoration
        if assetDecoration.isCollectible {
            let asset = CollectibleAsset(asset: ALGAsset(id: assetId), decoration: assetDecoration)
            self.viewModel?.middleView?.asset = asset
        } else {
            let asset = StandardAsset(asset: ALGAsset(id: assetId), decoration: assetDecoration)
            self.viewModel?.middleView?.asset = asset
        }

        bindData()
    }
}

extension WCSingleTransactionRequestScreen {
    private func addScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
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

        contentView.addSubview(requestView)
        requestView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension WCSingleTransactionRequestScreen: WCSingleTransactionRequestViewDelegate {
    func wcSingleTransactionRequestViewDidTapCancel(
        _ requestView: WCSingleTransactionRequestView
    ) {
        delegate?.wcSingleTransactionRequestScreenDidReject(self)
    }

    func wcSingleTransactionRequestViewDidTapConfirm(
        _ requestView: WCSingleTransactionRequestView
    ) {
        delegate?.wcSingleTransactionRequestScreenDidConfirm(self)
    }

    func wcSingleTransactionRequestViewDidTapShowTransaction(
        _ requestView: WCSingleTransactionRequestView
    ) {
        guard let transaction = transactions.first else {
            return
        }

        presentSingleWCTransaction(
            transaction,
            with: dataSource.transactionRequest,
            wcSession: dataSource.wcSession
        )
    }

    func wcSingleTransactionRequestViewDidOpenASADiscovery(
        _ requestView: WCSingleTransactionRequestView
    ) {
        openASADiscovery()
    }

    private func openASADiscovery() {
        guard let asset = assetDecoration else {
            return
        }

        let screen = Screen.asaDiscovery(
            account: nil,
            quickAction: nil,
            asset: asset
        )
        open(
            screen,
            by: .present
        )
    }
}

extension WCSingleTransactionRequestScreen: WalletConnectSingleTransactionRequestPresentable { }

protocol WCSingleTransactionRequestScreenDelegate: AnyObject {
    func wcSingleTransactionRequestScreenDidConfirm(
        _ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen
    )
    func wcSingleTransactionRequestScreenDidReject(
        _ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen
    )
}
