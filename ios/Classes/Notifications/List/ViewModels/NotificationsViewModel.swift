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
//  NotificationsViewModel.swift

import UIKit
import SwiftDate

final class NotificationsViewModel: Hashable {
    private(set) var notificationImage: UIImage?
    private(set) var title: NSAttributedString?
    private(set) var time: String?
    private(set) var isRead: Bool = true

    private let notificationMessage: NotificationMessage
    
    init(
        notification: NotificationMessage,
        latestReadTimestamp: TimeInterval? = nil
    ) {
        self.notificationMessage = notification

        bindImage(notification: notification)
        bindTitle(notification: notification)
        bindTime(notification: notification)
        bindIsRead(notification: notification, latestReadTimestamp: latestReadTimestamp)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(notificationMessage.id)
    }

    static func == (lhs: NotificationsViewModel, rhs: NotificationsViewModel) -> Bool {
        lhs.notificationMessage.id == rhs.notificationMessage.id
    }
}

extension NotificationsViewModel {
    private func bindImage(notification: NotificationMessage) {
        let isFailedTransaction = notification.url == nil

        if isFailedTransaction {
            notificationImage = img("img-nc-failed")
        } else {
            notificationImage = img("icon-algo-circle")
        }
    }

    private func bindTitle(notification: NotificationMessage) {
        guard let aTitle = notification.message else {
            return
        }

        title =  aTitle.bodyRegular()
    }

    private func bindTime(notification: NotificationMessage) {
        if let notificationDate = notification.date {
            time = (Date() - notificationDate).ago.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.autoUpdating)
        }
    }

    private func bindIsRead(notification: NotificationMessage, latestReadTimestamp: TimeInterval?) {
        guard let notificationLatestFetchTimestamp = latestReadTimestamp,
            let notificationDate = notification.date else {
            isRead = false
            return
        }

        isRead = notificationDate.timeIntervalSince1970 < notificationLatestFetchTimestamp
    }
}
