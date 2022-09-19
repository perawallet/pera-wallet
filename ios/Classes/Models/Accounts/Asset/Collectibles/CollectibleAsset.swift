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
    var optedInAddress: String?

    let id: AssetID
    let amount: UInt64
    let decimals: Int
    let total: UInt64?
    let decimalAmount: Decimal
    let isFrozen: Bool?
    let isDeleted: Bool?
    let optedInAtRound: UInt64?
    let creator: AssetCreator?
    let name: String?
    let unitName: String?
    let usdValue: Decimal?
    let totalUSDValue: Decimal?
    let verificationTier: AssetVerificationTier
    let thumbnailImage: URL?
    let media: [Media]
    let standard: CollectibleStandard?
    let mediaType: MediaType
    let title: String?
    let collectionName: String?
    let url: String?
    let description: String?
    let properties: [CollectibleTrait]?
    let projectURL: URL?
    let explorerURL: URL?
    let logoURL: URL?
    let discordURL: URL?
    let telegramURL: URL?
    let twitterURL: URL?
    let isAlgo = false
    let isFault = false

    var state: AssetState = .ready

    var naming: AssetNaming {
        return AssetNaming(
            id: id,
            name: name,
            unitName: unitName
        )
    }

    var amountWithFraction: Decimal {
        return amount.assetAmount(fromFraction: decimals)
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
        self.isFrozen = asset.isFrozen
        self.isDeleted = asset.isDeleted
        self.optedInAtRound = asset.optedInAtRound
        self.creator = decoration.creator
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.total = decoration.total
        self.verificationTier = decoration.verificationTier
        self.thumbnailImage = decoration.collectible?.thumbnailImage
        self.mediaType = decoration.collectible?.mediaType ?? .unknown("")
        self.standard = decoration.collectible?.standard ?? .unknown("")
        self.media = decoration.collectible?.media ?? []
        self.title = decoration.collectible?.title
        self.collectionName = decoration.collectible?.collectionName
        self.url = decoration.url
        self.description = decoration.collectible?.description
        self.properties = decoration.collectible?.properties
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL

        let amount = asset.amount
        let decimals = decoration.decimals
        /// <note>
        /// decimalAmount = amount * 10^-(decimals)
        let decimalAmount = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(amount))
        let usdValue = decoration.usdValue

        self.amount = amount
        self.decimals = decimals
        self.decimalAmount = decimalAmount
        self.usdValue = usdValue
        self.totalUSDValue = usdValue.unwrap { $0 * decimalAmount }
    }

    init(decoration: AssetDecoration) {
        self.id = decoration.id
        self.isFrozen = nil
        self.isDeleted = nil
        self.optedInAtRound = nil
        self.creator = decoration.creator
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.total = decoration.total
        self.verificationTier = decoration.verificationTier
        self.thumbnailImage = decoration.collectible?.thumbnailImage
        self.mediaType = decoration.collectible?.mediaType ?? .unknown("")
        self.standard = decoration.collectible?.standard ?? .unknown("")
        self.media = decoration.collectible?.media ?? []
        self.title = decoration.collectible?.title
        self.collectionName = decoration.collectible?.collectionName
        self.url = decoration.url
        self.description = decoration.collectible?.description
        self.properties = decoration.collectible?.properties
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL
        self.amount = 0
        self.decimals = decoration.decimals
        self.decimalAmount = 0
        self.usdValue = decoration.usdValue
        self.totalUSDValue = 0
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
            lhs.verificationTier == rhs.verificationTier &&
            lhs.thumbnailImage == rhs.thumbnailImage &&
            lhs.title == rhs.title &&
            lhs.collectionName == rhs.collectionName &&
            lhs.optedInAtRound == rhs.optedInAtRound
    }

    static func < (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id < rhs.id
    }
}
