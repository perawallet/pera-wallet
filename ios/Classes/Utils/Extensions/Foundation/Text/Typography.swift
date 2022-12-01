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

//   Typography.swift

import UIKit
import MacaroonUIKit

enum Typography {}

// MARK: - Title

extension Typography {
    static func largeTitleMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.largeTitleMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.02

        return [
            .font(font),
            .letterSpacing(-0.36),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func largeTitleMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 36
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .largeTitle).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }

    static func largeTitleRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.largeTitleRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.02

        return [
            .font(font),
            .letterSpacing(-0.36),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func largeTitleRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 36
        let font = supportsDynamicType
            ? Fonts.DMSans.regular.make(size, .largeTitle).uiFont
            : Fonts.DMSans.regular.make(size).uiFont

        return font
    }

    static func largeTitleMonoMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.largeTitleMonoMediumAttributes(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.02

        return [
            .font(font),
            .letterSpacing(-0.72),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func largeTitleMonoMediumAttributes(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 36
        let font = supportsDynamicType
            ? Fonts.DMMono.medium.make(size, .largeTitle).uiFont
            : Fonts.DMMono.medium.make(size).uiFont

        return font
    }

    static func largeTitleMonoRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.largeTitleMonoRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.02

        return [
            .font(font),
            .letterSpacing(-0.72),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func largeTitleMonoRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 36
        let font = supportsDynamicType
            ? Fonts.DMMono.regular.make(size, .largeTitle).uiFont
            : Fonts.DMMono.regular.make(size).uiFont

        return font
    }

    static func titleBoldAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.titleBold(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 0.96

        return [
            .font(font),
            .letterSpacing(-0.32),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func titleBold(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 32
        let font = supportsDynamicType
            ? Fonts.DMSans.bold.make(size, .largeTitle).uiFont
            : Fonts.DMSans.bold.make(size).uiFont

        return font
    }

    static func titleMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.titleMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 0.96

        return [
            .font(font),
            .letterSpacing(-0.32),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func titleMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 32
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .title1).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }

    static func titleMonoRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.titleMonoRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 0.85

        return [
            .font(font),
            .letterSpacing(-0.72),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func titleMonoRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 36
        let font = supportsDynamicType
            ? Fonts.DMMono.regular.make(size, .title1).uiFont
            : Fonts.DMMono.regular.make(size).uiFont

        return font
    }

    static func titleSmallBoldAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.titleSmallBold(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 0.99

        return [
            .font(font),
            .letterSpacing(-0.28),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func titleSmallBold(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 28
        let font = supportsDynamicType
            ? Fonts.DMSans.regular.make(size, .title2).uiFont
            : Fonts.DMSans.regular.make(size).uiFont

        return font
    }

    static func titleSmallMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.titleSmallMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 0.99

        return [
            .font(font),
            .letterSpacing(-0.28),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func titleSmallMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 28
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .title2).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }
}

// MARK: - Body

extension Typography {
    static func bodyLargeMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyLargeMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.13

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyLargeMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 19
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .body).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }

    static func bodyLargeRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyLargeRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.13

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyLargeRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 19
        let font = supportsDynamicType
            ? Fonts.DMSans.regular.make(size, .body).uiFont
            : Fonts.DMSans.regular.make(size).uiFont

        return font
    }

    static func bodyLargeMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyLargeMonoRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.13

        return [
            .font(font),
            .letterSpacing(-0.38),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyLargeMonoRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 19
        let font = supportsDynamicType
            ? Fonts.DMMono.regular.make(size, .body).uiFont
            : Fonts.DMMono.regular.make(size).uiFont

        return font
    }

    static func bodyBoldAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyBold(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.23

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyBold(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 15
        let font = supportsDynamicType
            ? Fonts.DMSans.bold.make(size, .body).uiFont
            : Fonts.DMSans.bold.make(size).uiFont

        return font
    }

    static func bodyMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.23

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 15
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .body).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }

    static func bodyRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.23
        
        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 15
        let font = supportsDynamicType
            ? Fonts.DMSans.regular.make(size, .body).uiFont
            : Fonts.DMSans.regular.make(size).uiFont

        return font
    }

    static func bodyMonoMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyMonoMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.23

        return [
            .font(font),
            .letterSpacing(-0.3),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyMonoMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 15
        let font = supportsDynamicType
            ? Fonts.DMMono.medium.make(size, .body).uiFont
            : Fonts.DMMono.medium.make(size).uiFont

        return font
    }

    static func bodyMonoRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.bodyMonoRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.23

        return [
            .font(font),
            .letterSpacing(-0.3),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func bodyMonoRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 15
        let font = supportsDynamicType
            ? Fonts.DMMono.regular.make(size, .body).uiFont
            : Fonts.DMMono.regular.make(size).uiFont

        return font
    }
}

// MARK: - Footnote

extension Typography {
    static func footnoteHeadingMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.footnoteHeadingMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.18

        return [
            .font(font),
            .letterSpacing(1.04),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func footnoteHeadingMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 13
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .footnote).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }

    static func footnoteBoldAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.footnoteBold(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.18

        return [
            .font(font),
            .letterSpacing(-0.07),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func footnoteBold(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 13
        let font = supportsDynamicType
            ? Fonts.DMSans.bold.make(size, .footnote).uiFont
            : Fonts.DMSans.bold.make(size).uiFont

        return font
    }

    static func footnoteMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.footnoteMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.18

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func footnoteMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 13
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .footnote).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }

    static func footnoteRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.footnoteRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.18

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func footnoteRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 13
        let font = supportsDynamicType
            ? Fonts.DMSans.regular.make(size, .footnote).uiFont
            : Fonts.DMSans.regular.make(size).uiFont

        return font
    }

    static func footnoteMonoMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.footnoteMonoMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.18

        return [
            .font(font),
            .letterSpacing(-0.26),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func footnoteMonoMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 13
        let font = supportsDynamicType
            ? Fonts.DMMono.medium.make(size, .footnote).uiFont
            : Fonts.DMMono.medium.make(size).uiFont

        return font
    }

    static func footnoteMonoRegularAttributes(
        alignment: NSTextAlignment = .center,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.footnoteMonoRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.18

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func footnoteMonoRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 13
        let font = supportsDynamicType
            ? Fonts.DMMono.regular.make(size, .footnote).uiFont
            : Fonts.DMMono.regular.make(size).uiFont

        return font
    }
}

// MARK: - Caption

extension Typography {
    static func captionBoldAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.captionBold(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.12

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func captionBold(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 11
        let font = supportsDynamicType
            ? Fonts.DMSans.bold.make(size, .caption1).uiFont
            : Fonts.DMSans.bold.make(size).uiFont

        return font
    }

    static func captionMediumAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.captionMedium(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.12

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func captionMedium(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 11
        let font = supportsDynamicType
            ? Fonts.DMSans.medium.make(size, .caption1).uiFont
            : Fonts.DMSans.medium.make(size).uiFont

        return font
    }

    static func captionRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.captionRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.12

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func captionRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 11
        let font = supportsDynamicType
            ? Fonts.DMSans.regular.make(size, .caption1).uiFont
            : Fonts.DMSans.regular.make(size).uiFont

        return font
    }

    static func captionMonoRegularAttributes(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> TextAttributeGroup {
        let font = Self.captionMonoRegular(supportsDynamicType: supportsDynamicType)
        let lineHeightMultiplier = 1.12

        return [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(alignment),
                .lineBreakMode(lineBreakMode),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]
    }

    static func captionMonoRegular(
        supportsDynamicType: Bool = false
    ) -> UIFont {
        let size = 11
        let font = supportsDynamicType
            ? Fonts.DMMono.regular.make(size, .caption1).uiFont
            : Fonts.DMMono.regular.make(size).uiFont

        return font
    }
}
