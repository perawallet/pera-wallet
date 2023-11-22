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

//   WCTransactionRequestSDKErrorLog.swift

import Foundation

struct WCTransactionRequestSDKErrorLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        error: Error?,
        url: WalletConnectURL
    ) {
        self.name = .walletConnectTransactionRequestSDKError
        
        var metadata: ALGAnalyticsMetadata = [
            .wcVersion: WalletConnectProtocolID.v1.rawValue,
            .wcRequestURL: Self.regulate(url.absoluteString)
        ]
        if let error {
            metadata[.wcRequestError] = Self.regulate(error.localizedDescription)
        }
        self.metadata = metadata
    }
}

extension ALGAnalyticsLog where Self == WCTransactionRequestSDKErrorLog {
    static func wcTransactionRequestSDKError(
        error: Error?,
        url: WalletConnectURL
    ) -> Self {
        return WCTransactionRequestSDKErrorLog(
            error: error,
            url: url
        )
    }
}
