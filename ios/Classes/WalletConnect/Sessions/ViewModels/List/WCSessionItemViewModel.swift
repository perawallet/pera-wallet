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

//
//   WCSessionItemViewModel.swift

import CoreGraphics
import MacaroonUIKit
import SwiftDate
import MacaroonURLImage
import Foundation

struct WCSessionItemViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var name: EditText?
    private(set) var description: EditText?
    private(set) var date: EditText?
    private(set) var accounts: [WCSessionAccountStatusViewModel?]?
    
    init(
        peermeta: WCPeerMeta,
        sessionDate: Date,
        accountList: [Account]
    ) {
        bindImage(peermeta)
        bindName(peermeta)
        bindDescription(peermeta)
        bindDate(sessionDate)
        bindAccounts(accountList)
    }
}

extension WCSessionItemViewModel {
    private mutating func bindImage(_ peerMeta: WCPeerMeta) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]

        let placeholder = ImagePlaceholder(
            image: AssetImageSource(asset: placeholderImages.randomElement()!.uiImage)
        )

        image = DefaultURLImageSource(
            url: peerMeta.icons.first,
            size: .resize(CGSize(width: 40, height: 40), .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private mutating func bindName(_ peerMeta: WCPeerMeta) {
        name = .attributedString(
            peerMeta.name
                .bodyMedium(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }

    private mutating func bindDescription(_ peerMeta: WCPeerMeta) {
        guard let aDescription = peerMeta.description,
              !aDescription.isEmptyOrBlank else {
            return
        }

        description = .attributedString(
            aDescription
                .footnoteRegular()
        )
    }

    private mutating func bindDate(_ sessionDate: Date) {
        let formattedDate = sessionDate.toFormat("MMMM dd, yyyy - HH:mm")

        self.date = .attributedString(
            formattedDate
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
    
    private mutating func bindAccounts(_ accountList: [Account]) {
        accounts = []
        
        accountList.forEach {
            let accountStatusViewModel = WCSessionAccountStatusViewModel(account: $0)
            accounts?.append(accountStatusViewModel)
        }
    }
}
