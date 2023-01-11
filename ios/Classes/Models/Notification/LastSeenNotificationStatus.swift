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

//   LastSeenNotificationStatus.swift

import Foundation

final class LastSeenNotificationStatus: ALGAPIModel {
    let id: Int

    init() {
        id = -1
    }
}

extension LastSeenNotificationStatus {
    private enum CodingKeys:
        String,
        CodingKey {
        case id = "last_seen_notification_id"
    }
}
