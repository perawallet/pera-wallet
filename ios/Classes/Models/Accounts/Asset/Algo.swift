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

//   Algo.swift

import Foundation

final class Algo: Asset {
    let id: AssetID = 0
    var amount: UInt64
    let isFrozen: Bool? = nil
    let isDestroyed: Bool = false
    let optedInAtRound: UInt64? = nil
    let creator: AssetCreator? = nil
    let decimals: Int = 6
    let decimalAmount: Decimal
    let total: UInt64?
    let totalSupply: Decimal?
    let usdValue: Decimal? = nil
    let totalUSDValue: Decimal? = nil
    var state: AssetState = .ready
    let url: String? = AlgorandWeb.algorand.rawValue
    let verificationTier: AssetVerificationTier = .trusted
    let projectURL: URL?
    let explorerURL: URL? = nil
    let logoURL: URL? = nil
    let description: String?
    let discordURL: URL?
    let telegramURL: URL?
    let twitterURL: URL?
    let algoPriceChangePercentage: Decimal = 0
    let isAvailableOnDiscover: Bool = true

    let naming: AssetNaming = AssetNaming(
        id: 0,
        name: "Algo",
        unitName: "ALGO"
    )
    let amountWithFraction: Decimal = 0
    let isAlgo = true
    let isFault = false

    init(
        amount: UInt64
    ) {
        self.amount = amount
        /// <note>
        /// decimalAmount = amount * 10^-(decimals)
        self.decimalAmount = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(amount))

        /// microTotalSupply
        let total: UInt64 = 10_000_000_000_000_000
        self.total = total
        /// totalSupply = total * 10^-(decimals)
        self.totalSupply = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(total))
        self.description = "asset-algos-description".localized
        self.projectURL = AlgorandWeb.algorand.link
        self.discordURL = URL(string: "https://discord.com/invite/algorand")
        self.telegramURL = URL(string: "https://t.me/algorand")
        self.twitterURL = URL.twitterURL(username: "Algorand")
    }
}
