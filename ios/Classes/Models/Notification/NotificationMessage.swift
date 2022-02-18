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
import MacaroonUtils

final class NotificationMessage: ALGEntityModel {
    let id: Int
    let account: Int?
    let notificationType: NotificationType?
    let date: Date?
    let message: String?
    let detail: NotificationDetail?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.id ?? 0
        self.account = apiModel.account
        self.notificationType = apiModel.type
        /// <todo>
        /// Without format string ???
        self.date = apiModel.creationDatetime?.toDate()?.date
        self.message = apiModel.message
        self.detail = apiModel.metadata
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.id = id
        apiModel.account = account
        apiModel.type = notificationType
        apiModel.creationDatetime = date?.toString(.standard)
        apiModel.message = message
        apiModel.metadata = detail
        return apiModel
    }
}

extension NotificationMessage {
    struct APIModel: ALGAPIModel {
        var id: Int?
        var account: Int?
        var type: NotificationType?
        var creationDatetime: String?
        var message: String?
        var metadata: NotificationDetail?

        init() {
            self.id = nil
            self.account = nil
            self.type = nil
            self.creationDatetime = nil
            self.message = nil
            self.metadata = nil
        }

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case account = "account"
            case type = "type"
            case creationDatetime = "creation_datetime"
            case message = "message"
            case metadata = "metadata"
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
