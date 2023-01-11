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

//   LastSeenNotificationController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class LastSeenNotificationController {
    private let api: ALGAPI
    private var ongoingEndpoint: EndpointOperatable?

    init(api: ALGAPI) {
        self.api = api
    }

    func checkStatus() {
        guard let deviceId = api.session.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }

        let draft = NotificationStatusFetchDraft(deviceId: deviceId)
        fetchNotificationStatus(draft: draft)
    }

    func setLastSeenNotification(_ notification: NotificationMessage) {
        guard let deviceId = api.session.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }

        if api.session.lastSeenNotificationID == notification.id {
            return
        }

        let draft = NotificationStatusUpdateDraft(notificationId: notification.id, deviceId: deviceId)

        api.updateNotificationStatus(draft) {
            [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .success(let status):
                self.api.session.lastSeenNotificationID = status.id
            case .failure:
                break
            }
        }
    }

    private func fetchNotificationStatus(draft: NotificationStatusFetchDraft) {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = api.fetchNotificationStatus(draft) {
            [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case .success(let status):
                if status.hasNewNotification {
                    NotificationCenter.default.post(
                        name: .newNotificationReceieved,
                        object: self,
                        userInfo: nil
                    )
                    return
                }
            case .failure:
                break
            }

        }
    }
}
