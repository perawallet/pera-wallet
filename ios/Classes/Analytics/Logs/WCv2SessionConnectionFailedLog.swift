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

//   WCv2SessionConnectionFailedLog.swift

import Foundation

struct WCv2SessionConnectionFailedLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        uri: WalletConnectV2URI,
        error: Error
    ) {
        self.name = .walletConnectV2SessionConnectionFailed
        self.metadata = [
            .wcSessionTopic: uri.topic,
            .wcRequestURL: Self.regulate(uri.absoluteString),
            .wcRequestError: Self.regulate(error.localizedDescription)
        ]
    }
}

extension ALGAnalyticsLog where Self == WCv2SessionConnectionFailedLog {
    static func wcV2SessionConnectionFailedLog(
        uri: WalletConnectV2URI,
        error: Error
    ) -> Self {
        return WCv2SessionConnectionFailedLog(
            uri: uri,
            error: error
        )
    }
}
