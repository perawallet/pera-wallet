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
//  NotificationFilterDraft.swift

import MagpieCore

struct NotificationFilterDraft: JSONObjectBody {
    let deviceId: String
    let accountAddress: String
    let receivesNotifications: Bool

    var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        params.append(.init(.receivesNotifications, receivesNotifications))
        return params
    }
}
