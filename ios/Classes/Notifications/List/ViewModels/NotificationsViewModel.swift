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

import MacaroonUIKit
import MacaroonURLImage
import Prism
import SwiftDate
import UIKit

final class NotificationsViewModel: Hashable {
    private(set) var icon: ImageSource?
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
        guard let notificationIcon = notification.icon,
              let notificationIconURL = notificationIcon.logo else {
            icon = AssetImageSource(asset: "notification-icon-default".uiImage)
            return
        }
        
        let size = CGSize(width: 40, height: 40)
        let shape: ImageShape = notificationIcon.shape?.convertToImageShape() ?? .circle
        let url = PrismURL(baseURL: notificationIconURL)?
            .setExpectedImageSize(size)
            .build()
        let placeholder = ImagePlaceholder(image: .init(asset: "notification-icon-default".uiImage))
        
        icon = DefaultURLImageSource(
            url: url,
            shape: shape,
            placeholder: placeholder
        )
    }

    private func bindTitle(notification: NotificationMessage) {
        guard let aTitle = notification.message else {
            title = nil
            return
        }

        title =  aTitle.bodyRegular()
    }

    private func bindTime(notification: NotificationMessage) {
        if let notificationDate = notification.date {
            time = (Date() - notificationDate).ago.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.autoUpdating)
        } else {
            time = nil
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
