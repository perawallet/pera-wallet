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

//   AccountPreviewTitleViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct AccountPreviewTitleViewModel:
    PrimaryTitleViewModel,
    Hashable {
    private(set) var primaryTitle: MacaroonUIKit.TextProvider?
    private(set) var primaryTitleAccessory: MacaroonUIKit.Image?
    private(set) var secondaryTitle: MacaroonUIKit.TextProvider?

    init(account: Account) {
        bindPrimaryTitle(account: account)
        bindSecondaryTitle(account: account)
    }

    init(
        primaryTitle: String?,
        secondaryTitle: String?
    ) {
        self.primaryTitle = getPrimaryTitle(primaryTitle)
        self.secondaryTitle = getSecondaryTitle(secondaryTitle)
    }
}

extension AccountPreviewTitleViewModel {
    mutating func bindPrimaryTitle(account: Account) {
        primaryTitle = getPrimaryTitle(account.primaryDisplayName)
    }

    mutating func bindSecondaryTitle(account: Account) {
        secondaryTitle = getSecondaryTitle(account.secondaryDisplayName)
    }
}

extension AccountPreviewTitleViewModel {
    func getPrimaryTitle(_ aTitle: String?) -> TextProvider? {
        guard let aTitle = aTitle else {
            return nil
        }

        return aTitle.bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    func getSecondaryTitle(_ aTitle: String?) -> TextProvider? {
        guard let aTitle = aTitle else {
            return nil
        }

        return aTitle.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
