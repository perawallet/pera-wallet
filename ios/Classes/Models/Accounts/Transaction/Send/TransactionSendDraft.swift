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
//  TransactionSendDraft.swift

import Foundation

protocol TransactionSendDraft {
    var from: Account { get set }
    var toAccount: Account? { get set }
    var amount: Decimal? { get set }
    var fee: UInt64? { get set }
    var isMaxTransaction: Bool { get set }
    var identifier: String? { get set }
    var note: String? { get set }
    var lockedNote: String? { get set }
    var toContact: Contact? { get set }
    var toNameService: NameService? { get set }
}

extension TransactionSendDraft {
    mutating func updateNote(_ note: String?) {
        self.note = note
    }
}
