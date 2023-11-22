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

//   RemoveAccountSheet.swift

import Foundation

final class RemoveAccountSheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let account: Account
    private let sharedDataController: SharedDataController
    private let peraConnect: PeraConnect
    private let eventHandler: EventHandler

    init(
        account: Account,
        sharedDataController: SharedDataController,
        peraConnect: PeraConnect,
        eventHandler: @escaping EventHandler
    ) {
        self.account = account
        self.sharedDataController = sharedDataController
        self.peraConnect = peraConnect
        self.eventHandler = eventHandler

        let title =
            "options-remove-account"
                .localized
                .bodyLargeMedium(alignment: .center)
        let body =
            "options-remove-account-explanation"
                .localized
                .bodyRegular(alignment: .center)

        super.init(
            image: "icon-trash-red",
            title: title,
            body: UISheetBodyTextProvider(text: body)
        )

        let confirmAction = makeConfirmAction()
        addAction(confirmAction)

        let cancelAction = makeCancelAction()
        addAction(cancelAction)
    }
}

extension RemoveAccountSheet {
    private func makeConfirmAction() -> UISheetAction {
        return UISheetAction(
            title: "title-remove".localized,
            style: .default
        ) {
            [unowned self] in
            self.removeAccount()
            self.eventHandler(.didRemoveAccount)
        }
    }

    private func removeAccount() {
        sharedDataController.resetPollingAfterRemoving(account)
        peraConnect.updateSessionsWithRemovingAccount(account)
    }

    private func makeCancelAction() -> UISheetAction {
        return UISheetAction(
            title: "title-keep".localized,
            style: .cancel
        ) {
            [unowned self] in
            self.eventHandler(.didCancel)
        }
    }
}

extension RemoveAccountSheet {
    enum Event {
        case didRemoveAccount
        case didCancel
    }
}
