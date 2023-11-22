// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BackUpAccountFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUtils

final class BackUpAccountFlowCoordinator: NotificationObserver {
    static let didBackupAccount =  Notification.Name(rawValue: "didBackUpAccount")
    static let didBackUpAccountNotificationAccountKey = "account"

    var notificationObservations: [NSObjectProtocol] = []

    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private unowned let presentingScreen: UIViewController
    private let api: ALGAPI

    init(
        presentingScreen: UIViewController,
        api: ALGAPI
    ) {
        self.presentingScreen = presentingScreen
        self.api =  api
    }

    deinit {
        stopObservingNotifications()
    }
}

extension BackUpAccountFlowCoordinator {
    func launch(_ notBackedUpAccount: AccountHandle) {
        startObservingDidBackupAccountNotification()

        openIntroduction(notBackedUpAccount)
    }

    func launch(_ notBackedUpAccounts: [AccountHandle]) {
        startObservingDidBackupAccountNotification()

        if notBackedUpAccounts.isSingular {
            guard let account = notBackedUpAccounts.first else {
                stopObservingNotifications()
                return
            }

            openIntroduction(account)
            return
        }

        openIntroduction()
    }
}

extension BackUpAccountFlowCoordinator {
    private func startObservingDidBackupAccountNotification() {
        observe(notification: Self.didBackupAccount) {
            [weak self] notification in
            guard let self else { return }
            let preferencesKey = Self.didBackUpAccountNotificationAccountKey
            let account = notification.userInfo?[preferencesKey] as? Account
            guard let account else { return }

            let accountHandle = AccountHandle(
                account: account,
                status: .ready
            )
            self.eventHandler?(.didBackUpAccount(accountHandle))

            self.presentingScreen.dismiss(animated: true)

            stopObservingNotifications()
        }
    }
}

extension BackUpAccountFlowCoordinator {
    private func openIntroduction(_ account: AccountHandle) {
        openIntroduction(account.value.address)
    }

    private func openIntroduction(_ address: String? = nil) {
        let needsAccountSelection = address == nil
        presentingScreen.open(
            .tutorial(
                flow: .addNewAccount(mode: .add),
                tutorial: .backUp(
                    flow: .backUpAccount(needsAccountSelection: needsAccountSelection),
                    address: address
                )
            ),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
    }
}

extension BackUpAccountFlowCoordinator {
    enum Event {
        case didBackUpAccount(AccountHandle)
    }
}
