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
//  NSAttributedString+Additions.swift

import CoreGraphics
import Foundation
import MacaroonUIKit
import UIKit

extension NSAttributedString {
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let compoundAttributedString = NSMutableAttributedString()
        compoundAttributedString.append(lhs)
        compoundAttributedString.append(rhs)
        return compoundAttributedString
    }

    func height(withConstrained width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)

        let rect = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin],
            context: nil
        )

        return ceil(rect.size.height)
    }

    func addAttributes(
        to attributedText: String,
        newAttributes: TextAttributeGroup
    ) -> NSMutableAttributedString {
        let selfMutableString = NSMutableAttributedString(
            attributedString: self
        )

        let attributedRange = (selfMutableString.string as NSString).range(of: attributedText)

        selfMutableString.addAttributes(
            newAttributes.asSystemAttributes(),
            range: attributedRange
        )

        return selfMutableString
    }

    func add(
        _ newAttributes: TextAttributeGroup
    ) -> NSMutableAttributedString {
        let selfMutableString = NSMutableAttributedString(
            attributedString: self
        )
        let fullRange = NSRange(
            location: 0,
            length: length
        )

        selfMutableString.addAttributes(
            newAttributes.asSystemAttributes(),
            range: fullRange
        )

        return selfMutableString
    }

    func calculateNumberOfLines(
        toFitIn width: CGFloat,
        font: UIFont
    ) -> Int {
        let size = CGSize(
            width: width,
            height: .greatestFiniteMagnitude
        )
        let characterHeight = font.lineHeight
        let text = string as NSString

        let fullTextSize = text.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [
                .font: font
            ],
            context: nil
        )
        let numberOfLines = Int(ceil(fullTextSize.height / characterHeight))
        return numberOfLines
    }
}

extension Array where Element == NSAttributedString {
    public func compound(
        _ separator: String = " "
    ) -> NSAttributedString {
        return self.joined(separator: separator)
    }
}

extension Array where Element == NSAttributedString? {
    public func compound(
        _ separator: String = " "
    ) -> NSAttributedString {
        return self
            .compactMap { $0 }
            .joined(separator: separator)
    }
}

extension Array where Element == NSAttributedString {
    func joined(separator: NSAttributedString) -> NSAttributedString {
        guard let firstElement = first else {
            return NSMutableAttributedString(string: "")
        }

        let joined =
            dropFirst()
                .reduce(
                    into: NSMutableAttributedString(attributedString: firstElement)
                ) { result, element in
                    result.append(separator)
                    result.append(element)
                }
        return joined
    }

    func joined(separator: String) -> NSAttributedString {
        guard let firstElement = first else {
            return NSMutableAttributedString(string: "")
        }

        let attributedStringSeparator = NSAttributedString(string: separator)

        let joined =
            dropFirst()
                .reduce(
                    into: NSMutableAttributedString(attributedString: firstElement)
                ) { result, element in
                    result.append(attributedStringSeparator)
                    result.append(element)
                }
        return joined
    }
}
