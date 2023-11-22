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
//   WCAssetConfigTransactionViewController.swift

import UIKit

final class WCAssetCreationTransactionViewController: WCSingleTransactionViewController {
    private lazy var assetCreationTransactionView = WCAssetCreationTransactionView()

    private lazy var currencyFormatter = CurrencyFormatter()

    override var transactionView: WCSingleTransactionView? {
        return assetCreationTransactionView
    }

    var asset: Asset?

    override func configureAppearance() {
        super.configureAppearance()

        title = "wallet-connect-asset-creation-title".localized
    }

    override func linkInteractors() {
        super.linkInteractors()

        assetCreationTransactionView.delegate = self
    }

    override func bindData() {
        bindView()
    }

    private func bindView() {
        assetCreationTransactionView.bind(
            WCAssetCreationTransactionViewModel(
                transaction: transaction,
                senderAccount: account,
                asset: asset,
                currency: sharedDataController.currency,
                currencyFormatter: currencyFormatter
            )
        )
    }
}

extension WCAssetCreationTransactionViewController: WCAssetCreationTransactionViewDelegate {
    func wcAssetCreationTransactionViewDidOpenRawTransaction(_ wcAssetCreationTransactionView: WCAssetCreationTransactionView) {
        displayRawTransaction()
    }

    func wcAssetCreationTransactionViewDidOpenAssetURL(_ wcAssetCreationTransactionView: WCAssetCreationTransactionView) {
        if let urlString = transaction.transactionDetail?.assetConfigParams?.url,
           let url = URL(string: urlString) {
            open(url)
        }
    }

    func wcAssetCreationTransactionViewDidOpenAssetDiscovery(
        _ wcAssetCreationTransactionView: WCAssetCreationTransactionView
    ) {
        openAssetDiscovery(asset)
    }
}

extension WCAssetCreationTransactionViewController: WCSingleTransactionViewControllerAssetManagable { }
