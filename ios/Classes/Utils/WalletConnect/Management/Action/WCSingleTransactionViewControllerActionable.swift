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
//   WCSingleTransactionViewControllerActionable.swift

import Foundation

protocol WCSingleTransactionViewControllerActionable: AnyObject {
    func displayRawTransaction()
}

extension WCSingleTransactionViewControllerActionable where Self: WCSingleTransactionViewController {
    func displayRawTransaction() {
        guard let transationDetail = transaction.transactionDetail,
              let transactionData = try? JSONEncoder().encode(transationDetail),
              let object = try? JSONSerialization.jsonObject(with: transactionData, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else {
            return
        }

        open(.jsonDisplay(jsonData: data, title: "wallet-connect-raw-transaction-title".localized), by: .present)
    }
}
