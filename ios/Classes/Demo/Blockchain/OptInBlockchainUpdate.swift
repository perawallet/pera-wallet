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

//   OptInBlockchainUpdate.swift

import Foundation

struct OptInBlockchainUpdate: BlockchainUpdate {
    let accountAddress: String
    let assetID: AssetID
    let assetName: String?
    let assetUnitName: String?
    let assetVerificationTier: AssetVerificationTier
    let isAssetDestroyed: Bool
    let isCollectibleAsset: Bool
    let collectibleAssetTitle: String?
    let collectibleAssetThumbnailImage: URL?
    let collectibleAssetCollectionName: String?
    let status: Status
    let notificationMessage: String

    init(request: OptInBlockchainRequest) {
        self.accountAddress = request.accountAddress
        self.assetID = request.assetID
        self.assetName = request.assetName
        self.assetUnitName = request.assetUnitName
        self.assetVerificationTier = request.assetVerificationTier
        self.isAssetDestroyed = request.isAssetDestroyed
        self.isCollectibleAsset = request.isCollectibleAsset
        self.collectibleAssetTitle = request.collectibleAssetTitle
        self.collectibleAssetThumbnailImage = request.collectibleAssetThumbnailImage
        self.collectibleAssetCollectionName = request.collectibleAssetCollectionName
        self.status = .pending

        let name: String
        if request.isCollectibleAsset {
            name = request.collectibleAssetTitle ?? request.assetName ?? String(request.assetID)
        } else {
            name = request.assetName ?? request.assetUnitName ?? String(request.assetID)
        }
        self.notificationMessage = "asset-opt-in-successful-message".localized(params: name)
    }

    init(
        update: OptInBlockchainUpdate,
        status: Status
    ) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.assetName = update.assetName
        self.assetUnitName = update.assetUnitName
        self.assetVerificationTier = update.assetVerificationTier
        self.isAssetDestroyed = update.isAssetDestroyed
        self.isCollectibleAsset = update.isCollectibleAsset
        self.collectibleAssetTitle = update.collectibleAssetTitle
        self.collectibleAssetThumbnailImage = update.collectibleAssetThumbnailImage
        self.collectibleAssetCollectionName = update.collectibleAssetCollectionName
        self.status = status
        self.notificationMessage = update.notificationMessage
    }
}

extension OptInBlockchainUpdate {
    enum Status {
        case pending
        case waitingForNotification
        case completed
    }
}
