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

//   BackUpBeforeRemovingAccountWarningSheet.swift

import Foundation

final class BackUpBeforeRemovingAccountWarningSheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let eventHandler: EventHandler

    init(eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler

        let title =
            "back-up-before-removing-account-warning-title"
                .localized
                .bodyLargeMedium(alignment: .center)
        let body =
            "back-up-before-removing-account-warning-body"
                .localized
                .bodyRegular(alignment: .center)

        super.init(
            image: "icon-info-red",
            title: title,
            body: UISheetBodyTextProvider(text: body)
        )

        let confirmAction = makeConfirmAction()
        addAction(confirmAction)

        let cancelAction = makeCancelAction()
        addAction(cancelAction)
    }
}

extension BackUpBeforeRemovingAccountWarningSheet {
    private func makeConfirmAction() -> UISheetAction {
        return UISheetAction(
            title: "title-yes-continue".localized,
            style: .default
        ) {
            [unowned self] in
            self.eventHandler(.didConfirm)
        }
    }

    private func makeCancelAction() -> UISheetAction {
        return UISheetAction(
            title: "back-up-before-removing-account-warning-cancel-action".localized,
            style: .cancel
        ) {
            [unowned self] in
            self.eventHandler(.didCancel)
        }
    }
}

extension BackUpBeforeRemovingAccountWarningSheet {
    enum Event {
        case didConfirm
        case didCancel
    }
}
