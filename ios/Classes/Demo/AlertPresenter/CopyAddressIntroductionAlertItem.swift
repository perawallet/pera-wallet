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

//   CopyAddressIntroductionAlertItem.swift

import Foundation

final class CopyAddressIntroductionAlertItem:
    AlertItem,
    Storable {
    typealias Object = Any

    var isAvailable: Bool { checkAvailability() }

    unowned let delegate: CopyAddressIntroductionAlertItemDelegate

    private lazy var isSeen: Bool? = userDefaults.object(forKey: isSeenKey) as? Bool {
        didSet { saveIsSeen() }
    }
    private let isSeenKey: String = "promotion.dialog.copyAddress"

    init(delegate: CopyAddressIntroductionAlertItemDelegate) {
        self.delegate = delegate
    }
}

extension CopyAddressIntroductionAlertItem {
    func makeAlert() -> Alert {
        isSeen = true

        let title = "story-copy-address-title"
            .localized
            .bodyLargeMedium(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let body = "story-copy-address-description"
            .localized
            .footnoteRegular(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let alert = Alert(
            image: "copy-address-story",
            title: title,
            body: body
        )

        let gotItAction = makeGotItAction()
        alert.addAction(gotItAction)

        return alert
    }

    func cancel() {
        isSeen = isSeen ?? false
    }
}

extension CopyAddressIntroductionAlertItem {
    private func makeGotItAction() -> AlertAction {
        return AlertAction(
            title: "title-got-it".localized,
            style: .secondary
        ) {
            [unowned self] in
            self.delegate.copyAddressIntroductionAlertItemDidPerformGotIt(self)
        }
    }
}

extension CopyAddressIntroductionAlertItem {
    private func checkAvailability() -> Bool {
        if isSeen == nil {
            /// <note>
            /// According to the handling the underlying value in the previous versions, if the
            /// `appOpenCount` is more than 1 in the first launch, fresh or update, it means the
            /// dialog had already been seen by the user.
            let appLaunchStore = ALGAppLaunchStore()
            let isAlreadySeenInPreviousReleases = appLaunchStore.appOpenCount > 1
            isSeen = isAlreadySeenInPreviousReleases
        }

        return !(isSeen!)
    }
}

extension CopyAddressIntroductionAlertItem {
    private func saveIsSeen() {
        userDefaults.set(
            isSeen,
            forKey: isSeenKey
        )
    }
}

protocol CopyAddressIntroductionAlertItemDelegate: AnyObject {
    func copyAddressIntroductionAlertItemDidPerformGotIt(_ item: CopyAddressIntroductionAlertItem)
}
