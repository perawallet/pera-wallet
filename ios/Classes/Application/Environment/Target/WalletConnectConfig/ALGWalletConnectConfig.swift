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

//   ALGWalletConnectConfig.swift

import Foundation

final class ALGWalletConnectConfig:
    WalletConnectConfig,
    Decodable {
    let meta: WalletConnectMetaConfig
    
    private enum CodingKeys:
        String,
        CodingKey {
        case meta
    }
    
    init(
        meta: WalletConnectMetaConfig
    ) {
        self.meta = meta
    }
    
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.meta = try container.decode(
            ALGWalletConnectMetaConfig.self,
            forKey: .meta
        )
    }
}

final class ALGWalletConnectMetaConfig:
    WalletConnectMetaConfig,
    Decodable {
    let name: String
    let description: String
    let icons: [URL]
    let url: URL
    
    init(
        name: String,
        description: String,
        icons: [URL],
        url: URL
    ) {
        self.name = name
        self.description = description
        self.icons = icons
        self.url = url
    }
}
