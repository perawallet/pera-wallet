// Copyright 2019 Algorand, Inc.

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

import Magpie

class NotificationMessage: Model {
    let id: Int
    let account: Int?
    let notificationType: NotificationType?
    let date: Date?
    let message: String?
    let detail: NotificationDetail?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        account = try container.decodeIfPresent(Int.self, forKey: .account)
        notificationType = try container.decodeIfPresent(NotificationType.self, forKey: .notificationType)
        if let stringDate = try container.decodeIfPresent(String.self, forKey: .date) {
            date = stringDate.toDate()?.date
        } else {
            date = nil
        }
        message = try container.decodeIfPresent(String.self, forKey: .message)
        detail = try container.decodeIfPresent(NotificationDetail.self, forKey: .detail)
    }
}

extension NotificationMessage {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case account = "account"
        case notificationType = "type"
        case date = "creation_datetime"
        case message = "message"
        case detail = "metadata"
    }
}
