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
//   CompoundAsset.swift

import Foundation

final class CompoundAsset: Hashable {
    let id: Int64
    let base: Asset
    let detail: AssetInformation
    
    init(
        _ base: Asset,
        _ detail: AssetInformation
    ) {
        self.id = base.id
        self.base = base
        self.detail = detail
    }
}

extension CompoundAsset {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(base)
        hasher.combine(detail)
    }
    
    static func == (
        lhs: CompoundAsset,
        rhs: CompoundAsset
    ) -> Bool {
        return
            lhs.base == rhs.base &&
            lhs.detail == rhs.detail
    }
}
