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
//  Account.swift

import Magpie

class Account: Model {
    let address: String
    var amount: UInt64
    var amountWithoutRewards: UInt64
    var rewardsBase: UInt64?
    var round: UInt64?
    var signatureType: SignatureType?
    var status: AccountStatus
    var rewards: UInt64?
    var pendingRewards: UInt64
    var participation: Participation?
    var createdAssets: [AssetDetail]?
    var assets: [Asset]?
    var authAddress: String?
    var createdRound: Int64?
    var closedRound: Int64?
    var isDeleted: Bool?
    
    var assetDetails: [AssetDetail] = []
    var name: String?
    var type: AccountType = .standard
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try container.decode(String.self, forKey: .address)
        amount = try container.decode(UInt64.self, forKey: .amount)
        amountWithoutRewards = try container.decodeIfPresent(UInt64.self, forKey: .amountWithoutRewards) ?? 0
        rewardsBase = try container.decodeIfPresent(UInt64.self, forKey: .rewardsBase)
        round = try container.decodeIfPresent(UInt64.self, forKey: .round)
        signatureType = try container.decodeIfPresent(SignatureType.self, forKey: .signatureType)
        status = try container.decode(AccountStatus.self, forKey: .status)
        rewards = try container.decodeIfPresent(UInt64.self, forKey: .rewards)
        pendingRewards = try container.decodeIfPresent(UInt64.self, forKey: .pendingRewards) ?? 0
        participation = try container.decodeIfPresent(Participation.self, forKey: .participation)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        createdAssets = try? container.decodeIfPresent([AssetDetail].self, forKey: .createdAssets)
        assets = try? container.decodeIfPresent([Asset].self, forKey: .assets) ?? nil
        assetDetails = try container.decodeIfPresent([AssetDetail].self, forKey: .assetDetails) ?? []
        type = try container.decodeIfPresent(AccountType.self, forKey: .type) ?? .standard
        authAddress = try container.decodeIfPresent(String.self, forKey: .authAddress)
        ledgerDetail = try container.decodeIfPresent(LedgerDetail.self, forKey: .ledgerDetail)
        receivesNotification = try container.decodeIfPresent(Bool.self, forKey: .receivesNotification) ?? true
        rekeyDetail = try container.decodeIfPresent(RekeyDetail.self, forKey: .rekeyDetail)
        createdRound = try container.decodeIfPresent(Int64.self, forKey: .createdRound)
        closedRound = try container.decodeIfPresent(Int64.self, forKey: .closedRound)
        isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
    }
    
    init(
        address: String,
        type: AccountType,
        ledgerDetail: LedgerDetail? = nil,
        name: String? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true
    ) {
        self.address = address
        amount = 0
        amountWithoutRewards = 0
        pendingRewards = 0
        status = .offline
        self.name = name
        self.type = type
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
    }
    
    init(accountInformation: AccountInformation) {
        self.address = accountInformation.address
        self.amount = 0
        self.amountWithoutRewards = 0
        self.pendingRewards = 0
        self.status = .offline
        self.name = accountInformation.name
        self.type = accountInformation.type
        self.ledgerDetail = accountInformation.ledgerDetail
        self.receivesNotification = accountInformation.receivesNotification
        self.rekeyDetail = accountInformation.rekeyDetail
    }
}

extension Account {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case amount = "amount"
        case status = "status"
        case rewards = "rewards"
        case amountWithoutRewards = "amount-without-pending-rewards"
        case pendingRewards = "pending-rewards"
        case rewardsBase = "reward-base"
        case name = "name"
        case participation = "participation"
        case createdAssets = "created-assets"
        case assets = "assets"
        case assetDetails = "assetDetails"
        case type = "type"
        case ledgerDetail = "ledgerDetail"
        case signatureType = "sig-type"
        case round = "round"
        case authAddress = "auth-addr"
        case receivesNotification = "receivesNotification"
        case rekeyDetail = "rekeyDetail"
        case createdRound = "created-at-round"
        case closedRound = "closed-at-round"
        case isDeleted = "deleted"
    }
}

extension Account: Encodable {
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address == rhs.address
    }
}

extension Account: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(address.hashValue)
    }
}
