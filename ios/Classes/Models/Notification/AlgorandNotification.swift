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
//  AlgorandNotification.swift

import Magpie

class AlgorandNotification: Model {
    let badge: Int?
    let alert: String?
    let details: NotificationDetail?
    let sound: String?
}

extension AlgorandNotification {
    func getAccountId() -> String? {
        guard let notificationDetails = details,
              let notificationType = notificationDetails.notificationType else {
                return nil
        }

        switch notificationType {
        case .transactionReceived,
             .assetTransactionReceived:
            return notificationDetails.receiverAddress
        case .transactionSent,
             .assetTransactionSent:
            return notificationDetails.senderAddress
        case .assetSupportRequest:
            return notificationDetails.receiverAddress
        case .assetSupportSuccess:
            return notificationDetails.receiverAddress
        case .broadcast:
            return nil
        default:
            return nil
        }
    }
}

extension AlgorandNotification {
    enum CodingKeys: String, CodingKey {
        case badge = "badge"
        case alert = "alert"
        case details = "custom"
        case sound = "sound"
    }
}
