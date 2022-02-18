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
//   WCAssetDeletionTransactionViewController.swift

import UIKit

class WCAssetDeletionTransactionViewController: WCSingleTransactionViewController {
    
    private lazy var assetDeletionTransactionView = WCAssetDeletionTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return assetDeletionTransactionView
    }

    var assetDetail: AssetDetail?

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-asset-deletion-title".localized
    }

    override func linkInteractors() {
        super.linkInteractors()
        assetDeletionTransactionView.delegate = self
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

extension WCAssetDeletionTransactionViewController {
    private func bindView() {
        assetDeletionTransactionView.bind(
            WCAssetDeletionTransactionViewModel(
                transaction: transaction,
                senderAccount: account,
                assetDetail: assetDetail
            )
        )
    }
}

extension WCAssetDeletionTransactionViewController: WCAssetDeletionTransactionViewDelegate {
    func wcAssetDeletionTransactionViewDidOpenRawTransaction(_ wcAssetDeletionTransactionView: WCAssetDeletionTransactionView) {
        displayRawTransaction()
    }

    func wcAssetDeletionTransactionViewDidOpenAlgoExplorer(_ wcAssetDeletionTransactionView: WCAssetDeletionTransactionView) {
        openInExplorer(assetDetail)
    }
}

extension WCAssetDeletionTransactionViewController: WCSingleTransactionViewControllerAssetManagable { }
