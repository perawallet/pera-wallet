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

//   WalletConnectV2SessionValidator.swift

import Foundation

struct WalletConnectV2SessionValidator: WalletConnectSessionValidator {
    func isValidSession(_ uri: WalletConnectSessionText) -> Bool {
        if !uri.hasPrefix(sessionPrefix) {
            return false
        }
        
        let formettedURI = formatSessionURIIfNeeded(uri)
        
        guard let sessionURL = URL(string: formettedURI),
              let queryParameters = sessionURL.queryParameters else {
            return false
        }
        
        return hasValidQueryParameters(queryParameters)
    }
}

extension WalletConnectV2SessionValidator {
    private func formatSessionURIIfNeeded(_ uri: WalletConnectSessionText) -> String {
        let properURIString: String
        if uri.starts(with: "") {
            properURIString = uri
        } else if uri.starts(with: "\(sessionPrefix)/") {
            properURIString = uri.replacingOccurrences(
                of: "\(sessionPrefix)/",
                with: "\(sessionPrefix)//"
            )
        } else {
            properURIString = uri.replacingOccurrences(
                of: "\(sessionPrefix)",
                with: "\(sessionPrefix)//"
            )
        }
        
        return properURIString
    }
    
    private func hasValidQueryParameters(_ queryParameters: [String: String]) -> Bool {
        return containsSessionRelayProtocol(on: queryParameters) && containsSessionSymKey(on: queryParameters)
    }
    
    private func containsSessionRelayProtocol(on queryParameters: [String: String]) -> Bool {
        return queryParameters["relay-protocol"] != nil
    }
    
    private func containsSessionSymKey(on queryParameters: [String: String]) -> Bool {
        return queryParameters["symKey"] != nil
    }
}
