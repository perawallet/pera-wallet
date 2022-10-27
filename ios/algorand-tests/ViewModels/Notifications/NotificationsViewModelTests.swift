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
//  NotificationsViewModelTests.swift

import Foundation
import MacaroonUtils
import XCTest

@testable import pera_staging

class NotificationsViewModelTests: XCTestCase {

    private let notification = Bundle.main.decode(response: NotificationMessage.self, from: "NotificationMessage.json")
    private let account = Bundle.main.decode(response: Account.self, from: "AccountA.json")

//    func testNotificationMessageSenderAccount() {
//        let viewModel = NotificationsViewModel(notification: notification, senderAccount: account, latestReadTimestamp: 3000)
//        XCTAssertEqual(viewModel.title?.string, "Your transaction of 55.555555 Algos from Chase to MF5KP5...RGQRHI is complete.")
//    }
//
//    func testNotificationMessageReceiverAccount() {
//        let viewModel = NotificationsViewModel(notification: notification, receiverAccount: account, latestReadTimestamp: 3000)
//        XCTAssertEqual(viewModel.title?.string, "Your transaction of 55.555555 Algos from T4EWBD...UU6QRM to MF5KP5...RGQRHI is complete.")
//    }

    func testIsRead() {
//        let viewModel = NotificationsViewModel(notification: notification, senderAccount: account, latestReadTimestamp: 3000)
//        XCTAssertFalse(viewModel.isRead)
    }
}
