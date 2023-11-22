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

//   WCSessionExpirationDateSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionExpirationDateSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init(_ wcV2Session: WalletConnectV2Session) {
        bindTitle(wcV2Session)
        bindAccessory(wcV2Session)
    }
}

extension WCSessionExpirationDateSecondaryListItemViewModel {
    private mutating func bindTitle(_ wcV2Session: WalletConnectV2Session) {
        title =
            "wc-session-expiration-date"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindAccessory(_ wcV2Session: WalletConnectV2Session) {
        accessory = WCSessionExpirationDateSecondaryListItemValueViewModel(wcV2Session)
    }
}

fileprivate struct WCSessionExpirationDateSecondaryListItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init(_ wcV2Session: WalletConnectV2Session) {
        bindTitle(wcV2Session)
    }
}

extension WCSessionExpirationDateSecondaryListItemValueViewModel {
    private mutating func bindTitle(_ wcV2Session: WalletConnectV2Session) {
        let dateFormat = "MMM d, yyyy, h:mm a"
        let formattedDate = wcV2Session.expiryDate.toFormat(dateFormat)
        let date = formattedDate.footnoteRegular(lineBreakMode: .byTruncatingTail)

        var hourAttributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
        hourAttributes.insert(.textColor(Colors.Text.gray))

        let hourFormat = "h:mm a"
        let hour = wcV2Session.expiryDate.toFormat(hourFormat)
        let aTitle = date.addAttributes(
            to: hour,
            newAttributes: hourAttributes
        )
        title = aTitle
    }
}
