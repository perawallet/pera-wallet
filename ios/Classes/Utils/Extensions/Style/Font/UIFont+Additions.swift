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
//  UIFont+Additions.swift

import UIKit

enum FontType: String {
    case publicSans = "PublicSans"
}

enum FontWeight {
    case bold(size: CGFloat)
    case medium(size: CGFloat)
    case regular(size: CGFloat)
    case semiBold(size: CGFloat)
}

extension UIFont {
    static func font(withWeight weight: FontWeight, _ font: FontType = .publicSans) -> UIFont {
        let fontName = self.fontName(font, withWeight: weight)
        
        switch weight {
        case .bold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case .medium(size: let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .regular(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        case .semiBold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        }
    }
    
    private static func fontName(_ font: FontType, withWeight weight: FontWeight) -> String {
        let fontName = "\(font.rawValue)-"
        
        switch weight {
        case .bold:
            return fontName.appending("Bold")
        case .medium:
            return fontName.appending("Medium")
        case .regular:
            return fontName.appending("Regular")
        case .semiBold:
            return fontName.appending("SemiBold")
        }
    }
}
