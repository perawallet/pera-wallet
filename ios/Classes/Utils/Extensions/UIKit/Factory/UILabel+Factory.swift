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
//  UILabel+Factory.swift

import UIKit

extension UILabel {
    
    @discardableResult
    func withLine(_ line: Line) -> UILabel {
        switch line {
        case .single:
            numberOfLines = 1
            lineBreakMode = .byTruncatingTail
        case .multi(let line):
            numberOfLines = line
            lineBreakMode = .byWordWrapping
        case .contained:
            numberOfLines = 0
            lineBreakMode = .byWordWrapping
        }
        
        return self
    }
    
    @discardableResult
    func withFont(_ font: UIFont) -> UILabel {
        self.font = font
        return self
    }
    
    @discardableResult
    func withTextColor(_ textColor: UIColor) -> UILabel {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    func withText(_ text: String) -> UILabel {
        self.text = text
        return self
    }
    
    @discardableResult
    func withAttributedText(_ text: NSAttributedString) -> UILabel {
        self.attributedText = text
        return self
    }
    
    @discardableResult
    func withAlignment(_ alignment: NSTextAlignment) -> UILabel {
        self.textAlignment = alignment
        return self
    }
}

extension UILabel {
    
    enum Line {
        case single
        case multi(Int)
        case contained
    }
}

extension UILabel {
    func clearText() {
        text = nil
        attributedText = nil
    }
}
