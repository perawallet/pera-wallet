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

//   SelectedAccountPreviewViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct SelectedAccountPreviewViewModel:
    BindableViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var value: EditText?

    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension SelectedAccountPreviewViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let draft = model as? IconWithShortAddressDraft {
            bind(draft: draft)
            return
        }
    }
}

extension SelectedAccountPreviewViewModel {
    mutating func bind(
        draft: IconWithShortAddressDraft
    ) {
        let account = draft.account

        bindIcon(draft.account.typeImage)
        bindTitle("collectible-receive-asset-list-selected-account".localized)

        let value = account.primaryDisplayName

        bindValue(value)
    }
}

extension SelectedAccountPreviewViewModel {
    mutating func bindIcon(
        _ someIcon: UIImage?
    ) {
        icon = someIcon
    }

    mutating func bindTitle(
        _ someTitle: String?
    ) {
        title = getTitle(someTitle)
    }

    mutating func bindValue(
        _ someMessage: String?
    ) {
        value = getValue(someMessage)
    }
}

extension SelectedAccountPreviewViewModel {
    func getTitle(
        _ aTitle: String?
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        return .attributedString(
            aTitle
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }

    func getValue(
        _ aValue: String?
    ) -> EditText? {
        guard let aValue = aValue else {
            return nil
        }

        return .attributedString(
            aValue
                .bodyRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}
