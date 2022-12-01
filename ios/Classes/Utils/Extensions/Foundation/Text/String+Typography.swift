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
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.largeTitleMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func largeTitleRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.largeTitleRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func largeTitleMonoMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.largeTitleMonoMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func largeTitleMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.largeTitleMonoRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func titleBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.titleBoldAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func titleMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.titleMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func titleMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.titleMonoRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func titleSmallBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.titleSmallBoldAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func titleSmallMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.titleSmallMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }
}

// MARK: - Body

extension String {
    func bodyLargeMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyLargeMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func bodyLargeRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyLargeRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func bodyLargeMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyLargeMonoRegular(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func bodyBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyBoldAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func bodyMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func bodyRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func bodyMonoMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyMonoMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func bodyMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.bodyMonoRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }
}

// MARK: - Footnote

extension String {
    func footnoteHeadingMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.footnoteHeadingMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func footnoteBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.footnoteBoldAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func footnoteMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.footnoteMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func footnoteRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.footnoteRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func footnoteMonoMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.footnoteMonoMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func footnoteMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.footnoteMonoRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }
}

// MARK: - Caption

extension String {
    func captionBold(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.captionBoldAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func captionMedium(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.captionMediumAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func captionRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.captionMonoRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }

    func captionMonoRegular(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        supportsDynamicType: Bool = false
    ) -> NSAttributedString {
        return attributed(
            Typography.captionMonoRegularAttributes(
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                supportsDynamicType: supportsDynamicType
            )
        )
    }
}
