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
//   WalletConnectResponse+Helpers.swift

import Foundation

extension WalletConnectResponse {
    static func signature(_ signature: [Data?], for request: WalletConnectRequest) -> WalletConnectResponse? {
        guard let id = request.id else {
            return nil
        }

        return try? WalletConnectResponse(url: request.url, value: signature, id: id)
    }

    static func rejection(_ request: WalletConnectRequest, with error: WCTransactionErrorResponse) -> WalletConnectResponse? {
        return try? WalletConnectResponse(url: request.url, errorCode: error.rawValue, message: error.message, id: request.id)
    }
}
