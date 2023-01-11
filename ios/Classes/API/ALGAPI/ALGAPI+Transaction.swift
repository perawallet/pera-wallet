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
//  API+Transaction.swift

import Foundation
import MagpieCore
import MagpieExceptions
import SwiftDate

extension ALGAPI {
    @discardableResult
    func fetchTransactions(
        _ draft: TransactionFetchDraft,
        onCompleted handler: @escaping (Response.ModelResult<TransactionList>) -> Void
    ) -> EndpointOperatable {
        var from: String?
        var to: String?
        
        if let fromDate = draft.dates.from,
            let toDate = draft.dates.to {
            from = "\(fromDate.toFormat("yyyy-MM-dd"))T00:00:00.000Z"
            to = "\(toDate.toFormat("yyyy-MM-dd"))T23:59:59.000Z"
        }

        let transactionType = draft.transactionType?.rawValue
        
        return EndpointBuilder(api: self)
            .base(.indexer(network))
            .path(.accountTransaction, args: draft.account.address)
            .method(.get)
            .query(TransactionsQuery(limit: draft.limit, from: from, to: to, next: draft.nextToken, assetId: draft.assetId, transactionType: transactionType))
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func sendTransaction(
        _ transactionData: Data,
        onCompleted handler: @escaping (Response.Result<TransactionID, IndexerError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.transactions)
            .method(.post)
            .type(.upload(.data(transactionData)))
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func getTransactionParams(
        onCompleted handler: @escaping (Response.ModelResult<TransactionParams>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.transactionParams)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func trackTransaction(_ draft: TransactionTrackDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.trackTransactions)
            .method(.post)
            .body(draft)
            .execute()
    }

    @discardableResult
    func fetchPendingTransactions(
        _ address: String,
        onCompleted handler: @escaping (Response.ModelResult<PendingTransactionList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.pendingAccountTransactions, args: address)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func getPendingTransaction(
        _ id: TxnID,
        onCompleted handler: @escaping ( Response.Result<PendingTransaction, IndexerError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.pendingTransaction, args: id)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
}

extension ALGAPI {
    @discardableResult
    func exportTransactions(
        draft: ExportTransactionsDraft,
        onCompleted handler: @escaping (Response.DownloadResult<CSVFile, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .type(.download(.file(draft.fileURL)))
            .base(.mobileV1(network))
            .path(.exportTransactions, args: draft.account.address)
            .method(.get)
            .query(draft)
            .completionHandler(handler)
            .execute()
    }
}

extension ALGAPI {
    private enum Formatter {
        static let date: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()
    }
}
