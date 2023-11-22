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

//   WCSessionConnectionDateSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionConnectionDateSecondaryListItemViewModel: SecondaryListItemViewModel {
    private(set) var title: TextProvider?
    private(set) var accessory: SecondaryListItemValueViewModel?

    init(
        draft: WCSessionDraft,
        wcV2SessionConnectionDate: Date?
    ) {
        bindTitle()
        bindAccessory(
            draft: draft,
            wcV2SessionConnectionDate: wcV2SessionConnectionDate
        )
    }
}

extension WCSessionConnectionDateSecondaryListItemViewModel {
    private mutating func bindTitle() {
        title =
            "wc-session-connection-date"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindAccessory(
        draft: WCSessionDraft,
        wcV2SessionConnectionDate: Date?
    ) {
        accessory = WCSessionConnectionDateSecondaryListItemValueViewModel(
            draft: draft,
            wcV2SessionConnectionDate: wcV2SessionConnectionDate
        )
    }
}

fileprivate struct WCSessionConnectionDateSecondaryListItemValueViewModel: SecondaryListItemValueViewModel {
    private(set) var icon: ImageStyle?
    private(set) var title: TextProvider?

    init(
        draft: WCSessionDraft,
        wcV2SessionConnectionDate: Date?
    ) {
        bindTitle(
            draft: draft,
            wcV2SessionConnectionDate: wcV2SessionConnectionDate
        )
    }
}

extension WCSessionConnectionDateSecondaryListItemValueViewModel {
    private mutating func bindTitle(
        draft: WCSessionDraft,
        wcV2SessionConnectionDate: Date?
    ) {
        if let wcV1Session = draft.wcV1Session {
            bindTitle(wcV1Session)
            return
        }

        if draft.isWCv2Session {
            bindTitle(wcV2SessionConnectionDate: wcV2SessionConnectionDate)
            return
        }

        title = nil
    }

    private mutating func bindTitle(_ wcV1Session: WCSession) {
        let dateFormat = "MMM d, yyyy, h:mm a"
        let formattedDate = wcV1Session.date.toFormat(dateFormat)
        let date = formattedDate.footnoteRegular(lineBreakMode: .byTruncatingTail)

        var hourAttributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
        hourAttributes.insert(.textColor(Colors.Text.gray))

        let hourFormat = "h:mm a"
        let hour = wcV1Session.date.toFormat(hourFormat)
        let aTitle = date.addAttributes(
            to: hour,
            newAttributes: hourAttributes
        )
        title = aTitle
    }

    private mutating func bindTitle(wcV2SessionConnectionDate: Date?) {
        guard let wcV2SessionConnectionDate else {
            title = nil
            return
        }

        let dateFormat = "MMM d, yyyy, h:mm a"
        let formattedDate = wcV2SessionConnectionDate.toFormat(dateFormat)
        let date = formattedDate.footnoteRegular(lineBreakMode: .byTruncatingTail)

        var hourAttributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
        hourAttributes.insert(.textColor(Colors.Text.gray))

        let hourFormat = "h:mm a"
        let hour = wcV2SessionConnectionDate.toFormat(hourFormat)
        let aTitle = date.addAttributes(
            to: hour,
            newAttributes: hourAttributes
        )
        title = aTitle
    }
}
