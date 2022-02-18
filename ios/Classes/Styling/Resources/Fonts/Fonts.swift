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
//   Fonts.swift

import Foundation
import MacaroonUIKit
import UIKit

enum Fonts {
    enum DMMono: String, FontMaker {
        case regular = "Regular"
        case light = "Light"
        case lightItalic = "LightItalic"
        case italic = "Italic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"

        var name: String {
            return "DMMono-\(rawValue)"
        }
    }

    enum DMSans: String, FontMaker {
        case regular = "Regular"
        case bold = "Bold"
        case boldItalic = "BoldItalic"
        case italic = "Italic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"

        var name: String {
            return "DMSans-\(rawValue)"
        }
    }
}

protocol FontMaker {
    var name: String { get }
}

extension FontMaker {
    func make(
        _ size: FontSize,
        _ style: CustomFont.Style? = nil
    ) -> CustomFont {
        return CustomFont(
            name: name,
            size: size,
            style: style
        )
    }
}
