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

//   WCArbitraryData.swift

import Foundation

final class WCArbitraryData:
    Codable,
    Equatable {
    let chainID: Int?
    let data: Data?
    let message: String?
    let signer: String?

    private(set) var requestedSigner = WCTransactionRequestedSigner()

    private let id = UUID()

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chainID = try container.decodeIfPresent(Int.self, forKey: .chaindID)
        data = try container.decodeIfPresent(Data.self, forKey: .data)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        signer = try container.decodeIfPresent(String.self, forKey: .signer)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(chainID, forKey: .chaindID)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(signer, forKey: .signer)
    }
}

extension WCArbitraryData {
    private enum CodingKeys:
        String,
        CodingKey {
        case chaindID = "chainId"
        case data = "data"
        case message = "message"
        case signer = "signer"
    }
}

extension WCArbitraryData {
    static func == (
        lhs: WCArbitraryData,
        rhs: WCArbitraryData
    ) -> Bool {
        return lhs.id == rhs.id
    }
}

extension WCArbitraryData {
    func findSignerAccount(
        in accountCollection: AccountCollection,
        on session: Session
    ) {
        guard let signer else { return }

        requestedSigner.findSignerAccount(
            signer: signer,
            in: accountCollection,
            on: session
        )
    }
}
