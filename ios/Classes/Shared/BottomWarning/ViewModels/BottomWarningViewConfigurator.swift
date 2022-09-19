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
        
        return .attributedString(
            aTitle
                .bodyLargeMedium(
                    alignment: .center
                )
        )
    }

    private func getDescription(
        _ aDescription: BottomWarningViewConfigurator.BottomWarningDescription?
    ) -> EditText? {
        guard let aDescription = aDescription else {
            return nil
        }

        var attributes = Typography.bodyRegularAttributes(
            alignment: .center
        )

        attributes.insert(.textColor(Colors.Text.gray))

        let attributedString =
        aDescription
            .underlyingDescription
            .attributed(
                attributes
            )

        let mutableAttributedString = NSMutableAttributedString(
            attributedString: attributedString
        )

        aDescription.params?.forEach {
            let paramRange = (mutableAttributedString.string as NSString).range(of: $0)

            let paramAttributes: TextAttributeGroup = [
                .textColor(Colors.Text.main)
            ]

            mutableAttributedString.addAttributes(
                paramAttributes.asSystemAttributes(),
                range: paramRange
            )
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

        return .attributedString(
            aTitle
                .bodyMedium(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}

extension BottomWarningViewConfigurator {
    func getLinkAttributes() -> Dictionary<NSAttributedString.Key, Any> {
        var attributes = Typography.bodyMediumAttributes(
            alignment: .center
        )

        attributes.insert(.textColor(Colors.Link.primary))

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

