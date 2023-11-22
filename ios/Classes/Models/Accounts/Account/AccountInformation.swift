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
//  AccountInformation.swift

import Foundation
import UIKit

typealias PublicKey = String
typealias RekeyDetail = [PublicKey: LedgerDetail]

final class AccountInformation: Codable {
    let address: String
    var name: String
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?
    var preferredOrder: Int
    var isBackedUp: Bool

    static let invalidOrder = -1

    var isWatchAccount: Bool {
        get {
            return type == .watch
        }
        set {
            type = newValue ? .watch : .standard
        }
    }

    private var type: AccountType
    
    init(
        address: String,
        name: String,
        isWatchAccount: Bool,
        ledgerDetail: LedgerDetail? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true,
        preferredOrder: Int? = nil,
        isBackedUp: Bool
    ) {
        self.address = address
        self.name = name
        self.type = isWatchAccount ? .watch : .standard
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
        self.preferredOrder = preferredOrder ?? Self.invalidOrder
        self.isBackedUp = isBackedUp
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decodeIfPresent(AccountType.self, forKey: .type) ?? .standard
        ledgerDetail = try container.decodeIfPresent(LedgerDetail.self, forKey: .ledgerDetail)
        receivesNotification = try container.decodeIfPresent(Bool.self, forKey: .receivesNotification) ?? true
        rekeyDetail = try container.decodeIfPresent(RekeyDetail.self, forKey: .rekeyDetail)
        preferredOrder = try container.decodeIfPresent(Int.self, forKey: .preferredOrder) ?? Self.invalidOrder
        isBackedUp = try container.decodeIfPresent(Bool.self, forKey: .isBackedUp) ?? true
    }
}

extension AccountInformation {
    func updateName(_ name: String) {
        self.name = name
    }
    
    func addRekeyDetail(_ ledgerDetail: LedgerDetail, for address: String) {
        if rekeyDetail != nil {
            self.rekeyDetail?[address] = ledgerDetail
        } else {
            self.rekeyDetail = [address: ledgerDetail]
        }
    }

    func addRekeyDetail(_ rekeyDetail: RekeyDetail, for address: String) {
        if self.rekeyDetail != nil {
            self.rekeyDetail?[address] = rekeyDetail[address]
        } else {
            self.rekeyDetail = rekeyDetail
        }
    }
}

extension AccountInformation {
    enum AccountType:
        String,
        Codable {
        case standard = "standard"
        case watch = "watch"
        case ledger = "ledger"
        case rekeyed = "rekeyed"
    }
}

extension AccountInformation {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case name = "name"
        case type = "type"
        case ledgerDetail = "ledgerDetail"
        case receivesNotification = "receivesNotification"
        case rekeyDetail = "rekeyDetail"
        case preferredOrder = "preferredOrder"
        case isBackedUp = "isBackedUp"
    }
}

extension AccountInformation: Hashable {
    static func == (lhs: AccountInformation, rhs: AccountInformation) -> Bool {
        return lhs.address == rhs.address
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}
