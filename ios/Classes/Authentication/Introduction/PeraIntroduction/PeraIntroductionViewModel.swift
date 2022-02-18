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

//   PeraIntroductionViewModel.swift

import Foundation
import MacaroonUIKit

struct PeraIntroductionViewModel: ViewModel {
    private(set) var logoImage: Image?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var description: EditText?

    init() {
        bind()
    }
}

extension PeraIntroductionViewModel {
    private mutating func bind() {
        bindLogoImage()
        bindTitle()
        bindSubtitle()
        bindDescription()
    }

    private mutating func bindLogoImage() {
        logoImage = "icon-logo"
    }

    private mutating func bindTitle() {
        let font = Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23

        title = .attributedString(
            "pera-announcement-title"
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }

    private mutating func bindSubtitle() {
        let font = Fonts.DMSans.medium.make(32).uiFont
        let lineHeightMultiplier = 0.96

        subtitle = .attributedString(
            "pera-announcement-subtitle"
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }

    private mutating func bindDescription() {
        let font = Fonts.DMMono.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23

        description = .attributedString(
            "pera-announcement-description"
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
                .appendAttributesToRange(
                    [
                        .foregroundColor: AppColors.Components.Link.primary.uiColor,
                        .font: font
                    ],
                    of: "pera-announcement-description-blog".localized
                )
        )
    }
}
