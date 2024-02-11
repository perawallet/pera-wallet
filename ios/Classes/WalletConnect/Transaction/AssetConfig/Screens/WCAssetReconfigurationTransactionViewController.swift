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
//   WCAssetReconfigurationTransactionViewController.swift

import UIKit

final class WCAssetReconfigurationTransactionViewController: WCSingleTransactionViewController {
    private lazy var assetReconfigurationTransactionView = WCAssetReconfigurationTransactionView()

    private lazy var currencyFormatter = CurrencyFormatter()

    override var transactionView: WCSingleTransactionView? {
        return assetReconfigurationTransactionView
    }

    var asset: Asset?

    override func configureAppearance() {
        super.configureAppearance()

        title = "wallet-connect-asset-reconfiguration-title".localized
    }

    override func linkInteractors() {
        super.linkInteractors()

        assetReconfigurationTransactionView.delegate = self
    }

    override func bindData() {
        bindView()

        setCachedAsset {
            if self.asset == nil {
                self.dismissScreen()
                return
            }

            DispatchQueue.main.async {
                self.bindView()
            }
        }
    }
}

extension WCAssetReconfigurationTransactionViewController {
    private func bindView() {
        assetReconfigurationTransactionView.bind(
            WCAssetReconfigurationTransactionViewModel(
                transaction: transaction,
                senderAccount: account,
                asset: asset,
                currency: sharedDataController.currency,
                currencyFormatter: currencyFormatter
            )
        )
    }
}

extension WCAssetReconfigurationTransactionViewController: WCAssetReconfigurationTransactionViewDelegate {
    func wcAssetReconfigurationTransactionViewDidOpenRawTransaction(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    ) {
        displayRawTransaction()
    }

    func wcAssetReconfigurationTransactionViewDidOpenAssetURL(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    ) {
        openAssetURL(asset)
    }

    func wcAssetReconfigurationTransactionViewDidOpenPeraExplorer(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    ) {
        openInExplorer(asset)
    }

    func wcAssetReconfigurationTransactionViewDidOpenAssetDiscovery(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    ) {
        openAssetDiscovery(asset)
    }
}

extension WCAssetReconfigurationTransactionViewController: WCSingleTransactionViewControllerAssetManagable { }
