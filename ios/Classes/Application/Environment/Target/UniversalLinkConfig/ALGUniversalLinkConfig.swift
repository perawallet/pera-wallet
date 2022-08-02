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

//   ALGUniversalLinkConfig.swift

import Foundation

final class ALGUniversalLinkConfig:
    UniversalLinkConfig,
    Decodable {
    let qr: UniversalLinkGroupConfig
    let walletConnect: UniversalLinkGroupConfig
    let url: URL

    private enum CodingKeys:
        String,
        CodingKey {
        case qr
        case walletConnect
        case url
    }

    init(
        qr: UniversalLinkGroupConfig,
        walletConnect: UniversalLinkGroupConfig,
        url: URL
    ) {
        self.qr = qr
        self.walletConnect = walletConnect
        self.url = url
    }

    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.qr = try container.decode(
            ALGUniversalLinkGroupConfig.self,
            forKey: .qr
        )
        self.walletConnect = try container.decode(
            ALGUniversalLinkGroupConfig.self,
            forKey: .walletConnect
        )
        self.url = try container.decode(
            URL.self,
            forKey: .url
        )
    }
}

final class ALGUniversalLinkGroupConfig:
    UniversalLinkGroupConfig,
    Decodable {
    let acceptedPaths: [String]

    init(
        acceptedPaths: [String]
    ) {
        self.acceptedPaths = acceptedPaths
    }
}
