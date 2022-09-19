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

//   Collectible.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class Collectible: ALGEntityModel {
    let standard: CollectibleStandard?
    let mediaType: MediaType?
    let thumbnailImage: URL?
    let title: String?
    let collectionName: String?
    let media: [Media]
    let description: String?
    let properties: [CollectibleTrait]?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.standard = apiModel.standard
        self.mediaType = apiModel.mediaType
        self.thumbnailImage = apiModel.primaryImage
        self.title = apiModel.title
        self.collectionName = apiModel.collectionName
        self.media = apiModel.media.unwrapMap(Media.init)
        self.description = apiModel.description
        self.properties = apiModel.traits
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.standard = standard
        apiModel.mediaType = mediaType
        apiModel.primaryImage = thumbnailImage
        apiModel.title = title
        apiModel.collectionName = collectionName
        apiModel.media = media.map { $0.encode() }
        apiModel.description = description
        apiModel.traits = properties
        return apiModel
    }
}

extension Collectible {
    struct APIModel: ALGAPIModel {
        var standard: CollectibleStandard?
        var mediaType: MediaType?
        var primaryImage: URL?
        var title: String?
        var collectionName: String?
        var media: [Media.APIModel]?
        var description: String?
        var traits: [CollectibleTrait]?

        init() {
            self.standard = nil
            self.mediaType = nil
            self.primaryImage = nil
            self.title = nil
            self.collectionName = nil
            self.media = []
            self.description = nil
            self.traits = nil
        }

        private enum CodingKeys: String, CodingKey {
            case standard
            case mediaType = "media_type"
            case primaryImage = "primary_image"
            case title
            case collectionName = "collection_name"
            case media
            case description
            case traits
        }
    }
}

enum MediaType:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    case image
    case video
    case mixed
    case unknown(String)

    var rawValue: String {
        switch self {
        case .image: return "image"
        case .video: return "video"
        case .mixed: return "mixed"
        case .unknown(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .image, .video, .mixed
    ]

    init() {
        self = .unknown("")
    }

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .unknown(rawValue)
    }

    var isSupported: Bool {
        if case .unknown = self {
            return false
        }

        return true
    }
}

enum CollectibleStandard:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    case arc3
    case arc69
    case unknown(String)

    var rawValue: String {
        switch self {
        case .arc3: return "arc3"
        case .arc69: return "arc69"
        case .unknown(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .arc3, .arc69
    ]

    init() {
        self = .unknown("")
    }

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .unknown(rawValue)
    }
}

enum MediaExtension:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    case gif
    case jpg
    case jpeg
    case png
    case mp4
    case webp
    case other(String)

    var rawValue: String {
        switch self {
        case .gif: return ".gif"
        case .jpg: return ".jpg"
        case .jpeg: return ".jpeg"
        case .png: return ".png"
        case .mp4: return ".mp4"
        case .webp: return ".webp"
        case .other(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .gif, .jpg, .jpeg, .png, .mp4, .webp
    ]

    init() {
        self = .other("")
    }

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .other(rawValue)
    }
}
