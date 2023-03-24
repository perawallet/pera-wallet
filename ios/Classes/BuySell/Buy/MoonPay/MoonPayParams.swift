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

//   MoonPayParams.swift

import Foundation

struct MoonPayParams: Hashable {
    let address: String
    let amount: String?
    let transactionStatus: TransactionStatus
    let transactionId: String

    static var notificationObjectKey = "buy.algo.params"

    enum TransactionStatus: String {
        case completed
        case pending
        case failed
        case waitingPayment
        case waitingAuthorization
    }
}

extension MoonPayParams {
    enum Keys: String {
        case amount = "amount"
        case transactionStatus = "transactionStatus"
        case transactionId = "transactionId"
    }
}
