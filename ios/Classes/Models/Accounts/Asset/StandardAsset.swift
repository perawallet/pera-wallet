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

//   StandardAsset.swift

import Foundation

final class StandardAsset: Asset {
    let id: AssetID
    let amount: UInt64
    let decimals: Int
    let decimalAmount: Decimal
    let total: UInt64?
    let totalSupply: Decimal?
    let isFrozen: Bool?
    let isDestroyed: Bool
    let optedInAtRound: UInt64?
    let name: String?
    let unitName: String?
    let usdValue: Decimal?
    let totalUSDValue: Decimal?
    let verificationTier: AssetVerificationTier
    let creator: AssetCreator?
    let url: String?
    let projectURL: URL?
    let explorerURL: URL?
    let logoURL: URL?
    let description: String?
    let discordURL: URL?
    let telegramURL: URL?
    let twitterURL: URL?
    let isAlgo = false
    let algoPriceChangePercentage: Decimal
    let isAvailableOnDiscover: Bool

    let isFault: Bool

    var state: AssetState = .ready

    var naming: AssetNaming {
        return AssetNaming(
            id: id,
            name: name,
            unitName: unitName
        )
    }

    var amountWithFraction: Decimal {
        return amount.assetAmount(fromFraction: decimals)
    }

    init(
        asset: ALGAsset,
        decoration: AssetDecoration
    ) {
        self.id = asset.id
        self.isFrozen = asset.isFrozen
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = asset.optedInAtRound
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.verificationTier = decoration.verificationTier
        self.creator = decoration.creator
        self.url = decoration.url
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply

        let amount = asset.amount
        let decimals = decoration.decimals
        /// <note>
        /// decimalAmount = amount * 10^-(decimals)
        let decimalAmount = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(amount))
        let usdValue = decoration.usdValue

        self.amount = amount
        self.decimals = decimals
        self.decimalAmount = decimalAmount
        self.usdValue = usdValue
        self.totalUSDValue = usdValue.unwrap { $0 * decimalAmount }
        self.description = decoration.description
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL
        self.isFault = false
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
    }

    init(
        decoration: AssetDecoration
    ) {
        self.id = decoration.id
        self.isFrozen = nil
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = nil
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.verificationTier = decoration.verificationTier
        self.creator = decoration.creator
        self.url = decoration.url
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply
        self.amount = 0
        self.decimals = decoration.decimals
        self.decimalAmount = 0
        self.usdValue = decoration.usdValue
        self.totalUSDValue = nil
        self.description = decoration.description
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL
        self.isFault = true
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
    }
}

extension StandardAsset {
    var assetNameRepresentation: String {
        if let name = name,
           !name.isEmptyOrBlank {
            return name
        }

        return "title-unknown".localized
    }

    var unitNameRepresentation: String {
        if let code = unitName,
            !code.isEmptyOrBlank {
            return code.uppercased()
        }

        return "title-unknown".localized
    }

    var hasDisplayName: Bool {
        return !name.isNilOrEmpty || !unitName.isNilOrEmpty
    }
}

extension StandardAsset: Comparable {
    static func == (lhs: StandardAsset, rhs: StandardAsset) -> Bool {
        return lhs.id == rhs.id &&
            lhs.amount == rhs.amount &&
            lhs.isFrozen == rhs.isFrozen &&
            lhs.isDestroyed == rhs.isDestroyed &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.decimals == rhs.decimals &&
            lhs.usdValue == rhs.usdValue &&
            lhs.verificationTier == rhs.verificationTier &&
            lhs.optedInAtRound == rhs.optedInAtRound
    }

    static func < (lhs: StandardAsset, rhs: StandardAsset) -> Bool {
        return lhs.id < rhs.id
    }
}

extension StandardAsset: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
