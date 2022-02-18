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
//  LedgerAccountAssetCountViewModel.swift

import MacaroonUIKit

final class LedgerAccountAssetCountViewModel: PairedViewModel {
    private(set) var assetCount: String?
    
    init(_ model: Account) {
        bindAssetCount(model)
    }
    
    private func bindAssetCount(_ account: Account) {
        guard let assets = account.assets,
              !assets.isEmpty else {
            return
        }
        
        assetCount = "title-plus-asset-count".localized(params: "\(assets.count)")
    }
}
