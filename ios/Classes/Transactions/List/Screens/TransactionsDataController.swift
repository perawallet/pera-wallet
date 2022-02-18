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
//   TransactionsDataController.swift

import Foundation
import UIKit

protocol TransactionsDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<TransactionsSection, TransactionsItem>

    var eventHandler: ((TransactionsDataControllerEvent) -> Void)? { get set }

    func load()
    func startPendingTransactionPolling()
    func stopPendingTransactionPolling()
    func loadContacts()
    func loadTransactions()
    func loadNextTransactions()
}

enum TransactionsSection:
    Int,
    Hashable {
    case info
    case transactionHistory
    case nextList
    case empty
}

enum TransactionsItem: Hashable {
    case algosInfo(AlgosDetailInfoViewModel)
    case assetInfo(AssetDetailInfoViewModel)
    case filter(TransactionHistoryFilterViewModel)
    case transaction(TransactionHistoryContextViewModel)
    case pending(TransactionHistoryContextViewModel)
    case reward(TransactionHistoryContextViewModel)
    case title(TransactionHistoryTitleContextViewModel)
    case empty(EmptyState)
    case nextList
}

enum EmptyState: Hashable {
    case noContent
    case loading
    case transactionHistoryLoading
    case algoTransactionHistoryLoading
    case assetTransactionHistoryLoading
}

enum TransactionsDataControllerEvent {
    case didUpdate(TransactionsDataController.Snapshot)
}
