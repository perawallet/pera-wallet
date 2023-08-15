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

//   TransakConfig.swift

import Foundation

struct TransakConfig {
    let url: String

    init(
        account: AccountHandle,
        network: ALGAPI.Network
    ) {
        let address = account.value.address
        switch network {
        case .testnet:
            let key = Bundle.main.infoDictionary?["TRANSAK_STAGING_API_KEY"] as? String ?? .empty
            self.url = "https://global-stg.transak.com/?apiKey=\(key)&defaultCryptoCurrency=USDC&networks=algorand,mainnet&cryptoCurrencyList=ALGO,USDC&walletAddress=\(address)"
        case .mainnet:
            let key = Bundle.main.infoDictionary?["TRANSAK_PROD_API_KEY"] as? String ?? .empty
            self.url =  "https://global.transak.com/?apiKey=\(key)&defaultCryptoCurrency=USDC&networks=algorand,mainnet&cryptoCurrencyList=ALGO,USDC&walletAddress=\(address)"
        }
    }
}
