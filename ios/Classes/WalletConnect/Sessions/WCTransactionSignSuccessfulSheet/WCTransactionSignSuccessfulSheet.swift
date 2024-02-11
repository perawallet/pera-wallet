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

//   WCTransactionSignSuccessfulSheet.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCTransactionSignSuccessfulSheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let eventHandler: EventHandler

    init(
        draft: WCSessionDraft,
        pairExpiryDate: Date?,
        eventHandler: @escaping EventHandler
    ) {
        self.eventHandler = eventHandler

        let title = Self.makeTitle(draft)
        let body = Self.makeBody(draft)
        let info = Self.makeInfo(
            draft: draft,
            pairExpiryDate: pairExpiryDate
        )

        super.init(
            image: "icon-info-orange",
            title: title,
            body: body,
            info: info
        )

        let closeAction = makeCloseAction()
        addAction(closeAction)
    }
}

extension WCTransactionSignSuccessfulSheet {
    private static func makeTitle(_ draft: WCSessionDraft) -> TextProvider? {
        return
            "wc-transaction-request-signed-warning-title"
                .localized
                .bodyLargeMedium(alignment: .center)
    }

    private static func makeBody(_ draft: WCSessionDraft) -> UISheetBodyTextProvider? {
        if let wcV1Session = draft.wcV1Session {
            return Self.makeBodyForWCv1(wcV1Session)
        }

        if let wcV2Session = draft.wcV2Session {
            return Self.makeBodyForWCv2(wcV2Session)
        }

        return nil
    }

    private static func makeInfo(
        draft: WCSessionDraft,
        pairExpiryDate: Date?
    ) -> TextProvider? {
        if draft.isWCv1Session {
            return nil
        }

        if let wcV2Session = draft.wcV2Session {
            return Self.makeInfoForWCv2(
                wcV2Session: wcV2Session,
                pairExpiryDate: pairExpiryDate
            )
        }

        return nil
    }

    private func makeCloseAction() -> UISheetAction {
        return UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) {
            [unowned self] in
            self.eventHandler(.didClose)
        }
    }
}

extension WCTransactionSignSuccessfulSheet {
    private static func makeBodyForWCv1(_ wcV1Session: WCSession) -> UISheetBodyTextProvider {
        let dAppName = wcV1Session.peerMeta.name
        let aBody = "wc-transaction-request-signed-warning-message"
            .localized(params: dAppName, dAppName)
            .bodyRegular(alignment: .center)
        return UISheetBodyTextProvider(text: aBody)
    }

    private static func makeBodyForWCv2(_ wcV2Session: WalletConnectV2Session) -> UISheetBodyTextProvider {
        let dAppName = wcV2Session.peer.name
        let aBody = "wc-transaction-request-signed-warning-message"
            .localized(params: dAppName, dAppName)
            .bodyRegular(alignment: .left)
        return UISheetBodyTextProvider(text: aBody)
    }
}

extension WCTransactionSignSuccessfulSheet {
    private static func makeInfoForWCv2(
        wcV2Session: WalletConnectV2Session,
        pairExpiryDate: Date?
    ) -> TextProvider? {
        guard let pairExpiryDate else {
            return nil
        }

        let expiryDate = wcV2Session.expiryDate
        let extendedDate = expiryDate.addingTimeInterval(TimeInterval(WalletConnectV2Session.defaultTimeToLive))
        guard extendedDate > pairExpiryDate else {
            return nil
        }

        let dateFormat = "MMM d, yyyy"
        let formattedDate = pairExpiryDate.toFormat(dateFormat)

        var textAttributes = Typography.footnoteRegularAttributes(alignment: .left)
        textAttributes.insert(.textColor(Colors.Text.gray))
        let text =
            "wc-transaction-request-signed-warning-info"
                .localized(params: formattedDate)
                .attributed(textAttributes)

        let maxExtendableToDateAttributes = Typography.footnoteMediumAttributes(alignment: .left)
        let aInfo = text.addAttributes(
            to: formattedDate,
            newAttributes: maxExtendableToDateAttributes
        )
        return aInfo
    }
}

extension WCTransactionSignSuccessfulSheet {
    enum Event {
        case didClose
    }
}
