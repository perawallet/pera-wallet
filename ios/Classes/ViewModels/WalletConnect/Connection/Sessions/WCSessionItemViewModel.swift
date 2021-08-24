// Copyright 2019 Algorand, Inc.

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

import UIKit
import Macaroon
import SwiftDate

class WCSessionItemViewModel {
    private(set) var image: ImageSource?
    private(set) var name: String?
    private(set) var description: String?
    private(set) var status: String?
    private(set) var date: String?

    private let placeholderImages = [
        img("icon-session-placeholder-1"),
        img("icon-session-placeholder-2"),
        img("icon-session-placeholder-3"),
        img("icon-session-placeholder-4")
    ]

    init(session: WCSession) {
        setImage(from: session)
        setName(from: session)
        setDescription(from: session)
        setStatus(from: session)
        setDate(from: session)
    }

    private func setImage(from session: WCSession) {
        let randomIndex = Int.random(in: 0..<placeholderImages.count)
        let placeholderImage = placeholderImages[safe: randomIndex]

        image = PNGImageSource(
            url: session.peerMeta.icons.first,
            color: nil,
            size: .resize(CGSize(width: 40.0, height: 40.0), .aspectFit),
            shape: .circle,
            placeholder: ImagePlaceholder(image: AssetImageSource(asset: placeholderImage), text: nil),
            forceRefresh: false
        )
    }

    private func setName(from session: WCSession) {
        name = session.peerMeta.name
    }

    private func setDescription(from session: WCSession) {
        description = session.peerMeta.description
    }

    private func setStatus(from session: WCSession) {
        if let connectedAccount = session.walletMeta?.accounts?.first {
            status = "wallet-connect-session-connected-with-account".localized(params: connectedAccount.shortAddressDisplay())
            return
        }

        status = "wallet-connect-session-connected".localized
    }

    private func setDate(from session: WCSession) {
        date = session.date.toFormat("MMMM dd, yyyy - HH:mm")
    }
}
