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

//   WCv2SessionConnectionRejectionFailedLog.swift

import Foundation

struct WCv2SessionConnectionRejectionFailedLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        proposalID: String,
        error: Error
    ) {
        self.name = .walletConnectV2SessionConnectionRejectionFailed
        self.metadata = [
            .wcV2SessionProposalID: proposalID,
            .wcRequestError: Self.regulate(error.localizedDescription)
        ]
    }
}

extension ALGAnalyticsLog where Self == WCv2SessionConnectionRejectionFailedLog {
    static func wcV2SessionConnectionRejectionFailedLog(
        proposalID: String,
        error: Error
    ) -> Self {
        return WCv2SessionConnectionRejectionFailedLog(
            proposalID: proposalID,
            error: error
        )
    }
}
