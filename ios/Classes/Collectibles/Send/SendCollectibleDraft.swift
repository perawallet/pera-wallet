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

//   SendCollectibleDraft.swift

import UIKit

struct SendCollectibleDraft {
    let fromAccount: Account
    let collectibleAsset: CollectibleAsset
    let image: UIImage?

    var toAccount: Account?
    var toContact: Contact?
    var toNameService: NameService?
    var fee: UInt64?

    var receiverAddress: String? {
        toAccount?.address ??
        toContact?.address ??
        toNameService?.address
    }

    mutating func resetReceiver() {
        toAccount = nil
        toContact = nil
        toNameService = nil
    }
}
