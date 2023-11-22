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

//   WalletConnectRequestDraft.swift

import Foundation

struct WalletConnectRequestDraft {
    let wcV1Request: WalletConnectRequest?
    let wcV2Request: WalletConnectV2Request?

    init(wcV1Request: WalletConnectRequest) {
        self.wcV1Request = wcV1Request
        self.wcV2Request = nil
    }

    init(wcV2Request: WalletConnectV2Request) {
        self.wcV2Request = wcV2Request
        self.wcV1Request = nil
    }
}
