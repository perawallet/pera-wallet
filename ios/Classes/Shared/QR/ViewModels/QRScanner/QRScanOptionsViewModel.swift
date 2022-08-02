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

//   QRScanOptionsViewModel.swift

import MacaroonUIKit

struct QRScanOptionsViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var address: EditText?

    init(
        _ address: PublicKey
    ) {
        bindTitle()
        bindAddress(address)
    }

    private mutating func bindTitle() {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        title = .attributedString(
            "qr-scan-option-scanned-title".localized.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.left)
                ])
            ])
        )
    }

    private mutating func bindAddress(
        _ address: PublicKey
    ) {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        self.address = .attributedString(
            address.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.left)
                ])
            ])
        )
    }
}
