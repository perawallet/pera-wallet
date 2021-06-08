// Copyright 2019 Algorand, Inc.

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
    case black(size: CGFloat)
    case blackItalic(size: CGFloat)
    case bold(size: CGFloat)
    case boldItalic(size: CGFloat)
    case extraBold(size: CGFloat)
    case extraBoldItalic(size: CGFloat)
    case extraLight(size: CGFloat)
    case extraLightItalic(size: CGFloat)
    case italic(size: CGFloat)
    case light(size: CGFloat)
    case lightItalic(size: CGFloat)
    case medium(size: CGFloat)
    case mediumItalic(size: CGFloat)
    case regular(size: CGFloat)
    case semiBold(size: CGFloat)
    case semiBoldItalic(size: CGFloat)
    case thin(size: CGFloat)
    case thinItalic(size: CGFloat)
}

extension UIFont {
    static func font(withWeight weight: FontWeight, _ font: FontType = .publicSans) -> UIFont {
        let fontName = self.fontName(font, withWeight: weight)
        
        switch weight {
        case .black(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        case .blackItalic(size: let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .bold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case .boldItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .extraBold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
        case .extraBoldItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .extraLight(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case .extraLightItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .italic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
        case .light(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .lightItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
        case .medium(size: let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .mediumItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .regular(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        case .semiBold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        case .semiBoldItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .thin(size: let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .thinItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        }
    }
    
    private static func fontName(_ font: FontType, withWeight weight: FontWeight) -> String {
        let fontName = "\(font.rawValue)-"
        
        switch weight {
        case .black:
            return fontName.appending("Black")
        case .blackItalic:
            return fontName.appending("BlackItalic")
        case .bold:
            return fontName.appending("Bold")
        case .boldItalic:
            return fontName.appending("BoldItalic")
        case .extraBold:
            return fontName.appending("ExtraBold")
        case .extraBoldItalic:
            return fontName.appending("ExtraBoldItalic")
        case .extraLight:
            return fontName.appending("ExtraLight")
        case .extraLightItalic:
            return fontName.appending("ExtraLightItalic")
        case .italic:
            return fontName.appending("Italic")
        case .light:
            return fontName.appending("Light")
        case .lightItalic:
            return fontName.appending("LightItalic")
        case .medium:
            return fontName.appending("Medium")
        case .mediumItalic:
            return fontName.appending("MediumItalic")
        case .regular:
            return fontName.appending("Regular")
        case .semiBold:
            return fontName.appending("SemiBold")
        case .semiBoldItalic:
            return fontName.appending("SemiBoldItalic")
        case .thin:
            return fontName.appending("Thin")
        case .thinItalic:
            return fontName.appending("ThinItalic")
        }
    }
}
