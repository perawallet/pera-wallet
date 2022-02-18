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
    private(set) var title: EditText
    private(set) var description: EditText?
    private(set) var primaryActionButtonTitle: String?
    private(set) var secondaryActionButtonTitle: String
    private(set) var primaryAction: (() -> Void)?
    private(set) var secondaryAction: (() -> Void)?

    init(
        image: UIImage,
        title: String,
        description: String? = nil,
        primaryActionButtonTitle: String? = nil,
        secondaryActionButtonTitle: String,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.image = image
        self.title = Self.getTitle(title)
        self.description = Self.getDescription(description)
        self.primaryActionButtonTitle = primaryActionButtonTitle
        self.secondaryActionButtonTitle = secondaryActionButtonTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}

extension BottomWarningViewConfigurator {
    private static func getTitle(_ text: String) -> EditText {
        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13

        return .attributedString(
            text
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

    private static func getDescription(_ text: String?) -> EditText? {
        guard let text = text else {
            return nil
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            text
                .localized
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
}
