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
//   WCAssetTransactionViewController.swift

import UIKit

class WCAssetTransactionViewController: WCSingleTransactionViewController {

    private lazy var assetTransactionView = WCAssetTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return assetTransactionView
    }

    var assetDetail: AssetDetail?

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-asset".localized
    }

    override func linkInteractors() {
        super.linkInteractors()
        assetTransactionView.delegate = self
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

extension WCAssetTransactionViewController {
    private func bindView() {
        assetTransactionView.bind(
            WCAssetTransactionViewModel(
                transaction: transaction,
                senderAccount: account,
                assetDetail: assetDetail
            )
        )
    }
}

extension WCAssetTransactionViewController: WCAssetTransactionViewDelegate {
    func wcAssetTransactionViewDidOpenRawTransaction(_ wcAssetTransactionView: WCAssetTransactionView) {
        displayRawTransaction()
    }
}

extension WCAssetTransactionViewController: WCSingleTransactionViewControllerAssetManagable { }
