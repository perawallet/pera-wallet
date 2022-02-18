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
//  QRCreationDraft.swift

import Foundation

struct QRCreationDraft {
    let address: String
    let mnemonic: String?
    let title: String?
    let mode: QRMode
    let isSelectable: Bool
    
    init(address: String, mode: QRMode, mnemonic: String? = nil, title: String?) {
        self.address = address
        self.mode = mode
        self.mnemonic = mnemonic
        self.isSelectable = mode == .address
        self.title = title
    }
}
