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

//   WCSessionDraft.swift

import Foundation

struct WCSessionDraft: Hashable {
    let wcV1Session: WCSession?
    let wcV2Session: WalletConnectV2Session?

    init(wcV1Session: WCSession) {
        self.wcV1Session = wcV1Session
        self.wcV2Session = nil
    }

    init(wcV2Session: WalletConnectV2Session) {
        self.wcV2Session = wcV2Session
        self.wcV1Session = nil
    }

    var isWCv1Session: Bool {
        return wcV1Session != nil
    }

    var isWCv2Session: Bool {
        return wcV2Session != nil
    }

    func hash(
        into hasher: inout Hasher
    ) {
        if let wcV1Session {
            hasher.combine(wcV1Session.urlMeta.topic)
            return
        }

        if let wcV2Session {
            hasher.combine(wcV2Session.topic)
            return
        }
    }

    static func == (
        lhs: WCSessionDraft,
        rhs: WCSessionDraft
    ) -> Bool {
        if lhs.isWCv1Session && rhs.isWCv1Session {
            return lhs.wcV1Session == rhs.wcV1Session
        } else if lhs.isWCv2Session && rhs.isWCv2Session {
            return lhs.wcV2Session!.topic == rhs.wcV2Session!.topic
        } else {
            return false
        }
    }
}
