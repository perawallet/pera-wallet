// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCMainArbitraryDataDataSource.swift

import Foundation
import UIKit

final class WCMainArbitraryDataDataSource: NSObject {
    let wcSession: WCSessionDraft

    private let sharedDataController: SharedDataController
    private let data: [WCArbitraryData]
    private let wcRequest: WalletConnectRequestDraft
    private let peraConnect: PeraConnect
    private let currencyFormatter: CurrencyFormatter

    init(
        sharedDataController: SharedDataController,
        data: [WCArbitraryData],
        wcSession: WCSessionDraft,
        wcRequest: WalletConnectRequestDraft,
        peraConnect: PeraConnect,
        currencyFormatter: CurrencyFormatter
    ) {
        self.sharedDataController = sharedDataController
        self.data = data
        self.wcSession = wcSession
        self.wcRequest = wcRequest
        self.peraConnect = peraConnect
        self.currencyFormatter = currencyFormatter

        super.init()
    }
}

extension WCMainArbitraryDataDataSource {
    func rejectTransaction(reason: WCTransactionErrorResponse = .rejected(.user)) {
        if let wcV1TransactionRequest = wcRequest.wcV1Request {
            let params = WalletConnectV1RejectTransactionRequestParams(
                v1Request: wcV1TransactionRequest,
                error: reason
            )
            peraConnect.rejectTransactionRequest(params)
            return
        }

        if let wcV2TransactionRequest = wcRequest.wcV2Request {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: reason,
                v2Request: wcV2TransactionRequest
            )
            peraConnect.rejectTransactionRequest(params)
            return
        }
    }

    func signTransactionRequest(signature: [Data?]) {
        if let wcV1TransactionRequest = wcRequest.wcV1Request {
            let params = WalletConnectV1ApproveTransactionRequestParams(
                v1Request: wcV1TransactionRequest,
                signature: signature
            )
            peraConnect.approveTransactionRequest(params)
            return
        }

        if let wcV2TransactionRequest = wcRequest.wcV2Request {
            let params = WalletConnectV2ApproveTransactionRequestParams(
                v2Request: wcV2TransactionRequest,
                response: WalletConnectV2CodableResult(signature)
            )
            peraConnect.approveTransactionRequest(params)
            return
        }
    }
}

extension WCMainArbitraryDataDataSource: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let data = data[safe: indexPath.item] else {
            fatalError("Unexpected index")
        }

        let account = data.requestedSigner.account
        return dequeueSingleSignerCell(
            in: collectionView,
            at: indexPath,
            for: data,
            with: account
        )
    }
}

extension WCMainArbitraryDataDataSource {
    private func dequeueSingleSignerCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCArbitraryData,
        with account: Account?
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCGroupTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCGroupTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        let viewModel = WCGroupTransactionItemViewModel(
            account: account,
            currencyFormatter: currencyFormatter
        )
        cell.bind(viewModel)
        return cell
    }
}

extension WCMainArbitraryDataDataSource {
    func data(at index: Int) -> WCArbitraryData? {
        return data[safe: index]
    }
}
