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
    let collection: CollectibleCollection?
    let media: [Media]
    let description: String?
    let properties: [CollectibleTrait]?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.standard = apiModel.standard
        self.mediaType = apiModel.mediaType
        self.thumbnailImage = apiModel.primaryImage.toURL()
        self.title = apiModel.title
        self.collection = apiModel.collection
        self.media = apiModel.media.unwrapMap(Media.init)
        self.description = apiModel.description
        self.properties = apiModel.traits
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.standard = standard
        apiModel.mediaType = mediaType
        apiModel.primaryImage = thumbnailImage?.absoluteString
        apiModel.title = title
        apiModel.collection = collection
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
        var primaryImage: String?
        var title: String?
        var collection: CollectibleCollection?
        var media: [Media.APIModel]?
        var description: String?
        var traits: [CollectibleTrait]?

        init() {
            self.standard = nil
            self.mediaType = nil
            self.primaryImage = nil
            self.title = nil
            self.collection = nil
            self.media = []
            self.description = nil
            self.traits = nil
        }

        private enum CodingKeys: String, CodingKey {
            case standard
            case mediaType = "media_type"
            case primaryImage = "primary_image"
            case title
            case collection
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
    case audio
    case image
    case video
    case mixed
    case unknown(String)

    var rawValue: String {
        switch self {
        case .audio: return "audio"
        case .image: return "image"
        case .video: return "video"
        case .mixed: return "mixed"
        case .unknown(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .audio, .image, .video, .mixed
    ]

    init() {
        self = .unknown("")
    }

    init?(
        rawValue: String
    ) {
        switch rawValue {
        case Self.audio.rawValue: self = .audio
        case Self.image.rawValue: self = .image
        case Self.video.rawValue: self = .video
        case Self.mixed.rawValue: self = .mixed
        default: self = .unknown(rawValue)
        }
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
    case aac
    case adts
    case aif
    case aifc
    case aiff
    case ass
    case au
    case gif
    case jpg
    case jpeg
    case loas
    case mid
    case midi
    case mp2
    case mp3
    case mp4
    case opus
    case png
    case ra
    case snd
    case threeGp
    case threeGpp
    case threeG2
    case threeGpp2
    case wav
    case webp
    case other(String)

    var rawValue: String {
        switch self {
        case .aac: return ".aac"
        case .adts: return ".adts"
        case .aif: return ".aif"
        case .aifc: return ".aifc"
        case .aiff: return ".aiff"
        case .ass: return ".ass"
        case .au: return ".au"
        case .gif: return ".gif"
        case .jpg: return ".jpg"
        case .jpeg: return ".jpeg"
        case .loas: return ".loas"
        case .mid: return ".mid"
        case .midi: return ".midi"
        case .mp2: return ".mp2"
        case .mp3: return ".mp3"
        case .mp4: return ".mp4"
        case .opus: return ".opus"
        case .png: return ".png"
        case .ra: return ".ra"
        case .snd: return ".snd"
        case .threeGp: return ".3gp"
        case .threeGpp: return ".3gpp"
        case .threeG2: return ".3g2"
        case .threeGpp2: return ".3gpp2"
        case .wav: return ".wav"
        case .webp: return ".webp"
        case .other(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .aac, .adts, .aif, .aifc, .aiff,
        .ass, .au, .gif, .jpg, .jpeg,
        .loas, .mid, .midi, .mp2, .mp3,
        .mp4, .opus, .png, .ra, .threeGp,
        .threeGpp, .threeG2, .threeGpp2, .snd, .wav,
        .webp
    ]

    init() {
        self = .other("")
    }

    init?(rawValue: String) {
        switch rawValue {
        case Self.aac.rawValue: self = .aac
        case Self.adts.rawValue: self = .adts
        case Self.aif.rawValue: self = .aif
        case Self.aifc.rawValue: self = .aifc
        case Self.aiff.rawValue: self = .aiff
        case Self.ass.rawValue: self = .ass
        case Self.au.rawValue: self = .au
        case Self.gif.rawValue: self = .gif
        case Self.jpg.rawValue: self = .jpg
        case Self.jpeg.rawValue: self = .jpeg
        case Self.loas.rawValue: self = .loas
        case Self.mid.rawValue: self = .mid
        case Self.midi.rawValue: self = .midi
        case Self.mp2.rawValue: self = .mp2
        case Self.mp3.rawValue: self = .mp3
        case Self.mp4.rawValue: self = .mp4
        case Self.opus.rawValue: self = .opus
        case Self.png.rawValue: self = .png
        case Self.ra.rawValue: self = .ra
        case Self.snd.rawValue: self = .snd
        case Self.threeGp.rawValue: self = .threeGp
        case Self.threeGpp.rawValue: self = .threeGpp
        case Self.threeG2.rawValue: self = .threeG2
        case Self.threeGpp2.rawValue: self = .threeGpp2
        case Self.wav.rawValue: self = .wav
        case Self.webp.rawValue: self = .webp
        default: self = .other(rawValue)
        }
    }
}

extension MediaExtension {
    var isGIF: Bool {
        return self == .gif
    }
}
