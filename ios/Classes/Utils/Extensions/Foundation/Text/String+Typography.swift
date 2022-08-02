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

//   String+Typography.swift

import Foundation
import MacaroonUIKit
import UIKit

// MARK: - Title

extension String {
    func largeTitleMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.medium.make(36, .largeTitle).uiFont
            : Fonts.DMSans.medium.make(36).uiFont
        let lineHeightMultiplier = 1.02

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.36),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func largeTitleRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.regular.make(36, .largeTitle).uiFont
            : Fonts.DMSans.regular.make(36).uiFont
        let lineHeightMultiplier = 1.02

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.36),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func largeTitleMonoMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.medium.make(36, .largeTitle).uiFont
            : Fonts.DMMono.medium.make(36).uiFont
        let lineHeightMultiplier = 1.02

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.72),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func largeTitleMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.regular.make(36, .largeTitle).uiFont
            : Fonts.DMMono.regular.make(36).uiFont
        let lineHeightMultiplier = 1.02

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.72),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func title1Bold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.bold.make(32, .largeTitle).uiFont
            : Fonts.DMSans.bold.make(32).uiFont
        let lineHeightMultiplier = 0.96

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.32),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func title1Medium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.medium.make(32, .title1).uiFont
            : Fonts.DMSans.medium.make(32).uiFont
        let lineHeightMultiplier = 0.96

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.32),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func title1MonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.regular.make(36, .title1).uiFont
            : Fonts.DMMono.regular.make(36).uiFont
        let lineHeightMultiplier = 0.85

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.72),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func title2Bold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.bold.make(28, .title2).uiFont
            : Fonts.DMSans.bold.make(28).uiFont
        let lineHeightMultiplier = 0.99

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.28),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func title2Medium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.medium.make(28, .title2).uiFont
            : Fonts.DMSans.medium.make(28).uiFont
        let lineHeightMultiplier = 0.99

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.28),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }
}

// MARK: - Body

extension String {
    func bodyLargeMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.medium.make(19, .body).uiFont
            : Fonts.DMSans.medium.make(19).uiFont
        let lineHeightMultiplier = 1.13

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func bodyLargeRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.regular.make(19, .body).uiFont
            : Fonts.DMSans.regular.make(19).uiFont
        let lineHeightMultiplier = 1.13

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func bodyLargeMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.regular.make(19, .body).uiFont
            : Fonts.DMMono.regular.make(19).uiFont
        let lineHeightMultiplier = 1.13

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.38),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func bodyBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.bold.make(15, .body).uiFont
            : Fonts.DMSans.bold.make(15).uiFont
        let lineHeightMultiplier = 1.23

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func bodyMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.medium.make(15, .body).uiFont
            : Fonts.DMSans.medium.make(15).uiFont
        let lineHeightMultiplier = 1.23

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func bodyRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.regular.make(15, .body).uiFont
            : Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func bodyMonoMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.medium.make(15, .body).uiFont
            : Fonts.DMMono.medium.make(15).uiFont
        let lineHeightMultiplier = 1.23

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.3),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func bodyMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.regular.make(15, .body).uiFont
            : Fonts.DMMono.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.3),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

}

// MARK: - Footnote

extension String {
    func footnoteBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.bold.make(13, .footnote).uiFont
            : Fonts.DMSans.bold.make(13).uiFont
        let lineHeightMultiplier = 1.18

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.07),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func footnoteMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.medium.make(13, .footnote).uiFont
            : Fonts.DMSans.medium.make(13).uiFont
        let lineHeightMultiplier = 1.18

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func footnoteRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.regular.make(13, .footnote).uiFont
            : Fonts.DMSans.regular.make(13).uiFont
        let lineHeightMultiplier = 1.18

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func footnoteMonoMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.medium.make(13, .footnote).uiFont
            : Fonts.DMMono.medium.make(13).uiFont
        let lineHeightMultiplier = 1.18

        return attributed(
            [
                .font(font),
                .letterSpacing(-0.26),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func footnoteMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.regular.make(13, .footnote).uiFont
            : Fonts.DMMono.regular.make(13).uiFont
        let lineHeightMultiplier = 1.18

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }
}

// MARK: - Caption

extension String {
    func captionBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.bold.make(11, .caption1).uiFont
            : Fonts.DMSans.bold.make(11).uiFont
        let lineHeightMultiplier = 1.12

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func captionMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.medium.make(11, .caption1).uiFont
            : Fonts.DMSans.medium.make(11).uiFont
        let lineHeightMultiplier = 1.12

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func captionRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMSans.regular.make(11, .caption1).uiFont
            : Fonts.DMSans.regular.make(11).uiFont
        let lineHeightMultiplier = 1.12

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }

    func captionMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        let font =
            supportsDynamicType
            ? Fonts.DMMono.regular.make(11, .caption1).uiFont
            : Fonts.DMMono.regular.make(11).uiFont
        let lineHeightMultiplier = 1.12

        return attributed(
            [
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(alignment),
                    .lineBreakMode(lineBreakMode),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ]
        )
    }
}
