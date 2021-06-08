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
//  Notification.Name+Additions.swift

import Foundation

extension Notification.Name {
    static var AuthenticatedUserUpdate: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.authenticated.user.update")
    }

    static var ApplicationWillEnterForeground: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.application.WillEnterForeground")
    }

    static var AccountUpdate: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.account.update")
    }
    
    static var ContactAddition: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.contact.addition")
    }

    static var ContactEdit: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.contact.edit")
    }

    static var ContactDeletion: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.contact.deletion")
    }
    
    static var NetworkChanged: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.network.change")
    }
    
    static var DeviceIDDidSet: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.device.id.set")
    }
    
    static var NotificationDidReceived: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.received")
    }
}
