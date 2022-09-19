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

    var state: AssetState = .ready

    var isCollectible: Bool {
        return collectible != nil
    }

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.assetId
        self.name = apiModel.name
        self.unitName = apiModel.unitName
        self.decimals = apiModel.fractionDecimals ?? 0
        self.usdValue = apiModel.usdValue.unwrap { Decimal(string: $0) }
        self.total = apiModel.total.unwrap { UInt64($0) }
        self.creator = apiModel.creator.unwrap(AssetCreator.init)
        self.projectURL = apiModel.projectURL
            .unwrapNonEmptyString()
            .unwrap(URL.init)
        self.explorerURL = apiModel.explorerURL
        self.collectible = apiModel.collectible.unwrap(Collectible.init)
        self.url = apiModel.url
        self.verificationTier = apiModel.verificationTier ?? .unverified
        self.logoURL = apiModel.logo
        self.description = apiModel.description
        self.discordURL = apiModel.discordURL
            .unwrapNonEmptyString()
            .unwrap(URL.init)
        self.telegramURL = apiModel.telegramURL
            .unwrapNonEmptyString()
            .unwrap(URL.init)
        self.twitterURL = apiModel.twitterUsername
            .unwrapNonEmptyString()
            .unwrap(URL.twitterURL(username:))
    }
    
    init(assetDetail: AssetDetail) {
        self.id = assetDetail.id
        self.name = assetDetail.assetName
        self.unitName = assetDetail.unitName
        self.decimals = assetDetail.fractionDecimals
        self.usdValue = nil
        self.total = assetDetail.total
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
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetId = id
        apiModel.name = name
        apiModel.unitName = unitName
        apiModel.fractionDecimals = decimals
        apiModel.usdValue = usdValue.unwrap { String(describing: $0) }
        apiModel.total = total.unwrap { String(describing: $0) }
        apiModel.creator = creator?.encode()
        apiModel.projectURL = projectURL?.absoluteString
        apiModel.explorerURL = explorerURL
        apiModel.collectible = collectible?.encode()
        apiModel.url = url
        apiModel.verificationTier = verificationTier
        apiModel.logo = logoURL
        apiModel.description = description
        apiModel.discordURL = discordURL?.absoluteString
        apiModel.telegramURL = telegramURL?.absoluteString
        apiModel.twitterUsername = twitterURL?.pathComponents.last
        return apiModel
    }

    init(asset: Asset) {
        self.id = asset.id
        self.name = asset.naming.name
        self.unitName = asset.naming.unitName
        self.decimals = asset.decimals
        self.usdValue = asset.usdValue
        self.total = asset.total
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
        var explorerURL: URL?
        var collectible: Collectible.APIModel?
        var url: String?
        var total: String?
        var verificationTier: AssetVerificationTier?
        var logo: URL?
        var description: String?
        var discordURL: String?
        var telegramURL: String?
        var twitterUsername: String?

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
            case verificationTier = "verification_tier"
            case logo
            case description
            case discordURL = "discord_url"
            case telegramURL = "telegram_url"
            case twitterUsername = "twitter_username"
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
