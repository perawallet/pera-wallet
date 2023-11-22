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

//   WCTransactionRequestDidLoadLog.swift

import Foundation

struct WCTransactionRequestDidLoadLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        transactionRequest: WalletConnectRequest
    ) {
        self.name = .walletConnectTransactionRequestDidLoad
        self.metadata = [
            .wcVersion: WalletConnectProtocolID.v1.rawValue,
            .wcRequestID: transactionRequest.id.unwrap(or: ""),
            .wcRequestURL: Self.regulate(transactionRequest.url.absoluteString)
        ]
    }

    fileprivate init(
        transactionRequest: WalletConnectV2Request
    ) {
        self.name = .walletConnectTransactionRequestDidLoad
        self.metadata = [
            .wcVersion: WalletConnectProtocolID.v2.rawValue,
            .wcSessionTopic: transactionRequest.topic,
            .wcRequestID: transactionRequest.id.string
        ]
    }
}

extension ALGAnalyticsLog where Self == WCTransactionRequestDidLoadLog {
    static func wcTransactionRequestDidLoad(
        transactionRequest: WalletConnectRequestDraft
    ) -> Self {
        if let wcV1Request = transactionRequest.wcV1Request {
            return .wcTransactionRequestDidLoad(transactionRequest: wcV1Request)
        }

        return .wcTransactionRequestDidLoad(transactionRequest: transactionRequest.wcV2Request!)
    }

    static func wcTransactionRequestDidLoad(
        transactionRequest: WalletConnectRequest
    ) -> Self {
        return WCTransactionRequestDidLoadLog(
            transactionRequest: transactionRequest
        )
    }

    static func wcTransactionRequestDidLoad(
        transactionRequest: WalletConnectV2Request
    ) -> Self {
        return WCTransactionRequestDidLoadLog(
            transactionRequest: transactionRequest
        )
    }
}
