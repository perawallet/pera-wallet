// Copyright 2019 Algorand, Inc.

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
//  AssetCardViewModel.swift

import UIKit

class AssetCardViewModel {
    
    private(set) var isVerified: Bool = false
    private(set) var name: String?
    private(set) var amount: String?
    private(set) var id: String?
    
    init(account: Account, assetDetail: AssetDetail) {
        setIsVerified(from: assetDetail)
        setName(from: assetDetail)
        setAmount(from: assetDetail, in: account)
        setId(from: assetDetail)
    }
    
    private func setIsVerified(from assetDetail: AssetDetail) {
        isVerified = assetDetail.isVerified
    }
    
    private func setName(from assetDetail: AssetDetail) {
        name = assetDetail.getDisplayNames().0
    }
    
    private func setAmount(from assetDetail: AssetDetail, in account: Account) {
        guard let assetAmount = account.amount(for: assetDetail) else {
            return
        }
        amount = assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
    
    private func setId(from assetDetail: AssetDetail) {
        id = "asset-detail-id-title".localized(params: "\(assetDetail.id)")
    }
}
