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
    private(set) var image: UIImage
    private(set) var title: String
    private(set) var description: BottomWarningDescription? = nil
    private(set) var primaryActionButtonTitle: String? = nil
    private(set) var secondaryActionButtonTitle: String
    private(set) var primaryAction: (() -> Void)? = nil
    private(set) var secondaryAction: (() -> Void)? = nil
}

extension BottomWarningViewConfigurator {
    func getTitle() -> EditText {
        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13

        return .attributedString(
            title
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

    func getDescription() -> EditText? {
        guard let description = description else {
            return nil
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            description
                .underlyingDescription
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

    func getPrimaryActionTitle() -> EditText? {
        guard let title = primaryActionButtonTitle else {
            return nil
        }

        return getActionTitle(
            title
        )
    }

    func getSecondaryActionTitle() -> EditText {
        return getActionTitle(
            secondaryActionButtonTitle
        )
    }

    private func getActionTitle(
        _ aTitle: String
    ) -> EditText {
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
    enum BottomWarningDescription {
        typealias Hyperlink = (word: String, url: URL)

        case plain(_ description: String)
        case customURL(description: String, hyperlink: Hyperlink)

        var underlyingDescription: String {
            switch self {
            case .plain(let description): return description
            case .customURL(let description, _): return description
            }
        }
    }
}
