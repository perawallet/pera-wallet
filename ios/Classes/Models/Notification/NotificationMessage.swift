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
//  Notification.swift

import Foundation
import MagpieCore
import MacaroonURLImage
import MacaroonUtils

final class NotificationMessage: ALGEntityModel {
    let id: Int
    let url: URL?
    let date: Date?
    let message: String?
    let icon: NotificationIcon?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.id ?? 0
        self.url = apiModel.url.toURL()
        /// <todo>
        /// Without format string ???
        self.date = apiModel.creationDatetime?.toDate()?.date
        self.message = apiModel.message
        self.icon = apiModel.icon.unwrap(NotificationIcon.init)
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.id = id
        apiModel.url = url?.absoluteString
        apiModel.creationDatetime = date?.toString(.standard)
        apiModel.message = message
        apiModel.icon = icon?.encode()
        return apiModel
    }
}

extension NotificationMessage {
    struct APIModel: ALGAPIModel {
        var id: Int?
        var url: String?
        var creationDatetime: String?
        var message: String?
        var icon: NotificationIcon.APIModel?

        init() {
            self.id = nil
            self.url = nil
            self.creationDatetime = nil
            self.message = nil
            self.icon = nil
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case url
            case creationDatetime = "creation_datetime"
            case message
            case icon
        }
    }
}

final class NotificationIcon: ALGEntityModel {
    let logo: URL?
    let shape: NotificationIconShape?
    
    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.logo = apiModel.logo.toURL()
        self.shape = apiModel.shape
    }
    
    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.logo = logo?.absoluteString
        apiModel.shape = shape
        return apiModel
    }
}

extension NotificationIcon {
    struct APIModel: ALGAPIModel {
        var logo: String?
        var shape: NotificationIconShape?
        
        init() {
            self.logo = nil
            self.shape = .circle
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.logo = try container.decodeIfPresent(String.self, forKey: .logo)
            
            if self.logo == nil {
                self.shape = nil
            } else {
                self.shape = try container.decode(NotificationIconShape.self, forKey: .shape)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case logo
            case shape
        }
    }
}

enum NotificationIconShape:
    String,
    APIModel {
    case circle
    case rectangle
    
    init?(rawValue: String) {
        switch rawValue {
        case "circle": self = .circle
        case "rectangle": self = .rectangle
        default: self = .circle
        }
    }
    
    func convertToImageShape() -> ImageShape {
        switch self {
        case .circle: return .circle
        case .rectangle: return .rounded(4)
        }
    }
}

final class NotificationMessageList:
    PaginatedList<NotificationMessage>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(NotificationMessage.init)
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

extension NotificationMessageList {
    struct APIModel: ALGAPIModel, PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [NotificationMessage.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

extension NotificationMessage: Hashable {
    static func == (lhs: NotificationMessage, rhs: NotificationMessage) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
