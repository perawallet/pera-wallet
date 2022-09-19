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

//   AccountNamePreviewViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AccountNamePreviewViewModel:
    ViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var subtitle: EditText?

    init(
        account: Account,
        with alignment: NSTextAlignment
    ) {
        bind(
            account: account,
            with: alignment
        )
    }

    init(
        title: String?,
        subtitle: String?,
        with alignment: NSTextAlignment
    ) {
        self.title = getTitle(
            title, with:
                alignment
        )
        self.subtitle = getSubtitle(
            subtitle,
            with: alignment
        )
    }
}

extension AccountNamePreviewViewModel {
    mutating func bind(
        account: Account,
        with alignment: NSTextAlignment
    ) {
        bindTitle(
            account: account,
            with: alignment
        )
        bindSubtitle(
            account: account,
            with: alignment
        )
    }
}

extension AccountNamePreviewViewModel {
    mutating func bindTitle(
        account: Account,
        with alignment: NSTextAlignment
    ) {
        let title: String = account.name.unwrap(
            or: account.address.shortAddressDisplay
        )

        self.title = getTitle(
            title,
            with: alignment
        )
    }

    mutating func bindSubtitle(
        account: Account,
        with alignment: NSTextAlignment
    ) {
        if account.type == .standard,
           let name = account.name,
           name == account.address.shortAddressDisplay {
            return
        }

        let subtitle: String? =
        (account.name != nil && account.name != account.address.shortAddressDisplay)
        ? account.address.shortAddressDisplay
        : account.typeTitle

        self.subtitle = getSubtitle(
            subtitle,
            with: alignment
        )
    }
}

extension AccountNamePreviewViewModel {
    func getTitle(
        _ aTitle: String?,
        with alignment: NSTextAlignment
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        return .attributedString(
            aTitle.bodyRegular(
                alignment: alignment,
                lineBreakMode: .byTruncatingTail
            )
        )
    }

    func getSubtitle(
        _ aTitle: String?,
        with alignment: NSTextAlignment
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        return .attributedString(
            aTitle.footnoteRegular(
                alignment: alignment,
                lineBreakMode: .byTruncatingTail
            )
        )
    }
}
