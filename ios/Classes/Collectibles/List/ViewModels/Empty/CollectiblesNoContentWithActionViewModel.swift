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

//   CollectiblesNoContentWithActionViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectiblesNoContentWithActionViewModel: NoContentWithActionViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var body: EditText?
    private(set) var actionTitle: EditText?

    init() {
        bindIcon()
        bindTitle()
        bindBody()
        bindActionTitle()
    }
}

extension CollectiblesNoContentWithActionViewModel {
    private mutating func bindIcon() {
        icon = "img-collectible-empty"
    }

    private mutating func bindTitle() {
        let font = Fonts.DMSans.medium.make(32)
        let lineHeightMultiplier = 0.96

        title = .attributedString(
            "collectibles-empty-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.center)
                    ])
                ])
        )
    }

    private mutating func bindBody() {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        body = .attributedString(
            "collectibles-empty-body"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.center)
                    ])
                ])
        )
    }

    private mutating func bindActionTitle() {
        actionTitle = .string("collectibles-receive-action".localized)
    }
}
