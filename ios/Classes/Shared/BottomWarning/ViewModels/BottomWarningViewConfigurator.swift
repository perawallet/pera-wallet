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
//   BottomWarningViewConfigurator.swift

import UIKit
import MacaroonUIKit

struct BottomWarningViewConfigurator {
    private(set) var image: UIImage?
    private(set) var title: EditText?
    private(set) var description: BottomWarningDescription?
    private(set) var descriptionText: EditText?
    private(set) var primaryActionButtonTitle: EditText?
    private(set) var secondaryActionButtonTitle: EditText?
    private(set) var primaryAction: (() -> Void)?
    private(set) var secondaryAction: (() -> Void)?

    init(
        image: UIImage? = nil,
        title: String,
        description: BottomWarningViewConfigurator.BottomWarningDescription? = nil,
        primaryActionButtonTitle: String? = nil,
        secondaryActionButtonTitle: String,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        bind(
            image: image,
            title: title,
            description: description,
            primaryActionButtonTitle: primaryActionButtonTitle,
            secondaryActionButtonTitle: secondaryActionButtonTitle,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        )
    }
}

extension BottomWarningViewConfigurator {
    private mutating func bind(
        image: UIImage? = nil,
        title: String,
        description: BottomWarningViewConfigurator.BottomWarningDescription? = nil,
        primaryActionButtonTitle: String? = nil,
        secondaryActionButtonTitle: String,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.description = description

        bindImage(image)
        bindTitle(title)
        bindDescriptionText(description)
        bindPrimaryActionButtonTitle(primaryActionButtonTitle)
        bindSecondaryActionButtonTitle(secondaryActionButtonTitle)

        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}

extension BottomWarningViewConfigurator {
    private mutating func bindImage(
        _ image: UIImage?
    ) {
        self.image = image
    }

    private mutating func bindTitle(
        _ title: String?
    ) {
        self.title = getTitle(
            title
        )
    }

    private mutating func bindDescriptionText(
        _ description: BottomWarningViewConfigurator.BottomWarningDescription?
    ) {
        self.descriptionText = getDescription(
            description
        )
    }

    private mutating func bindPrimaryActionButtonTitle(
        _ title: String?
    ) {
        primaryActionButtonTitle = getActionTitle(
            title
        )
    }

    private mutating func bindSecondaryActionButtonTitle(
        _ title: String
    ) {
        secondaryActionButtonTitle = getActionTitle(
            title
        )
    }
}

extension BottomWarningViewConfigurator {
    private func getTitle(
        _ aTitle: String?
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }
        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13

        return .attributedString(
            aTitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.center),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    private func getDescription(
        _ aDescription: BottomWarningViewConfigurator.BottomWarningDescription?
    ) -> EditText? {
        guard let aDescription = aDescription else {
            return nil
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        let attributedString =
        aDescription
            .underlyingDescription
            .attributed([
                .textColor(AppColors.Components.Text.gray.uiColor),
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(.center),
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])

        let mutableAttributedString = NSMutableAttributedString(
            attributedString: attributedString
        )

        aDescription.params?.forEach {
            mutableAttributedString.addColor(AppColors.Components.Text.main.uiColor, to: $0)
        }

        return .attributedString(
            mutableAttributedString
        )
    }

    private func getActionTitle(
        _ aTitle: String?
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            aTitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.center),
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}

extension BottomWarningViewConfigurator {
    func getLinkAttributes() -> Dictionary<NSAttributedString.Key, Any> {
        let font = Fonts.DMSans.medium.make(15).uiFont
        let lineHeightMultiplier = 1.23

        let attributes: TextAttributeGroup = [
            .textColor(AppColors.Components.Link.primary.uiColor),
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .textAlignment(.center),
                .lineBreakMode(.byWordWrapping),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]

        return attributes.asSystemAttributes()
    }
}

extension BottomWarningViewConfigurator {
    enum BottomWarningDescription {
        typealias MarkedWordWithHandler = (word: String, handler: () -> Void)
        typealias LocalizedTextWithParams = (text: String, params: [String]?)

        case plain(
            _ description: String
        )
        case custom(
            description: LocalizedTextWithParams,
            markedWordWithHandler: MarkedWordWithHandler
        )

        var underlyingDescription: String {
            switch self {
            case .plain(let description):
                return description
            case .custom(let description, _):
                return description.text
            }
        }

        var params: [String]? {
            switch self {
            case .custom(let description, _):
                return description.params
            default:
                return nil
            }
        }
    }
}

