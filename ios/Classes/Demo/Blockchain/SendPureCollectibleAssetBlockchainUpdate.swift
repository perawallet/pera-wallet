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

//   PureCollectibleAssetSendBlockchainUpdate.swift

import Foundation

struct SendPureCollectibleAssetBlockchainUpdate: BlockchainUpdate {
    let accountAddress: String
    let assetID: AssetID
    let assetName: String?
    let assetUnitName: String?
    let assetVerificationTier: AssetVerificationTier
    let assetTitle: String?
    let assetThumbnailImage: URL?
    let assetCollectionName: String?
    let status: Status

    init(request: SendPureCollectibleAssetBlockchainRequest) {
        self.accountAddress = request.accountAddress
        self.assetID = request.assetID
        self.assetName = request.assetName
        self.assetUnitName = request.assetUnitName
        self.assetVerificationTier = request.assetVerificationTier
        self.assetTitle = request.assetTitle
        self.assetThumbnailImage = request.assetThumbnailImage
        self.assetCollectionName = request.assetCollectionName
        self.status = .pending
    }

    init(
        update: SendPureCollectibleAssetBlockchainUpdate,
        status: Status
    ) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.assetName = update.assetName
        self.assetUnitName = update.assetUnitName
        self.assetVerificationTier = update.assetVerificationTier
        self.assetTitle = update.assetTitle
        self.assetThumbnailImage = update.assetThumbnailImage
        self.assetCollectionName = update.assetCollectionName
        self.status = status
    }
}

extension SendPureCollectibleAssetBlockchainUpdate {
    enum Status {
        case pending
        case waitingForNotification
        case completed
    }
}
