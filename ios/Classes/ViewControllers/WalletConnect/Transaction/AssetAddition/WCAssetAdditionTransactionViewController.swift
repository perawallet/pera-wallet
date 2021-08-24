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
//   WCAssetAdditionTransactionViewController.swift

import UIKit

class WCAssetAdditionTransactionViewController: WCSingleTransactionViewController {

    private lazy var assetAdditionTransactionView = WCAssetAdditionTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return assetAdditionTransactionView
    }

    var assetDetail: AssetDetail?

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-opt-in".localized
    }

    override func linkInteractors() {
        super.linkInteractors()
        assetAdditionTransactionView.delegate = self
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

extension WCAssetAdditionTransactionViewController {
    private func bindView() {
        assetAdditionTransactionView.bind(
            WCAssetAdditionTransactionViewModel(
                transaction: transaction,
                senderAccount: account,
                assetDetail: assetDetail)
        )
    }
}

extension WCAssetAdditionTransactionViewController: WCAssetAdditionTransactionViewDelegate {
    func wcAssetAdditionTransactionViewDidOpenRawTransaction(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {
        displayRawTransaction()
    }

    func wcAssetAdditionTransactionViewDidOpenAlgoExplorer(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {
        openInExplorer(assetDetail)
    }

    func wcAssetAdditionTransactionViewDidOpenAssetURL(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {
        openAssetURL(assetDetail)
    }

    func wcAssetAdditionTransactionViewDidOpenAssetMetadata(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {
        displayAssetMetadata(assetDetail)
    }
}

extension WCAssetAdditionTransactionViewController: WCSingleTransactionViewControllerAssetManagable { }
