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

//   WalletConnectV1SessionValidator.swift

import Foundation

struct WalletConnectV1SessionValidator: WalletConnectSessionValidator {
    func isValidSession(_ uri: WalletConnectSessionText) -> Bool {
        return hasValidPrefix(uri) && hasValidSessionParams(uri)
    }
}

extension WalletConnectV1SessionValidator {
    private func hasValidPrefix(_ uri: WalletConnectSessionText) -> Bool {
        return uri.hasPrefix(sessionPrefix)
    }
    
    private func hasValidSessionParams(_ uri: WalletConnectSessionText) -> Bool {
        return WalletConnectURL(uri) != nil
    }
}
