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
//   WCMultipleTransactionItemViewModel.swift

import Foundation

class WCMultipleTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var detail: String?

    init(transactions: [WCTransaction]) {
        setHasWarning(from: transactions)
        setDetail(from: transactions)
    }

    private func setHasWarning(from transactions: [WCTransaction]) {
        hasWarning = transactions.contains { $0.transactionDetail?.hasRekeyOrCloseAddress ?? false }
    }

    private func setDetail(from transactions: [WCTransaction]) {
        detail = transactions.count == 1 ?
            "wallet-connect-transaction-count-singular".localized :
            "wallet-connect-transaction-count".localized(params: transactions.count)
    }
}
