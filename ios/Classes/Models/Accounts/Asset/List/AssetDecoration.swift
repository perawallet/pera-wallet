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
//  AssetDecoration.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetDecoration: ALGEntityModel {
    let id: Int64
    let name: String?
    let unitName: String?
    let decimals: Int
    let usdValue: Decimal?
    let total: UInt64?
    let totalSupply: Decimal?
    let creator: AssetCreator?
    let collectible: Collectible?
    let projectURL: URL?
    let explorerURL: URL?
    let url: String?
    let verificationTier: AssetVerificationTier
    let logoURL: URL?
    let description: String?
    let discordURL: URL?
    let telegramURL: URL?
    let twitterURL: URL?
    let algoPriceChangePercentage: Decimal
    let isAvailableOnDiscover: Bool
    let isDestroyed: Bool

    var state: AssetState = .ready

    var isCollectible: Bool {
        return collectible != nil
    }

    var isAlgo: Bool {
        return id == 0
    }

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        let decimals = apiModel.fractionDecimals ?? 0

        self.id = apiModel.assetId
        self.name = apiModel.name
        self.unitName = apiModel.unitName
        self.decimals = decimals
        self.usdValue = apiModel.usdValue.unwrap { Decimal(string: $0) }
        self.total = apiModel.total.unwrap { UInt64($0) }

        if let totalSupply = apiModel.totalSupply {
            self.totalSupply = totalSupply
        } else {
            /// totalSupply = total * 10^-(decimals)
            self.totalSupply = apiModel.total
                .unwrap { Decimal(string: $0) }
                .unwrap { Decimal(sign: .plus, exponent: -decimals, significand: $0) }
        }

        self.creator = apiModel.creator.unwrap(AssetCreator.init)
        self.projectURL = apiModel.projectURL.toURL()
        self.explorerURL = apiModel.explorerURL.toURL()
        self.collectible = apiModel.collectible.unwrap(Collectible.init)
        self.url = apiModel.url
        self.verificationTier = apiModel.verificationTier ?? .unverified
        self.logoURL = apiModel.logo.toURL()
        self.description = apiModel.description
        self.discordURL = apiModel.discordURL.toURL()
        self.telegramURL = apiModel.telegramURL.toURL()
        self.twitterURL = apiModel.twitterUsername
            .unwrapNonEmptyString()
            .unwrap(URL.twitterURL(username:))
        self.algoPriceChangePercentage = apiModel.algoPriceChangePercentage ?? 0
        self.isAvailableOnDiscover = apiModel.isAvailableOnDiscover ?? false
        self.isDestroyed = apiModel.isDestroyed ?? false
    }
    
    init(assetDetail: AssetDetail) {
        self.id = assetDetail.id
        self.name = assetDetail.assetName
        self.unitName = assetDetail.unitName
        self.decimals = assetDetail.fractionDecimals
        self.usdValue = nil
        self.total = assetDetail.total
        self.totalSupply = nil
        self.creator = AssetCreator(address: assetDetail.creator)
        self.projectURL = nil
        self.explorerURL = nil
        self.collectible = nil
        self.url = assetDetail.url
        self.verificationTier = .unverified
        self.logoURL = nil
        self.description = nil
        self.discordURL = nil
        self.telegramURL = nil
        self.twitterURL = nil
        self.algoPriceChangePercentage = 0
        self.isAvailableOnDiscover = false
        self.isDestroyed = false
    }

    init(asset: Asset) {
        self.id = asset.id
        self.name = asset.naming.name
        self.unitName = asset.naming.unitName
        self.decimals = asset.decimals
        self.usdValue = asset.usdValue
        self.total = asset.total
        self.totalSupply = asset.totalSupply
        self.creator = asset.creator
        self.projectURL = asset.projectURL
        self.explorerURL = asset.explorerURL
        self.collectible = nil
        self.url = asset.url
        self.verificationTier = asset.verificationTier
        self.logoURL = asset.logoURL
        self.description = asset.description
        self.discordURL = asset.discordURL
        self.telegramURL = asset.telegramURL
        self.twitterURL = asset.twitterURL
        self.algoPriceChangePercentage = asset.algoPriceChangePercentage
        self.isAvailableOnDiscover = asset.isAvailableOnDiscover
        self.isDestroyed = asset.isDestroyed
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetId = id
        apiModel.name = name
        apiModel.unitName = unitName
        apiModel.fractionDecimals = decimals
        apiModel.usdValue = usdValue.unwrap { String(describing: $0) }
        apiModel.total = total.unwrap { String(describing: $0) }
        apiModel.totalSupply = totalSupply
        apiModel.creator = creator?.encode()
        apiModel.projectURL = projectURL?.absoluteString
        apiModel.explorerURL = explorerURL?.absoluteString
        apiModel.collectible = collectible?.encode()
        apiModel.url = url
        apiModel.verificationTier = verificationTier
        apiModel.logo = logoURL?.absoluteString
        apiModel.description = description
        apiModel.discordURL = discordURL?.absoluteString
        apiModel.telegramURL = telegramURL?.absoluteString
        apiModel.twitterUsername = twitterURL?.pathComponents.last
        apiModel.algoPriceChangePercentage = algoPriceChangePercentage
        apiModel.isAvailableOnDiscover = isAvailableOnDiscover
        apiModel.isDestroyed = isDestroyed
        return apiModel
    }
}

extension AssetDecoration {
    struct APIModel: ALGAPIModel {
        var assetId: Int64
        var name: String?
        var unitName: String?
        var fractionDecimals: Int?
        var usdValue: String?
        var creator: AssetCreator.APIModel?
        var projectURL: String?
        var explorerURL: String?
        var collectible: Collectible.APIModel?
        var url: String?
        var total: String?
        var totalSupply: Decimal?
        var verificationTier: AssetVerificationTier?
        var logo: String?
        var description: String?
        var discordURL: String?
        var telegramURL: String?
        var twitterUsername: String?
        var algoPriceChangePercentage: Decimal?
        var isAvailableOnDiscover: Bool?
        var isDestroyed: Bool?

        init() {
            self.assetId = 0
            self.verificationTier = .init()
        }

        private enum CodingKeys: String, CodingKey {
            case assetId = "asset_id"
            case name
            case unitName = "unit_name"
            case fractionDecimals = "fraction_decimals"
            case usdValue = "usd_value"
            case creator
            case projectURL = "project_url"
            case explorerURL = "explorer_url"
            case collectible
            case url
            case total
            case totalSupply = "total_supply"
            case verificationTier = "verification_tier"
            case logo
            case description
            case discordURL = "discord_url"
            case telegramURL = "telegram_url"
            case twitterUsername = "twitter_username"
            case algoPriceChangePercentage = "last_24_hours_algo_price_change_percentage"
            case isAvailableOnDiscover = "available_on_discover_mobile"
            case isDestroyed = "is_deleted"
        }
    }
}

extension AssetDecoration {
    var displayNames: (primaryName: String, secondaryName: String) {
        if let name = name, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            return (name, "\(code.uppercased())")
        } else if let name = name, !name.isEmptyOrBlank {
            return (name, "title-unknown".localized)
        } else if let code = unitName, !code.isEmptyOrBlank {
            return ("\(code.uppercased())", "title-unknown".localized)
        } else {
            return ("title-unknown".localized, "title-unknown".localized)
        }
    }
}

extension AssetDecoration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension AssetDecoration: Comparable {
    static func == (lhs: AssetDecoration, rhs: AssetDecoration) -> Bool {
        return lhs.id == rhs.id &&
            lhs.decimals == rhs.decimals &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.verificationTier == rhs.verificationTier
    }

    static func < (lhs: AssetDecoration, rhs: AssetDecoration) -> Bool {
        return lhs.id < rhs.id
    }
}

/// <todo>
/// Rethink the paginated list model. Should be more reusable.
final class AssetDecorationList:
    PaginatedList<AssetDecoration>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(AssetDecoration.init)
        )
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results.map { $0.encode() }
        return apiModel
    }
}

extension AssetDecorationList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [AssetDecoration.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

typealias AssetID = Int64

extension AssetID {
    var stringWithHashtag: String {
        "#".appending(String(self))
    }
}
