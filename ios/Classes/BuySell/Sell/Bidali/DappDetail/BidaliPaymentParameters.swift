// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BidaliPaymentParameters.swift

import Foundation
import MacaroonUtils

struct BidaliPaymentParameters: JSONModel {
    let data: BidaliPaymentRequest?
}

struct BidaliPaymentRequest: JSONModel {
    /// The address to send to.
    let address: String?
    /// The amount to send.
    let amount: String?
    /// The protocol of the currency the user has chosen to pay with, this is unique for each currency.
    let currencyProtocol: BidaliPaymentCurrencyProtocol?
    /// The extraId that must be passed as a note for the payment to be credited appropriately to the order.
    let extraID: String?

    enum CodingKeys:
        String,
        CodingKey {
        case address
        case amount
        case currencyProtocol = "protocol"
        case extraID = "extraId"
    }
}

enum BidaliPaymentCurrencyProtocol:
    JSONModel,
    CaseIterable {
    case algo
    case usdc
    case usdt
    case unknown(String)

    static var allCases: [BidaliPaymentCurrencyProtocol] = [
        .algo,
        .usdc,
        .usdt
    ]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case Self.algo.getRawValue(in: .mainnet):
            self = .algo
        case Self.usdc.getRawValue(in: .mainnet),
             Self.usdc.getRawValue(in: .testnet):
            self = .usdc
        case Self.usdt.getRawValue(in: .mainnet):
            self = .usdt
        default:
            self = .unknown(rawValue)
        }
    }
}

extension BidaliPaymentCurrencyProtocol {
    func getRawValue(in network: ALGAPI.Network) -> String {
        switch self {
        case .algo: return "algorand"
        case .usdc: return network == .mainnet ? "usdcalgorand" : "testusdcalgorand"
        case .usdt: return "usdtalgorand"
        case .unknown(let rawValue): return rawValue
        }
    }
}
