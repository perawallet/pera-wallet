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

//   SendPureCollectibleAssetBlockchainRequest.swift

import Foundation

struct SendPureCollectibleAssetBlockchainRequest: BlockchainRequest {
    let accountAddress: String
    let assetID: AssetID
    let assetName: String?
    let assetUnitName: String?
    let assetVerificationTier: AssetVerificationTier
    let assetTitle: String?
    let assetThumbnailImage: URL?
    let assetCollectionName: String?

    init(
        account: Account,
        asset: CollectibleAsset
    ) {
        self.accountAddress = account.address
        self.assetID = asset.id
        self.assetName = asset.naming.name
        self.assetUnitName = asset.naming.unitName
        self.assetVerificationTier = asset.verificationTier
        self.assetTitle = asset.title
        self.assetThumbnailImage = asset.thumbnailImage
        self.assetCollectionName = asset.collection?.name
    }
}
