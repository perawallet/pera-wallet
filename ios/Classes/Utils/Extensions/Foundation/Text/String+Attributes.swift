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
//  String+Attributes.swift

import UIKit

extension String {
    enum Attribute {
        case textColor(UIColor)
        case font(UIFont)
        case letterSpacing(CGFloat)
        case lineSpacing(CGFloat)
    }
    
    func attributed(_ attributes: [Attribute] = []) -> NSAttributedString {
        var theAttributes: [NSAttributedString.Key: Any] = [:]
        
        for attribute in attributes {
            switch attribute {
            case .textColor(let color):
                theAttributes[.foregroundColor] = color
            case .font(let font):
                theAttributes[.font] = font
            case .letterSpacing(let spacing):
                theAttributes[.kern] = spacing
            case .lineSpacing(let spacing):
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = spacing
                theAttributes[.paragraphStyle] = paragraphStyle
            }
        }
        
        return NSAttributedString(string: self, attributes: theAttributes)
    }
    
    // MARK: - Size
    func width(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func height(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func size(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func height(withConstrained width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        
        return ceil(boundingBox.height)
    }
}

extension String {
    typealias StringAttribute = [NSAttributedString.Key: Any]

    func addAttributes(_ attributes: StringAttribute, to targetString: String) -> NSAttributedString {
        let range = (self as NSString).range(of: targetString)
        let attributedText = NSMutableAttributedString(string: self)
        attributes.forEach { key, value in
            attributedText.addAttribute(key, value: value, range: range)
        }
        return attributedText
    }
}

extension NSAttributedString {
    func appendAttributesToRange(
        _ attributes: [NSAttributedString.Key: Any],
        of targetString: String
    ) -> NSAttributedString {
        let range = (string as NSString).range(of: targetString)
        let attributedText = NSMutableAttributedString(string: string)
        attributes.forEach { key, value in
            attributedText.addAttribute(key, value: value, range: range)
        }
        return attributedText
    }
}
