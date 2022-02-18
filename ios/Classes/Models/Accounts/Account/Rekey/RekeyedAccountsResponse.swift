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
//  RekeyedAccountsResponse.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class RekeyedAccountsResponse: ALGEntityModel {
    let accounts: [Account]
    let currentRound: UInt64
    let nextToken: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.accounts = apiModel.accounts.unwrapMap(Account.init)
        self.currentRound = apiModel.currentRound ?? 12345
        self.nextToken = apiModel.nextToken
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.accounts = accounts.encode()
        apiModel.currentRound = currentRound
        apiModel.nextToken = nextToken
        return apiModel
    }
}

extension RekeyedAccountsResponse {
    struct APIModel: ALGAPIModel {
        var accounts: [Account.APIModel]?
        var currentRound: UInt64?
        var nextToken: String?

        init() {
            self.accounts = []
            self.currentRound = nil
            self.nextToken = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case accounts
        case currentRound = "current-round"
        case nextToken = "next-token"
    }
}
