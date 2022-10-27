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
        title = .attributedString(
            "pera-announcement-title"
                .localized
                .bodyRegular()
        )
    }

    private mutating func bindSubtitle() {
        subtitle = .attributedString(
            "pera-announcement-subtitle"
                .localized
                .title1Medium()
        )
    }

    private mutating func bindDescription() {
        let text = "pera-announcement-description".localized
        let highlightedText = "pera-announcement-description-blog".localized

        let textAttributes = NSMutableAttributedString(
            attributedString: text.bodyMonoRegular()
        )

        let highlightedTextAttributes: TextAttributeGroup = [
            .textColor(AppColors.Components.Link.primary.uiColor),
            .font(Fonts.DMMono.medium.make(15).uiFont)
        ]

        let highlightedTextRange = (textAttributes.string as NSString).range(of: highlightedText)

        textAttributes.addAttributes(
            highlightedTextAttributes.asSystemAttributes(),
            range: highlightedTextRange
        )

        description = .attributedString(
            textAttributes
        )
    }
}
