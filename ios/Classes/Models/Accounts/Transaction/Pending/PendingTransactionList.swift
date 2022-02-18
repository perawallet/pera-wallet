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
//  PendingTransactionList.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class PendingTransactionList: ALGEntityModel {
    var pendingTransactions: [PendingTransaction]
    var count: Int

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.pendingTransactions = apiModel.topTransactions.unwrapMap(PendingTransaction.init)
        self.count = apiModel.totalTransactions ?? 0
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.topTransactions = pendingTransactions.map { $0.encode() }
        apiModel.totalTransactions = count
        return apiModel
    }
}

extension PendingTransactionList {
    struct APIModel: ALGAPIModel {
        var topTransactions: [PendingTransaction.APIModel]?
        var totalTransactions: Int?

        init() {
            self.topTransactions = []
            self.totalTransactions = nil
        }

        private enum CodingKeys: String, CodingKey {
            case topTransactions = "top-transactions"
            case totalTransactions = "total-transactions"
        }
    }
}
