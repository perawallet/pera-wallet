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

//   Announcement.swift

import Foundation

/// <todo>
/// Rethink the paginated list model. Should be more reusable.
final class AnnouncementList:
    PaginatedList<Announcement>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrap(or: [])
        )
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results
        return apiModel
    }
}

extension AnnouncementList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [Announcement]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

final class Announcement: ALGAPIModel {
    let id: Int
    let type: AnnouncementType
    let title: String?
    let subtitle: String?
    let buttonLabel: String?
    let buttonUrl: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(AnnouncementType.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.buttonLabel = try container.decodeIfPresent(String.self, forKey: .buttonLabel)
        self.buttonUrl = try container.decodeIfPresent(String.self, forKey: .buttonUrl)
    }
    
    init() {
        id = 0
        type = .generic
        title = nil
        subtitle = nil
        buttonLabel = nil
        buttonUrl = nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case subtitle
        case buttonLabel = "button_label"
        case buttonUrl = "button_url"
    }
    
}

enum AnnouncementType: String, Codable {
    case governance
    case generic
    
    init?(rawValue: String) {
        switch rawValue {
        case "governance":
            self = .governance
        default:
            self = .generic
        }
    }
}
