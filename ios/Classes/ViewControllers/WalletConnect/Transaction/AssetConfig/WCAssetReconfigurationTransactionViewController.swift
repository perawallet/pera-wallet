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
//   WCAssetReconfigurationTransactionViewController.swift

import UIKit

class WCAssetReconfigurationTransactionViewController: WCSingleTransactionViewController {

    private lazy var assetReconfigurationTransactionView = WCAssetReconfigurationTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return assetReconfigurationTransactionView
    }

    var assetDetail: AssetDetail?

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
            if self.assetDetail == nil {
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
                assetDetail: assetDetail
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
        openAssetURL(assetDetail)
    }

    func wcAssetReconfigurationTransactionViewDidOpenAlgoExplorer(
        _ wcAssetReconfigurationTransactionView: WCAssetReconfigurationTransactionView
    ) {
        openInExplorer(assetDetail)
    }
}

extension WCAssetReconfigurationTransactionViewController: WCSingleTransactionViewControllerAssetManagable { }
