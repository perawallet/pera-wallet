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
    var state: AssetState = .ready

    let id: AssetID
    private(set) var amount: UInt64
    private(set) var decimals: Int
    private(set) var total: UInt64?
    private(set) var totalSupply: Decimal?
    private(set) var decimalAmount: Decimal
    private(set) var isFrozen: Bool?
    private(set) var isDestroyed: Bool
    private(set) var optedInAtRound: UInt64?
    private(set) var creator: AssetCreator?
    private(set) var name: String?
    private(set) var unitName: String?
    private(set) var usdValue: Decimal?
    private(set) var totalUSDValue: Decimal?
    private(set) var verificationTier: AssetVerificationTier
    private(set) var thumbnailImage: URL?
    private(set) var media: [Media]
    private(set) var standard: CollectibleStandard?
    private(set) var mediaType: MediaType
    private(set) var title: String?
    private(set) var collection: CollectibleCollection?
    private(set) var url: String?
    private(set) var description: String?
    private(set) var properties: [CollectibleTrait]?
    private(set) var projectURL: URL?
    private(set) var explorerURL: URL?
    private(set) var logoURL: URL?
    private(set) var discordURL: URL?
    private(set) var telegramURL: URL?
    private(set) var twitterURL: URL?
    private(set) var algoPriceChangePercentage: Decimal
    private(set) var isAvailableOnDiscover: Bool

    let isAlgo = false
    let isFault = false

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
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = asset.optedInAtRound
        self.creator = decoration.creator
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply
        self.verificationTier = decoration.verificationTier
        self.thumbnailImage = decoration.collectible?.thumbnailImage
        self.mediaType = decoration.collectible?.mediaType ?? .unknown("")
        self.standard = decoration.collectible?.standard ?? .unknown("")
        self.media = decoration.collectible?.media ?? []
        self.title = decoration.collectible?.title
        self.collection = decoration.collectible?.collection
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
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
    }

    init(decoration: AssetDecoration) {
        self.id = decoration.id
        self.isFrozen = nil
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = nil
        self.creator = decoration.creator
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply
        self.verificationTier = decoration.verificationTier
        self.thumbnailImage = decoration.collectible?.thumbnailImage
        self.mediaType = decoration.collectible?.mediaType ?? .unknown("")
        self.standard = decoration.collectible?.standard ?? .unknown("")
        self.media = decoration.collectible?.media ?? []
        self.title = decoration.collectible?.title
        self.collection = decoration.collectible?.collection
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
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
    }
}

extension CollectibleAsset {
    func update(with asset: StandardAsset) {
        if id != asset.id { return }

        isFrozen = asset.isFrozen ?? isFrozen
        isDestroyed = asset.isDestroyed
        optedInAtRound = asset.optedInAtRound ?? optedInAtRound
        creator = asset.creator ?? creator
        name = asset.naming.name ?? name
        unitName = asset.naming.unitName ?? unitName
        total = asset.total ?? total
        totalSupply = asset.totalSupply ?? totalSupply
        verificationTier = asset.verificationTier
        url = asset.url ?? url
        projectURL = asset.projectURL ?? projectURL
        explorerURL = asset.explorerURL ?? explorerURL
        logoURL = asset.logoURL ?? logoURL
        discordURL = asset.discordURL ?? discordURL
        telegramURL = asset.telegramURL ?? telegramURL
        twitterURL = asset.twitterURL ?? twitterURL
        amount = asset.amount
        decimals = asset.decimals
        decimalAmount = asset.decimalAmount
        usdValue = asset.usdValue ?? usdValue
        totalUSDValue = asset.totalUSDValue ?? totalUSDValue
        algoPriceChangePercentage = asset.algoPriceChangePercentage
        isAvailableOnDiscover = asset.isAvailableOnDiscover
    }

    func update(with asset: CollectibleAsset) {
        if id != asset.id { return }

        isFrozen = asset.isFrozen ?? isFrozen
        isDestroyed = asset.isDestroyed
        optedInAtRound = asset.optedInAtRound ?? optedInAtRound
        creator = asset.creator ?? creator
        name = asset.naming.name ?? name
        unitName = asset.naming.unitName ?? unitName
        total = asset.total ?? total
        totalSupply = asset.totalSupply ?? totalSupply
        verificationTier = asset.verificationTier
        thumbnailImage = asset.thumbnailImage ?? thumbnailImage
        mediaType = asset.mediaType
        standard = asset.standard ?? standard
        media = asset.media.isEmpty ? media : asset.media
        title = asset.title ?? title
        collection = asset.collection ?? collection
        url = asset.url ?? url
        description = asset.description ?? description
        properties = asset.properties.isNilOrEmpty ? properties : asset.properties
        projectURL = asset.projectURL ?? projectURL
        explorerURL = asset.explorerURL ?? explorerURL
        logoURL = asset.logoURL ?? logoURL
        discordURL = asset.discordURL ?? discordURL
        telegramURL = asset.telegramURL ?? telegramURL
        twitterURL = asset.twitterURL ?? twitterURL
        amount = asset.amount
        decimals = asset.decimals
        decimalAmount = asset.decimalAmount
        usdValue = asset.usdValue ?? usdValue
        totalUSDValue = asset.totalUSDValue ?? totalUSDValue
        algoPriceChangePercentage = asset.algoPriceChangePercentage
        isAvailableOnDiscover = asset.isAvailableOnDiscover
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
            lhs.isDestroyed == rhs.isDestroyed &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.decimals == rhs.decimals &&
            lhs.usdValue == rhs.usdValue &&
            lhs.total == rhs.total &&
            lhs.verificationTier == rhs.verificationTier &&
            lhs.thumbnailImage == rhs.thumbnailImage &&
            lhs.title == rhs.title &&
            lhs.collection?.name == rhs.collection?.name &&
            lhs.optedInAtRound == rhs.optedInAtRound
    }

    static func < (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id < rhs.id
    }
}
