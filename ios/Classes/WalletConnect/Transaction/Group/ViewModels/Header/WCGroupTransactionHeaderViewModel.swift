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
//   WCGroupTransactionHeaderViewModel.swift

import UIKit

final class WCGroupTransactionHeaderViewModel {
    private(set) var title: String?
    private(set) var groupID: String?

    init(transactions: [WCTransaction]) {
        setGroupID(from: transactions)
    }

    private func setGroupID(from transactions: [WCTransaction]) {
        guard let groupID = transactions.first?.transactionDetail?.transactionGroupId else {
            return
        }

        self.groupID = "wallet-connect-group-transaction-header-title".localized(params: groupID)
    }
}
