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

//   CollectibleAsset.swift

import Foundation

final class CollectibleAsset: Asset {
    let id: AssetID
    let amount: UInt64
    let isFrozen: Bool?
    let isDeleted: Bool?
    let creator: AssetCreator?
    let name: String?
    let unitName: String?
    let decimals: Int
    let usdValue: Decimal?
    let total: Int64?
    let isVerified: Bool
    let thumbnailImage: URL?
    let media: [Media]
    let standard: CollectibleStandard?
    let mediaType: MediaType
    let title: String?
    let collectionName: String?
    let url: String?
    let description: String?
    let properties: [CollectibleTrait]?
    let explorerURL: URL?

    var state: AssetState = .ready

    var presentation: AssetPresentation {
        return AssetPresentation(
            id: id,
            decimals: decimals,
            name: name,
            unitName: unitName,
            isVerified: isVerified,
            url: url
        )
    }

    var amountWithFraction: Decimal {
        return amount.assetAmount(fromFraction: decimals)
    }

    var amountDisplayWithFraction: String? {
        return amountWithFraction.toExactFractionLabel(fraction: decimals)
    }

    var amountNumberWithAutoFraction: String? {
        return amountWithFraction.toNumberStringWithSeparatorForLabel(fraction: decimals)
    }

    var isOwned: Bool {
        return amount != 0
    }

    var containsUnsupportedMedia: Bool {
        return media.contains { !$0.type.isSupported }
    }

    /// Collectibles that are pure (non-frictional) according to ARC3
    /// https://github.com/algorandfoundation/ARCs/blob/main/ARCs/arc-0003.md#pure-and-fractional-nfts
    var isPure: Bool {
        guard let total = total else {
            return false
        }

        return total == 1 && decimals == 0
    }

    init(
        asset: ALGAsset,
        decoration: AssetDecoration
    ) {
        self.id = asset.id
        self.amount = asset.amount
        self.isFrozen = asset.isFrozen
        self.isDeleted = asset.isDeleted
        self.creator = decoration.creator
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.decimals = decoration.decimals
        self.usdValue = decoration.usdValue
        self.total = decoration.total
        self.isVerified = decoration.isVerified
        self.thumbnailImage = decoration.collectible?.thumbnailImage
        self.mediaType = decoration.collectible?.mediaType ?? .unknown("")
        self.standard = decoration.collectible?.standard ?? .unknown("")
        self.media = decoration.collectible?.media ?? []
        self.title = decoration.collectible?.title
        self.collectionName = decoration.collectible?.collectionName
        self.url = decoration.url
        self.description = decoration.collectible?.description
        self.properties = decoration.collectible?.properties
        self.explorerURL = decoration.collectible?.explorerURL
    }
}

extension CollectibleAsset: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CollectibleAsset: Comparable {
    static func == (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id == rhs.id &&
            lhs.amount == rhs.amount &&
            lhs.isFrozen == rhs.isFrozen &&
            lhs.isDeleted == rhs.isDeleted &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.decimals == rhs.decimals &&
            lhs.usdValue == rhs.usdValue &&
            lhs.total == rhs.total &&
            lhs.isVerified == rhs.isVerified &&
            lhs.thumbnailImage == rhs.thumbnailImage &&
            lhs.title == rhs.title &&
            lhs.collectionName == rhs.collectionName
    }

    static func < (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id < rhs.id
    }
}
