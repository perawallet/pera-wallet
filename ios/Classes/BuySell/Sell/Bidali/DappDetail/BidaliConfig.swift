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

//   BidaliConfig.swift

import Foundation

struct BidaliConfig {
    let key: String

    /// The name of the wallet integrating (Provided by Bidali).
    let name: String

    let url: String

    /// Allows you to only show certain cryptocurrencies as payment options.
    let supportedCurrencyProtocols: [String]

    init(network: ALGAPI.Network) {
        self.name = "perawallet"

        switch network {
        case .testnet:
            let key = Bundle.main.infoDictionary?["BIDALI_STAGING_API_KEY"] as? String ?? .empty
            self.key = key
            self.url = "https://commerce.staging.bidali.com/dapp?key=\(key)"
            self.supportedCurrencyProtocols = [
                BidaliPaymentCurrencyProtocol.algo.getRawValue(in: network),
                BidaliPaymentCurrencyProtocol.usdc.getRawValue(in: network)
            ]
        case .mainnet, .localnet:
            let key = Bundle.main.infoDictionary?["BIDALI_PROD_API_KEY"] as? String ?? .empty
            self.key = key
            self.url = "https://commerce.bidali.com/dapp?key=\(key)"
            self.supportedCurrencyProtocols = [
                BidaliPaymentCurrencyProtocol.algo.getRawValue(in: network),
                BidaliPaymentCurrencyProtocol.usdc.getRawValue(in: network),
                BidaliPaymentCurrencyProtocol.usdt.getRawValue(in: network)
            ]
        }
    }
}
